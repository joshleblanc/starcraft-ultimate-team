class Admin::SetExchangesController < ApplicationController
  before_action :require_admin
  before_action :set_set_exchange, only: %i[edit update destroy show]

  def index
    @set_exchanges = SetExchange.includes(:card_set).all.order(created_at: :desc)
  end

  def show
    @cards = @set_exchange.card_set.cards
  end

  def new
    @set_exchange = SetExchange.new
  end

  def create
    @set_exchange = SetExchange.new(set_exchange_params)

    if @set_exchange.save
      redirect_to admin_set_exchanges_path, notice: "Exchange was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
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
      :input_min_rating, :input_max_rating, :input_count,
      :output_min_rating, :output_max_rating, :output_count
    )
  end
end
