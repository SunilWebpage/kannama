class UsersController < ApplicationController
  def index
    @users = User.all
  end

def create
  @user = User.new(user_params)
  if @user.save
    redirect_to users_path
  else
    render :new
  end
end

def login
  @user = User.new
end

def login_form
  @user = User.find_by(username: user_params[:username], password: user_params[:password])
   if @user && @user.password == user_params[:password] 
    session[:user_id] = @user.id
    redirect_to home_path
  else
    flash.now[:alert] = "Invalid username or password"
    render :login
  end 
end

private

def user_params
  params.require(:user).permit(:username, :password)
end

end