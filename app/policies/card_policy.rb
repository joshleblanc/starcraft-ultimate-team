class CardPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    false # Only system can create cards
  end

  def update?
    false
  end

  def destroy?
    false
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
