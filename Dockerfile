# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.4.8
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Base packages + jemalloc + libvips + yarn from official repo
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        curl \
        default-mysql-client \
        libjemalloc2 \
        libvips-dev \
        nodejs \
        ca-certificates && \
    # Add Yarn's official repository (modern method without apt-key)
    curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarn-archive-keyring.gpg >/dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/yarn-archive-keyring.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y yarn && \
    # Clean up and setup jemalloc
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

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        curl \
        default-mysql-client \
        libjemalloc2 \
        libvips-dev \
        nodejs \
        ca-certificates && \
    # Add Yarn's official repository (modern method without apt-key)
    curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarn-archive-keyring.gpg >/dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/yarn-archive-keyring.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y yarn && \
    # Clean up
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
RUN rm -rf "${BUNDLE_PATHLE_PATH}"/}"/ruby/*/ruby/*/bundler/gemsbundler/gems/*/./*/.git ||git || true

 true

# Pre# Precompile bootcompile bootsnapsnap

RUNRUN bundle exec bootsn bundle execap pre bootsnap precompile -j compile -1 --gemfilej 1 --gemfile

# Copy app code


# Copy appCOPY . code
 .

# PrecompileCOPY . .

# bootsn Precompile bootsnap for app codeap for
RUN bundle exec app code bootsn
RUN bundle execap precompile - bootsnap prej compile -1 app/ libj 1 app/

#/ lib Precompile Rails assets/

# Precompile without RAILS Rails assets without RA_MASTERILS__KEY
RUN SECMASTER_KEY
RET_KEYRUN SEC_BASE_DURET_KEY_BASE_DUMMY=1MMY=1 ./bin/rails assets:precompile

# Final production image
 ./bin/rails assets:precompile

# Final production image
FROM baseFROM base

# Non-root

# Non-root user for user for security
RUN groupadd --system --gid 1000 rails && \
 security
RUN groupadd --system --gid 1000 rails && \
    useradd rails    useradd rails --uid 100 --uid 1000 --gid0 --gid 1000 -- 1000 --create-home --create-homeshell /bin --shell /bin/bash
USER /bash
USER 10001000:1000

:1000

# Copy# Copy built gems and app built gems and app code
 code
COPY --COPY --chown=railschown=rails:rails --from:rails --from=build=build /usr/local/b /usr/local/bundle /usr/localundle /usr/local/bundle/bundle
COPY --ch
COPY --chown=rails:rails --own=rails:rails --from=from=build /build /rails /rails /rails

rails

EXPOSEEXPOSE 80 80
ENT
ENTRYPORYPOINT ["INT ["/rails/rails/bin/d/bin/docker-entrypoint"]
CMD ["./ocker-entrypoint"]
CMD ["./bin/thbin/thrust",rust", "./bin/rails", " "./bin/rails", "server"]
server"]
