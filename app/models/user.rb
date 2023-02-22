class User < ApplicationRecord
  attr_accessor :old_password, :remember_token # создает виртуальный атрибут, который нужен для создания поля в форме и проверки пароля

  has_secure_password  validations: false # создает виртуальный атрибут password и password_confirmation. Они не попадают в бд, в бд идет только хеш пароля в password_digest

  validate :password_presence
  validate :correct_old_password, on: :update, if: -> {password.present?} # только при обновлении и вводе нового пароля
  validates :password, confirmation: true, allow_blank: true, # password должен совпадать с password_confirmation, allow_blank в данном случае означает, что при обновлении учетной записи юзер может оставить его пустым
    length: {minimum: 8, maximum: 70} 

  validates :email, presence: true, uniqueness: true, 'valid_email_2/email': true
  validate :password_complexity

  def remember_me 
    # генерируется сам токен, на основе которого делается хеш
    self.remember_token = SecureRandom.urlsafe_base64 
    # токен помещаем в таблицу
    update_column :remember_token_digest, digest(remember_token)
  end

  def forget_me
    update_column :remember_token_digest, nil # очищем поле при выходе пользователя из системы
    self.remember_token = nil
  end

  def remember_token_authenticated?(remebmer_token)
    return false unless remember_token_digest.present? # если этого digest здесь нет, сразу возвращает false без проверки
    # для проверки токена, который передается и токена, который есть в бд
    BCrypt::Password.new(remember_token_digest).is_password?(remember_token)
  end


  private

   def digest(string) # генерируется хеш на основе строки
    cost = ActiveModel::SecurePassword.
      min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def correct_old_password
    # password_digest_was берет иммено старый password_digest_was и сравнивает с password_digest на основе old_password
    return if BCrypt::Password.new(password_digest_was).is_password?(old_password)

    errors.add :old_password, 'is incorrect'
  end

  def password_complexity
    # Regexp extracted from https://stackoverflow.com/questions/19605150/regex-for-password-must-contain-at-least-eight-characters-at-least-one-number-a
    return if password.blank? || password =~ /^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,70}$/

    errors.add :password, 'complexity requirement not met. Length should be 8-70 characters and include: 1 uppercase, 1 lowercase, 1 digit and 1 special character'
  end

  def password_presence
    errors.add(:password, :blank) unless password_digest.present? # если password_digest существует, то пароль можно указывать либо не указывать
  end
end
