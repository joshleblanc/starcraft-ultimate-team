class UserCardPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def update?
    owner?
  end

  def set_starter?
    owner?
  end

  def remove_starter?
    owner?
  end

  private

  def owner?
    user.present? && record.user_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user
        scope.where(user: user)
      else
        scope.none
      end
    end
  end
end
