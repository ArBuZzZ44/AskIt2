module Recoverable
  extend ActiveSupport::Concern

  included do 
    # метод password_digest_changed? создаем сам rails, т.к. у нас есть password_diges в бд
    before_update :clear_reset_password_token, if: :password_digest_changed?
    def set_password_reset_token
      update password_reset_token: digest(SecureRandom.urlsafe_base64),
              password_reset_token_sent_at: Time.current
    end

    def clear_reset_password_token
      self.password_reset_token = nil 
      self.password_reset_token_sent_at = nil 
    end

    def password_reset_period_valid?
      # если разница больше, чем 60 минут, значит токен истек
      password_reset_token_sent_at.present? && Time.current - password_reset_token_sent_at <= 60.minutes
    end
  end
end