class LeagueStartedNotification < ApplicationNotifier
  deliver_by :database

  required_param :league

  notification_methods do
    def message
      league = params[:league]
      "🏟️ #{league.name} has started! Check your matches."
    end

    def url
      Rails.application.routes.url_helpers.league_path(params[:league])
    end

    def icon
      "🏟️"
    end
  end
end
