class UserPolicy < ApplicationPolicy
  def create?
    user.guest?
  end

  def update?
    record == user # текущий пользователь равер тому юзеру, которого нужно отредактировать
  end

  def index?
    false
  end

  def show?
    true
  end

  def destroy?
    false
  end
end