class PackOpening < ApplicationRecord
  belongs_to :user
  belongs_to :pack

  validates :opened_at, presence: true

  scope :recent, -> { order(opened_at: :desc) }
end
