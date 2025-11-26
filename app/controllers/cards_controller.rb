class CardsController < ApplicationController
  def index
    @user_cards = policy_scope(current_user.user_cards).joins(:card).order(Arel.sql("CASE cards.rarity WHEN 'legendary' THEN 4 WHEN 'epic' THEN 3 WHEN 'rare' THEN 2 ELSE 1 END DESC, cards.overall_rating DESC"))
    @starters = @user_cards.starters
    @bench = @user_cards.bench
  end

  def show
    @user_card = current_user.user_cards.includes(:card).find(params[:id])
    authorize @user_card.card
  end

  def set_starter
    @user_card = current_user.user_cards.find(params[:id])
    authorize @user_card

    position = params[:position].to_i

    # Remove any existing card in this position
    current_user.user_cards.where(is_starter: true, position: position).update_all(is_starter: false, position: nil)

    @user_card.update!(is_starter: true, position: position)

    respond_to do |format|
      format.html { redirect_to cards_path, notice: "#{@user_card.name} set as starter in position #{position}." }
      format.turbo_stream
    end
  end

  def remove_starter
    @user_card = current_user.user_cards.find(params[:id])
    authorize @user_card

    @user_card.update!(is_starter: false, position: nil)

    respond_to do |format|
      format.html { redirect_to cards_path, notice: "#{@user_card.name} moved to bench." }
      format.turbo_stream
    end
  end

  private

  def policy_scope(scope)
    UserCardPolicy::Scope.new(current_user, scope).resolve
  end
end
