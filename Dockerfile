# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.4.8
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Base packages + jemalloc + libvips
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        curl \
        default-mysql-client \
        libjemalloc2 \
        libvips-dev \
        nodejs \
        yarn && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so" \
    BOOTSNAP_CACHE_DIR="/tmp/cache"

# Build stage
FROM base AS build

# Base packages + jemalloc + libvips + nodejs + yarn
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        curl \
        gnupg2 \
        ca-certificates \
        default-mysql-client \
        libjemalloc2 \
        libvips-dev \
        nodejs && \
    # Add Yarn APT repository
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y yarn && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

# Copy Gemfiles and vendor directory
COPY Gemfile Gemfile.lock ./
COPY vendor/* ./vendor/

# Install gems
RUN gem install bundler -v 2.4.19 && \
    bundle install --jobs 4 --retry 3

# Clean caches safely
RUN rm -rf "${BUNDLE_PATH}"/ruby/*/cache || true
RUN rm -rf "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git || true

# Precompile bootsnap
RUN bundle exec bootsnap precompile -j 1 --gemfile

# Copy app code
COPY . .

# Precompile bootsnap for app code
RUN bundle exec bootsnap precompile -j 1 app/ lib/

# Precompile Rails assets without RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Final production image
FROM base

# Non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash
USER 1000:1000

# Copy built gems and app code
COPY --chown=rails:rails --from=build /usr/local/bundle /usr/local/bundle
COPY --chown=rails:rails --from=build /rails /rails

EXPOSE 80
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["./bin/thrust", "./bin/rails", "server"]

