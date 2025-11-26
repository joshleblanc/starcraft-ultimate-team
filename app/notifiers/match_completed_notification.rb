class MatchCompletedNotification < ApplicationNotifier
  deliver_by :database

  required_param :match

  notification_methods do
    def message
      match = params[:match]
      winner = match.winner_team
      
      if recipient.teams.include?(winner)
        "🏆 Victory! You won your match #{match.home_score}-#{match.away_score}!"
      else
        "Match completed. You lost #{match.home_score}-#{match.away_score}. Better luck next time!"
      end
    end

    def url
      Rails.application.routes.url_helpers.match_path(params[:match])
    end

    def icon
      match = params[:match]
      winner = match.winner_team
      recipient.teams.include?(winner) ? "🏆" : "⚔️"
    end
  end
end
