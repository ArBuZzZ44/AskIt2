class QuestionPolicy < ApplicationPolicy
  def create?
    false
  end

  def update?
  end

  def destroy?
  end

  def index?
    true
  end

  def show?
    true
  end
end