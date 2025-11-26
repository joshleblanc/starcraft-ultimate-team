class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications.order(created_at: :desc).limit(50)
    authorize Notification
  end

  def mark_as_read
    @notification = current_user.notifications.find(params[:id])
    authorize @notification

    @notification.mark_as_read!

    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path) }
      format.turbo_stream
    end
  end

  def mark_all_as_read
    authorize Notification

    current_user.notifications.unread.update_all(read_at: Time.current)

    respond_to do |format|
      format.html { redirect_to notifications_path, notice: "All notifications marked as read." }
      format.turbo_stream
    end
  end
end
