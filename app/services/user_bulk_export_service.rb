class UserBulkExportService < ApplicationService
  def call
    renderer = ActionController::Base.new # render_to_string може вызывать только из контроллера

      # создаем спец объект OutputStream. это фактически архив, который мы будем
      # пересылать пользователю в ответ на его запрос, при этом на диске он
      #  храниться не будет. что-то вроде временного архива
     compressed_filestream = Zip::OutputStream.write_buffer do |zos|
        User.order(created_at: :desc).each do |user| # файл для каждого пользователя
          zos.put_next_entry "user_#{user.id}.xlsx"
          # генерация самого файла
          zos.print renderer.render_to_string( # генерируем строку в память и затем записываем в файл
            layout: false,
            handlers: [:axlsx], # обработчик шаблонов
            formats: [:xlsx], # формат
            template: 'admin/users/user', # указываем шаблон, который хотим рендерить
            locals: { user: } # передаем представлению локальную переменную из теущего юзера
          )
        end
      end

      compressed_filestream.rewind
      ActiveStorage::Blob.create_and_upload! io: compressed_filestream,
                                             filename: 'users.zip'
  end
end