class ExchangesController < ApplicationController
  before_action :require_authentication

  def index
    @card_sets = CardSet.joins(:cards)
                        .where(cards: { id: current_user.user_cards.select(:card_id) })
                        .distinct
                        .includes(:cards)

    @exchanges_by_set = {}
    @card_sets.each do |card_set|
      exchanges = SetExchange.active.for_card_set(card_set.id)
      @exchanges_by_set[card_set] = exchanges if exchanges.any?
    end
  end

  def show
    @card_set = CardSet.includes(cards: :user_cards).find(params[:id])
    @exchanges = SetExchange.active.for_card_set(@card_set.id)
    @user_eligible_cards = current_user.user_cards.joins(:card).where(card_set_id: @card_set.id)
  end

  def redeem
    @exchange = SetExchange.active.find(params[:id])

    result = @exchange.redeem_for!(current_user)

    if result
      redirect_to exchanges_path, notice: "Successfully exchanged cards! You received #{result.card.name} (#{result.card.overall_rating})."
    else
      redirect_to exchanges_path, alert: "You don't have enough eligible cards for this exchange."
    end
  end
end
