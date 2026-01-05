class Admin::ExchangeQualificationsController < ApplicationController
  before_action :require_admin
  before_action :set_slot

  def new
    @qualification = @slot.exchange_qualifications.new(qualification_type: "rating_range")
  end

  def create
    @qualification = @slot.exchange_qualifications.new(qualification_params)

    if @qualification.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_set_exchange_path(@slot.set_exchange), notice: "Qualification added." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @qualification = @slot.exchange_qualifications.find(params[:id])
    @exchange = @slot.set_exchange
  end

  def update
    @qualification = @slot.exchange_qualifications.find(params[:id])

    if @qualification.update(qualification_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_set_exchange_path(@slot.set_exchange), notice: "Qualification updated." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @qualification = @slot.exchange_qualifications.find(params[:id])
    @qualification.destroy!
    redirect_to admin_set_exchange_path(@slot.set_exchange), notice: "Qualification removed."
  end

  private

  def require_admin
    return if current_user.admin?
    redirect_to root_path, alert: "Not authorized."
  end

  def set_slot
    @slot = ExchangeSlot.find(params[:exchange_slot_id])
  end

  def qualification_params
    params.require(:exchange_qualification).permit(
      :qualification_type, :card_id, :card_set_id, :min_rating, :max_rating
    )
  end
end
