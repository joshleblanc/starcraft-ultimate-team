class Lineup < ApplicationRecord
  belongs_to :match
  belongs_to :team

  has_many :lineup_slots, -> { order(:position) }, dependent: :destroy

  validates :team_id, uniqueness: { scope: :match_id }

  def complete?
    lineup_slots.count == 5
  end

  def submit!
    return false unless complete?
    
    update!(submitted: true)
    
    # Check if both teams have submitted
    if match.both_lineups_submitted?
      match.update!(status: "lineup_submitted")
    end
    
    true
  end

  def players
    lineup_slots.includes(user_card: :card).map(&:user_card)
  end

  def set_player(position:, user_card:)
    slot = lineup_slots.find_or_initialize_by(position: position)
    slot.update!(user_card: user_card)
    slot
  end

  def clear!
    lineup_slots.destroy_all
    update!(submitted: false)
  end
end
