class Admin::CardSetsController < ApplicationController
  before_action :require_admin
  before_action :set_card_set, only: %i[edit update destroy show]

  def index
    @card_sets = CardSet.all.order(created_at: :desc)
  end

  def show
    @cards = @card_set.cards.order(created_at: :desc)
  end

  def new
    @card_set = CardSet.new
  end

  def create
    @card_set = CardSet.new(card_set_params)

    if @card_set.save
      redirect_to admin_card_sets_path, notice: "Card set was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @card_set.update(card_set_params)
      redirect_to admin_card_sets_path, notice: "Card set was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @card_set.destroy!
    redirect_to admin_card_sets_path, notice: "Card set was successfully deleted."
  end

  private

  def require_admin
    return if current_user.admin?

    redirect_to root_path, alert: "You are not authorized to access this page."
  end

  def set_card_set
    @card_set = CardSet.find(params[:id])
  end

  def card_set_params
    params.require(:card_set).permit(:name, :description)
  end
end
