module Rememberable
  extend ActiveSupport::Concern

  included do 
    attr_accessor :remember_token

    def remember_me
      # генерируется сам токен, на основе которого делается хеш
      self.remember_token = SecureRandom.urlsafe_base64
      # rubocop:disable Rails/SkipsModelValidations
      # токен помещаем в таблицу
      update_column :remember_token_digest, digest(remember_token)
      # rubocop:enable Rails/SkipsModelValidations
    end

    def forget_me
      # rubocop:disable Rails/SkipsModelValidations
      update_column :remember_token_digest, nil # очищем поле при выходе пользователя из системы
      # rubocop:enable Rails/SkipsModelValidations
      self.remember_token = nil
    end

    def remember_token_authenticated?(remember_token)
      return false if remember_token_digest.blank?

      # для проверки токена, который передается и токена, который есть в бд
      BCrypt::Password.new(remember_token_digest).is_password?(remember_token)
    end
  end
end