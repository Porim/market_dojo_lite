class RfqsController < ApplicationController
  before_action :set_rfq, only: [:show, :edit, :update, :destroy]
  before_action :require_buyer!, only: [:new, :create, :edit, :update, :destroy]

  def index
    @rfqs = if current_user.buyer?
              current_user.rfqs.includes(:quotes)
            else
              Rfq.published.includes(:quotes, :user)
            end
  end

  def show
    @quotes = @rfq.quotes.includes(:user).by_price
    @auction = @rfq.auction
  end

  def new
    @rfq = current_user.rfqs.build
  end

  def create
    @rfq = current_user.rfqs.build(rfq_params)

    if @rfq.save
      redirect_to @rfq, notice: 'RFQ was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @rfq.update(rfq_params)
      redirect_to @rfq, notice: 'RFQ was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @rfq.destroy
    redirect_to rfqs_url, notice: 'RFQ was successfully destroyed.'
  end

  private

  def set_rfq
    @rfq = if current_user.buyer?
             current_user.rfqs.find(params[:id])
           else
             Rfq.published.find(params[:id])
           end
  end

  def rfq_params
    params.require(:rfq).permit(:title, :description, :deadline, :status)
  end
end