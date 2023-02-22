module Authentication
  extend ActiveSupport::Concern

  included do 

  private
  
  def current_user
    if session[:user_id].present?
      @current_user ||= User.find_by(id: session[:user_id]).decorate # задекорировали, теперь метод можем использовать
    elsif cookies.encrypted[:user_id].present? # если в сессии ничего нет, проверяем не запоминали ли мы этого юзера раньше
      user = User.find_by(id: cookies.encrypted[:user_id])
      if user&.remember_token_authenticated?(cookies.encrypted[:remember_token])
        sign_in user
        @current_user ||= user.decorate
      end
    end
  end

  def user_signed_in?
    current_user.present?
  end

  def require_no_authentication
    return if !user_signed_in?

    flash[:warning] = "You already signed in!"
    redirect_to root_path
  end

  def require_authentication
    return if user_signed_in?

    flash[:warning] = "You are not signed in!"
    redirect_to root_path
  end

  def sign_in(user)
    session[:user_id] = user.id
  end


  def remember(user) # метод из модели User
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
end