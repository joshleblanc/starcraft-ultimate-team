class Admin::SetExchangesController < ApplicationController
  before_action :require_admin
  before_action :set_set_exchange, only: %i[show edit update destroy]

  def index
    @set_exchanges = SetExchange.includes(:card_set).all.order(created_at: :desc)
  end

  def show
    @slots = @set_exchange.exchange_slots.includes(:exchange_qualifications).order(:position)
  end

  def new
    @set_exchange = SetExchange.new
  end

  def create
    @set_exchange = SetExchange.new(set_exchange_params)

    if @set_exchange.save
      redirect_to admin_set_exchange_path(@set_exchange), notice: "Exchange created. Add slots and qualifications."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @slots = @set_exchange.exchange_slots.includes(:exchange_qualifications).order(:position)
  end

  def update
    if @set_exchange.update(set_exchange_params)
      redirect_to admin_set_exchange_path(@set_exchange), notice: "Exchange updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @set_exchange.destroy!
    redirect_to admin_set_exchanges_path, notice: "Exchange deleted."
  end

  private

  def require_admin
    return if current_user.admin?
    redirect_to root_path, alert: "Not authorized."
  end

  def set_set_exchange
    @set_exchange = SetExchange.find(params[:id])
  end

  def set_exchange_params
    params.require(:set_exchange).permit(
      :card_set_id, :name, :description, :active,
      :output_min_rating, :output_max_rating, :output_count
    )
  end
end
