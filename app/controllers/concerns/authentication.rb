# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength
  included do
    private

    def current_user
      user = session[:user_id].present? ? user_from_session : user_from_token

      # амперсант на случай, если юзер в систему не вошел, чтобы не было nil
      @current_user ||= user&.decorate
    end

    def user_from_session
      User.find_by(id: session[:user_id])
    end

    def user_from_token
      user = User.find_by(id: cookies.encrypted[:user_id])
      token = cookies.encrypted[:remember_token]

      return unless user&.remember_token_authenticated?(token)

      sign_in user
      user
    end

    def user_signed_in?
      current_user.present?
    end

    def require_no_authentication
      return unless user_signed_in?

      flash[:warning] = 'You already signed in!'
      redirect_to root_path
    end

    def require_authentication
      return if user_signed_in?

      flash[:warning] = 'You are not signed in!'
      redirect_to root_path
    end

    def sign_in(user)
      session[:user_id] = user.id
    end

    # метод из модели User
    def remember(user)
      user.remember_me
      # encrypted для шифрования куки, permanent для долгого запоминания
      cookies.encrypted.permanent[:remember_token] = user.remember_token
      cookies.encrypted.permanent[:user_id] = user.id
    end

    def forget(user)
      user.forget_me
      cookies.delete :user_id # удаляем значения из куки
      cookies.delete :remember_token
    end

    def sign_out
      forget current_user
      session.delete :user_id
    end

    helper_method :current_user, :user_signed_in? # делаем хелперы из методов, чтобы они были доступны в представлениях
  end
  # rubocop:enable Metrics/BlockLength
end
