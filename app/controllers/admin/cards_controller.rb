class Admin::CardsController < ApplicationController
  before_action :require_admin

  def index
    @cards = Card.all.order(created_at: :desc)
  end

  def new
    @card = Card.new(card_set_id: params[:card_set_id])
  end

  def create
    @card = Card.new(card_params)

    if @card.save
      if @card.card_set_id
        redirect_to admin_card_set_path(@card.card_set_id), notice: "Card was successfully created."
      else
        redirect_to admin_cards_path, notice: "Card was successfully created."
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def require_admin
    return if current_user.admin?

    redirect_to root_path, alert: "You are not authorized to access this page."
  end

  def card_params
    params.require(:card).permit(
      :name, :race, :player_role, :card_set_id,
      :macro, :micro, :starsense, :poise, :speed,
      :early_game, :mid_game, :late_game
    )
  end
end
