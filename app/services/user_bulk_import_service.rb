# frozen_string_literal: true

class UserBulkImportService < ApplicationService
  attr_reader :archive_key, :service

  def initialize(archive_key)
    @archive_key = archive_key
    @service = ActiveStorage::Blob.service
    # tempfile позволяет получать ссылку на загружаемый файл
  end

  def call
    read_zip_entries do |entry|
      entry.get_input_stream do |f|
        User.import users_from(f.read), ignore: true 
        f.close 
      end
    end
  ensure
    service.delete archive_key # чтобы удалить архив, с которым мы работали(хранящийся на диске)
  end

  private

  def read_zip_entries
    return unless block_given?

    stream = zip_stream # метод, выполняющий стриминг загруженного файла zip

    loop do 
      entry = stream.get_next_entry # берем следующую запись из архива

      break unless entry # если файлы закончились, то выход из цикла
      next unless entry.name.end_with? '.xlsx'

      yield entry # передается в метод read_zip_entries 
    end
  ensure
    stream.close # закрываем поток
  end

  def zip_stream
    f = File.open service.path_for(archive_key) # получаем путь к загруженному файла по его ключу
    stream = Zip::InputStream.new(f)
    f.close
    stream
  end

  def users_from(data)
    # парсим файл, 0 указывает на первый лист документа
    sheet = RubyXL::Parser.parse_buffer(data)[0]
    sheet.map do |row|
      cells = row.cells
      User.new name: cells[0].value,
               email: cells[1].value,
               password: cells[2].value,
               password_confirmation: cells[2].value
    end
  end
end
