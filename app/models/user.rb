class User < ApplicationRecord
  attr_accessor :old_password # создает виртуальный атрибут, который нужен для создания поля в форме и проверки пароля

  has_secure_password  validations: false # создает виртуальный атрибут password и password_confirmation. Они не попадают в бд, в бд идет только хеш пароля в password_digest

  validate :password_presence
  validate :correct_old_password, on: :update # только при обновлении
  validates :password, confirmation: true, allow_blank: true, # password должен совпадать с password_confirmation, allow_blank в данном случае означает, что при обновлении учетной записи юзер может оставить его пустым
    length: {minimum: 8, maximum: 70} 

  validates :email, presence: true, uniqueness: true
  validate :password_complexity

  private

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
