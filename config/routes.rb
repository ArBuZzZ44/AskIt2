# frozen_string_literal: true

Rails.application.routes.draw do
  # для входа в пользователя в систему, destroy, чтобы пользователь мог выходить
  resource :session, only: %i[new create destroy]

  resources :users, only: %i[new create edit update]

  resources :questions do
    resources :answers, except: %i[new show] # except - кроме, т.е. исключаем ненужные маршруты
  end

  root 'pages#index'
end
