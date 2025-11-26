class MatchPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def submit_lineup?
    return false unless user.present?
    return false unless record.status == "pending" || record.status == "lineup_submitted"
    
    participant?
  end

  def simulate?
    return false unless user.present?
    return false unless record.can_simulate? || record.status == "in_progress"
    
    participant?
  end

  private

  def participant?
    team = user.active_team
    return false unless team
    
    record.home_team_id == team.id || record.away_team_id == team.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
