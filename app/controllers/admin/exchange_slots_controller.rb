class Admin::ExchangeSlotsController < ApplicationController
  before_action :require_admin
  before_action :set_exchange

  def new
    @slot = @exchange.exchange_slots.new
    @slot.exchange_qualifications.new(qualification_type: "rating_range")
  end

  def create
    max_position = @exchange.exchange_slots.maximum(:position) || 0
    @slot = @exchange.exchange_slots.new(position: max_position + 1)

    if @slot.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_set_exchange_path(@exchange), notice: "Slot added." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @slot = @exchange.exchange_slots.find(params[:id])
  end

  def update
    @slot = @exchange.exchange_slots.find(params[:id])

    if @slot.update(slot_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_set_exchange_path(@exchange), notice: "Slot updated." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @slot = @exchange.exchange_slots.find(params[:id])
    @slot.destroy!
    redirect_to admin_set_exchange_path(@exchange), notice: "Slot removed."
  end

  private

  def require_admin
    return if current_user.admin?
    redirect_to root_path, alert: "Not authorized."
  end

  def set_exchange
    @exchange = SetExchange.find(params[:set_exchange_id])
  end

  def slot_params
    params.require(:exchange_slot).permit(
      :position,
      exchange_qualifications_attributes: [ :id, :qualification_type, :card_id, :card_set_id, :min_rating, :max_rating, :_destroy ]
    )
  end
end
