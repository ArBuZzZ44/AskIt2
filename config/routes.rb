# frozen_string_literal: true

Rails.application.routes.draw do
  # скобки чтобы можно было в маршрут передавать локаль либо не передавать
  # локали передаем из конфига с помощью регулярного выражения 
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    # для входа в пользователя в систему, destroy, чтобы пользователь мог выходить
    resource :session, only: %i[new create destroy]

    resources :users, only: %i[new create edit update]

    resources :questions do
      resources :comments, only: %i[create destroy]

      resources :answers, except: %i[new show] # except - кроме, т.е. исключаем ненужные маршруты
    end

    resources :answers, except: %i[new show] do
      resources :comments, only: %i[create destroy]
    end

    # создаем пространство имен для admin и маршрут для этого имени
    namespace :admin do
      resources :users, only: %i[index create]
    end

    root 'pages#index'
  end
end
