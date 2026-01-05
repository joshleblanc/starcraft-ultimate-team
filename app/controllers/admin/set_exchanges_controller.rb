class Admin::SetExchangesController < ApplicationController
  before_action :require_admin
  before_action :set_set_exchange, only: %i[edit update destroy show]

  def index
    @set_exchanges = SetExchange.includes(:card_set).all.order(created_at: :desc)
  end

  def show
    @slots = @set_exchange.exchange_slots.includes(:exchange_qualifications)
  end

  def new
    @set_exchange = SetExchange.new
    @set_exchange.exchange_slots.build
  end

  def create
    @set_exchange = SetExchange.new(set_exchange_params)

    if @set_exchange.save
      redirect_to admin_set_exchanges_path, notice: "Exchange was successfully created."
    else
      build_default_slot if @set_exchange.exchange_slots.empty?
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @slots = @set_exchange.exchange_slots.includes(:exchange_qualifications)
  end

  def update
    if @set_exchange.update(set_exchange_params)
      redirect_to admin_set_exchanges_path, notice: "Exchange was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @set_exchange.destroy!
    redirect_to admin_set_exchanges_path, notice: "Exchange was successfully deleted."
  end

  def add_slot
    @set_exchange = SetExchange.find(params[:set_exchange_id])
    max_position = @set_exchange.exchange_slots.maximum(:position) || 0
    @slot = @set_exchange.exchange_slots.create!(position: max_position + 1)
    redirect_to edit_admin_set_exchange_path(@set_exchange), notice: "Slot added."
  end

  def remove_slot
    @set_exchange = SetExchange.find(params[:set_exchange_id])
    @slot = @set_exchange.exchange_slots.find_by(position: params[:position])
    @slot&.destroy!
    redirect_to edit_admin_set_exchange_path(@set_exchange), notice: "Slot removed."
  end

  def add_qualification
    @slot = ExchangeSlot.find(params[:slot_id])
    @slot.exchange_qualifications.create!(qualification_type: "rating_range")
    redirect_to edit_admin_set_exchange_path(@slot.set_exchange), notice: "Qualification added."
  end

  def update_qualification
    @qualification = ExchangeQualification.find(params[:id])
    if @qualification.update(qualification_params)
      redirect_to edit_admin_set_exchange_path(@qualification.exchange_slot.set_exchange), notice: "Qualification updated."
    else
      redirect_to edit_admin_set_exchange_path(@qualification.exchange_slot.set_exchange), alert: "Invalid qualification."
    end
  end

  def remove_qualification
    @qualification = ExchangeQualification.find(params[:id])
    @set_exchange = @qualification.exchange_slot.set_exchange
    @qualification.destroy!
    redirect_to edit_admin_set_exchange_path(@set_exchange), notice: "Qualification removed."
  end

  private

  def require_admin
    return if current_user.admin?

    redirect_to root_path, alert: "You are not authorized to access this page."
  end

  def set_set_exchange
    @set_exchange = SetExchange.find(params[:id])
  end

  def set_exchange_params
    params.require(:set_exchange).permit(
      :card_set_id, :name, :description, :active,
      :output_min_rating, :output_max_rating, :output_count,
      exchange_slots_attributes: [ :id, :position, :_destroy ]
    )
  end

  def qualification_params
    params.require(:exchange_qualification).permit(
      :qualification_type, :card_id, :card_set_id, :min_rating, :max_rating
    )
  end

  def build_default_slot
    @set_exchange.exchange_slots.build(position: 1)
  end
end
