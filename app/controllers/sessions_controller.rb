# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :require_no_authentication, only: %i[new create]
  before_action :require_authentication, only: :destroy

  def new; end

  def create
    user = User.find_by email: params[:email]
    # добавляем амперсант, если user будет nil, то данное условие сразу обратиться в ложное и мы уйдем в ветку else
    if user&.authenticate(params[:password]) # метод authenticate добавляется благодаря has_secure_password
      do_sign_in user # в моделт User. принимает строку, конвертирует ее в хеш и сравнивает с хешем в бд
    else
      flash[:warning] = 'Incorrect email and/or password'
      render :new
    end
  end

  def destroy
    sign_out
    flash[:success] = 'See you later!'
    redirect_to root_path
  end

  private

  def do_sign_in(user)
    sign_in user
    remember(user) if params[:remember_me] == '1'
    flash[:success] = "Welcome back, #{current_user.name_or_email}!"
    redirect_to root_path
  end
end
