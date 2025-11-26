class LineupPolicy < ApplicationPolicy
  def show?
    true
  end

  def update?
    return false unless user.present?
    return false if record.submitted?
    
    record.team.user_id == user.id
  end

  def submit?
    return false unless user.present?
    return false if record.submitted?
    return false unless record.complete?
    
    record.team.user_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
