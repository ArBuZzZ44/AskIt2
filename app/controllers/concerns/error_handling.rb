# frozen_string_literal: true

module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :notfound
    # значит обрабатывать ошибку ActiveRecord в методе notfound

    private

    # exception - ошибка, которая произошла
    def notfound(exception)
      logger.warn exception # записывает в журнал событий rails данную ошибку
      render file: 'public/404.html', status: :not_found, layout: false
    end
  end
end
