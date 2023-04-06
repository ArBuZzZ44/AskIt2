# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    # прописываем отдельно всю администраторскую логику

    before_action :require_authentication

    def index
      respond_to do |format| # показываем приложению как отвечать на разные форматы
        format.html do # описываем все форматы
          @pagy, @users = pagy User.order(created_at: :desc)
        end

        format.zip { respond_with_zipped_users }
      end
    end

    def create
      if params[:archive].present?
        UserBulkService.call params[:archive]
        flash[:success] = 'Users imported!'
      end

      redirect_to admin_users_path
    end

    private

    def respond_with_zipped_users
      # создаем спец объект OutputStream. это фактически архив, который мы будем
      # пересылать пользователю в ответ на его запрос, при этом на диске он
      #  храниться не будет. что-то вроде временного архива
      compressed_filestream = Zip::OutputStream.write_buffer do |zos|
        User.order(created_at: :desc).each do |user| # файл для каждого пользователя
          zos.put_next_entry "user_#{user.id}.xlsx"
          # генерация самого файла
          zos.print render_to_string( # генерируем строку в память и затем записываем в файл
            layout: false,
            handlers: [:axlsx], # обработчик шаблонов
            formats: [:xlsx], # формат
            template: 'admin/users/user', # указываем шаблон, который хотим рендерить
            locals: { user: } # передаем представлению локальную переменную из теущего юзера
          )
        end
      end

      compressed_filestream.rewind # "перематыаем" наш метод
      send_data compressed_filestream.read, filename: 'users.zip'
    end
  end
end
