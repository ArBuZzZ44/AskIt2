# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    # прописываем отдельно всю администраторскую логику

    before_action :require_authentication
    before_action :set_user!, only: %i[edit update destroy]
    before_action :authorize_user!
    after_action :verify_authorized

    def index
      respond_to do |format| # показываем приложению как отвечать на разные форматы
        format.html do # описываем все форматы
          @pagy, @users = pagy User.order(created_at: :desc)
        end

        format.zip do 
          UserBulkExportJob.perform_later current_user
          flash[:success] = t '.success'
          redirect_to admin_users_path
        end
      end
    end

    def edit; end

    def create
      if params[:archive].present?
        UserBulkImportJob.perfom_later create_blob, current_user # later чтобы задача поставилась в очередь и выполнилась в фоне
        flash[:success] = 'Users imported!'
      end

      redirect_to admin_users_path
    end

    def update
      if @user.update user_params
        flash[:success] = 'User updated'
        redirect_to admin_users_path
      else
        render :edit
      end
    end

    def destroy
      @user.destroy
      flash[:success] = 'User deleted!'
      redirect_to admin_users_path
    end

    private

    def create_blob
      # io - input output.
      file = File.open params[:archive]
      result = ActiveStorage::Blob.create_and_upload! io: file,
                                                      filename: params[:archive].original_filename
      file.close 
      # key - некий уникальный идентификатор загруженного файла
      result.key
    end

    def set_user!
      @user = User.find params[:id]
    end

    def user_params
      params.require(:user).permit(
        :email, :name, :password, :password_confirmation, :role
      ).merge(admin_edit: true)
    end

    def authorize_user!
      authorize(@user || User)
    end
  end
end
