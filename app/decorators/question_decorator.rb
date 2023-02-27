# frozen_string_literal: true

class QuestionDecorator < ApplicationDecorator
  delegate_all

  # l - localize, берется из стандартного перевода i18n
  def formatted_created_at
    l created_at, format: :long
  end
end
