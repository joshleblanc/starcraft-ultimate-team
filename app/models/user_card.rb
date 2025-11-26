class UserCard < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :team, optional: true
  belongs_to :card

  has_many :lineup_slots, dependent: :destroy
  has_many :home_games, class_name: "Game", foreign_key: :home_player_id, dependent: :nullify
  has_many :away_games, class_name: "Game", foreign_key: :away_player_id, dependent: :nullify

  scope :starters, -> { where(is_starter: true).order(:position) }
  scope :bench, -> { where(is_starter: false) }

  validates :position, numericality: { in: 1..5 }, allow_nil: true
  validate :has_owner

  def has_owner
    errors.add(:base, "Must belong to a user or team") unless user_id.present? || team_id.present?
  end

  delegate :name, :race, :rarity, :macro, :micro, :starsense, :poise, :speed,
           :early_game, :mid_game, :late_game, :overall_rating, :effective_stats_for_phase,
           :rarity_color, :race_icon, to: :card

  def games
    Game.where("home_player_id = ? OR away_player_id = ?", id, id)
  end
end
