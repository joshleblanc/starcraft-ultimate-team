class PackOpenedNotification < ApplicationNotifier
  deliver_by :database

  required_param :pack
  required_param :cards

  notification_methods do
    def message
      cards = params[:cards]
      legendary_count = cards.count { |c| c.rarity == "legendary" }
      epic_count = cards.count { |c| c.rarity == "epic" }
      
      if legendary_count > 0
        "🌟 LEGENDARY! You pulled #{legendary_count} legendary card(s)!"
      elsif epic_count > 0
        "💜 Nice! You pulled #{epic_count} epic card(s)!"
      else
        "📦 Pack opened! You received #{cards.count} new cards."
      end
    end

    def url
      Rails.application.routes.url_helpers.cards_path
    end

    def icon
      cards = params[:cards]
      if cards.any? { |c| c.rarity == "legendary" }
        "🌟"
      elsif cards.any? { |c| c.rarity == "epic" }
        "💜"
      else
        "📦"
      end
    end
  end
end
