class PacksController < ApplicationController
  def index
    @packs = Pack.all
  end

  def show
    @pack = Pack.find(params[:id])
    authorize @pack
  end

  def open
    @pack = Pack.find(params[:id])
    authorize @pack

    result = @pack.open_for(current_user)

    if result
      @cards = result[:cards]
      
      # Send notification
      PackOpenedNotification.with(pack: @pack, cards: @cards.map(&:card)).deliver(current_user)

      respond_to do |format|
        format.html { redirect_to pack_opening_path(@pack), notice: "Pack opened! You received #{@cards.count} cards." }
        format.turbo_stream
      end
    else
      redirect_to packs_path, alert: "Not enough credits to open this pack."
    end
  end

  def opening
    @pack = Pack.find(params[:id])
    @recent_cards = current_user.user_cards.includes(:card).order(created_at: :desc).limit(@pack.card_count)
  end
end
