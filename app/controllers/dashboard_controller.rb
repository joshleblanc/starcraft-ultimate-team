class DashboardController < ApplicationController
  def show
    @user = current_user
    @team = @user.active_team
    @starters = @user.starters.limit(5)
    @recent_matches = @team&.matches&.order(created_at: :desc)&.limit(5) || []
    @active_league = @team&.active_league
    @notifications = @user.notifications.recent.limit(5)
  end
end
