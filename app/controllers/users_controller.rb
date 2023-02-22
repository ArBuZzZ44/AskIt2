class UsersController < ApplicationController
  before_action :require_no_authentication, only: %i[new create]
  before_action :require_authentication, only: %i[edit update]
  
  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the AskIt, #{current_user.name_or_email}"
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
  end

  def update
  end
    
  end

  private

  def user_params
    params.require(:user).permit(:email, :name, :password, :password_confirmation)
  end
end
