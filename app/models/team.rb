class Team < ApplicationRecord
  belongs_to :user

  has_many :league_memberships, dependent: :destroy
  has_many :leagues, through: :league_memberships
  has_many :home_matches, class_name: "Match", foreign_key: :home_team_id, dependent: :destroy
  has_many :away_matches, class_name: "Match", foreign_key: :away_team_id, dependent: :destroy
  has_many :lineups, dependent: :destroy

  validates :name, presence: true, length: { maximum: 50 }

  def matches
    Match.where("home_team_id = ? OR away_team_id = ?", id, id)
  end

  def win_rate
    total = wins + losses
    return 0.0 if total.zero?
    (wins.to_f / total * 100).round(1)
  end

  def update_record(won:)
    if won
      increment!(:wins)
    else
      increment!(:losses)
    end
    update_rating(won)
  end

  def active_league
    league_memberships.joins(:league).where(leagues: { status: "active" }).first&.league
  end

  def starters
    user.user_cards.starters
  end

  private

  def update_rating(won)
    k_factor = 32
    change = won ? k_factor : -k_factor
    new_rating = [rating + change, 100].max
    update!(rating: new_rating)
  end
end
