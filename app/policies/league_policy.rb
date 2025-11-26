class LeaguePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.present?
  end

  def join?
    return false unless user.present?
    return false if record.full?
    return false unless record.status == "pending"
    return false unless user.active_team.present?
    
    # Check if user's team is already in the league
    !record.teams.include?(user.active_team)
  end

  def start?
    return false unless user.present?
    return false unless record.can_start?
    
    # Only league creator or member can start
    record.teams.any? { |t| t.user_id == user.id }
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
