# frozen_string_literal: true

require 'sidekiq/web'

class AdminConstraint
  def mathes?(request)
    # берем либо из сессии, либо из куки
    user_id = request.session[:user_id] || request.cookie_jar.encrypted[:user_id]

    User.find_by(id: user_id)&.admin_role?
  end
end

Rails.application.routes.draw do
  mount Sidekiq::Web =>'/sidekiq', constraints: AdminConstraint.new

  concern :commentable do
    resources :comments, only: %i[create destroy]
  end

  namespace :api do
    resources :tags, only: :index
  end

  # скобки чтобы можно было в маршрут передавать локаль либо не передавать
  # локали передаем из конфига с помощью регулярного выражения
  scope '(:locale)', locale: /#{I18n.available_locales.join("|")}/ do
    # для входа в пользователя в систему, destroy, чтобы пользователь мог выходить
    resource :session, only: %i[new create destroy]

    resource :password_reset, only: %i[new create edit update]

    resources :users, only: %i[new create edit update]

    resources :questions, concern: :commentable do
      resources :answers, except: %i[new show] # except - кроме, т.е. исключаем ненужные маршруты
    end

    resources :answers, except: %i[new show], concern: :commentable

    # создаем пространство имен для admin и маршрут для этого имени
    namespace :admin do
      resources :users, only: %i[index create edit update destroy]
    end

    root 'pages#index'
  end
end
