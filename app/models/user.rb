# frozen_string_literal: true

class User < ApplicationRecord
  include Recoverable
  include Rememberable

  enum role: { basic: 0, moderator: 1, admin: 2 }, _suffix: :role

  # создает виртуальный атрибут, который нужен для создания поля в форме и проверки пароля
  attr_accessor :old_password, :remember_token, :admin_edit

  # создает виртуальный атрибут password и password_confirmation.
  # Они не попадают в бд, в бд идет только хеш пароля в password_digest
  has_secure_password validations: false

  has_many :questions, dependent: :destroy
  has_many :answers, dependent: :destroy

  validate :password_presence
  validate :correct_old_password, on: :update, if: lambda {
                                                     password.present? && !admin_edit
                                                   } # только при обновлении и вводе нового пароля
  validates :password, confirmation: true, allow_blank: true, # password должен совпадать с password_confirmation,
                       length: { minimum: 8, maximum: 70 }
  # allow_blank в данном случае означает, что при обновлении учетной записи юзер может оставить его пустым

  validates :email, presence: true, uniqueness: true, 'valid_email_2/email': true
  validate :password_complexity
  validates :role, presence: true

  # функция обратного вызова, выполняется перед сохранением записи в бд
  before_save :set_gravatar_hash, if: :email_changed? # email_changed? - метод RoR

  def guest?
    false
  end

  def author?(obj)
    obj.user == self
  end


  private

  def set_gravatar_hash
    return if email.blank?

    # генерируем хеш на основе email пользователя
    hash = Digest::MD5.hexdigest email.strip.downcase
    self.gravatar_hash = hash
  end

  # генерируется хеш на основе строки
  def digest(string)
    cost = if ActiveModel::SecurePassword
              .min_cost
             BCrypt::Engine::MIN_COST
           else
             BCrypt::Engine.cost
           end
    BCrypt::Password.create(string, cost:)
  end

  def correct_old_password
    # password_digest_was берет иммено старый password_digest_was и сравнивает с password_digest на основе old_password
    return if BCrypt::Password.new(password_digest_was).is_password?(old_password)

    errors.add :old_password, 'is incorrect'
  end

  def password_complexity
    # Regexp extracted from https://stackoverflow.com/questions/19605150/regex-for-password-must-contain-at-least-eight-characters-at-least-one-number-a
    return if password.blank? || password =~ /^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,70}$/

    msg = 'complexity requirement not met. Length should be 8-70 characters and' \
          'include: 1 uppercase, 1 lowercase, 1 digit and 1 special character'
    errors.add :password, msg
  end

  def password_presence
    return if password_digest.present?

    errors.add(:password, :blank)
  end
end
