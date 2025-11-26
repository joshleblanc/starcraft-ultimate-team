class NotificationPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def mark_as_read?
    owner?
  end

  def mark_all_as_read?
    user.present?
  end

  private

  def owner?
    user.present? && record.recipient_id == user.id && record.recipient_type == "User"
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user
        scope.where(recipient: user)
      else
        scope.none
      end
    end
  end
end
