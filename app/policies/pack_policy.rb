class PackPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def open?
    user.present? && user.can_afford?(record.cost)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
