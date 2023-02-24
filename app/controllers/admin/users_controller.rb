class Admin::UsersController < ApplicationController
  # прописываем отдельно всю администраторскую логику

  before_action :require_authentication

  def index
    @pagy, @users = pagy User.order(created_at: :desc)
  end
end