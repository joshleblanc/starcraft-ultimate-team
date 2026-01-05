class PackOpenedNotification < ApplicationNotifier
  deliver_by :database

  required_param :pack
  required_param :cards

  notification_methods do
    def message
      "📦 Pack opened! You received #{cards.count} new cards."
    end

    def url
      Rails.application.routes.url_helpers.cards_path
    end

    def icon
      cards = params[:cards]
      "📦"
    end
  end
end
