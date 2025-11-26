class ApplicationNotifier < Noticed::Event
  deliver_by :database

  notification_methods do
    def message
      raise NotImplementedError
    end

    def url
      nil
    end

    def icon
      "🔔"
    end
  end
end
