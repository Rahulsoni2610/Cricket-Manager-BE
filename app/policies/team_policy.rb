class TeamPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.user == user
  end

  def create?
    true
  end

  def update?
    record.user == user
  end

  def destroy?
    record.user == user
  end

  class Scope < Scope
    def resolve
      scope.where(user: user)
    end
  end
end
