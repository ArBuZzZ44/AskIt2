# frozen_string_literal: true

class QuestionDecorator < ApplicationDecorator
  delegate_all
  # чтобы автоматически декорировалась ассоциация, которую мы применяем к этому объекту
  decorates_association :user

  # l - localize, берется из стандартного перевода i18n
  def formatted_created_at
    l created_at, format: :long
  end
end
