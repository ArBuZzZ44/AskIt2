# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend
  include ErrorHandling
  include Authentication

  around_action :switch_locale

  private

  # action - действие контроллера, которое необходимо выполнить
  def switch_locale(&action)
    locale = locale_from_url || I18n.default_locale # locale из url либо по умолчанию
    I18n.with_locale locale, &action
  end

  def locale_from_url
    locale = params[:locale]

    # если запрошенную locale мы поддерживаем, то мы ее выдаем
    return locale if I18n.available_locales.map(&:to_s).include?(locale) # переводим locale к строке
  end

  # чтобы к url указывалась текущая локаль
  def default_url_options
    { locale: I18n.locale }
  end
end
