class QuotesController < ApplicationController
  before_action :require_supplier!
  before_action :set_rfq

  def new
    @quote = @rfq.quotes.build(user: current_user)
  end

  def create
    @quote = @rfq.quotes.build(quote_params)
    @quote.user = current_user

    if @quote.save
      # Send email notification to buyer
      if @rfq.user.email_preference&.quote_received?
        NotificationMailer.quote_received(@quote).deliver_later
      end
      redirect_to @rfq, notice: "Quote was successfully submitted."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_rfq
    @rfq = Rfq.published.find(params[:rfq_id])
  end

  def quote_params
    params.require(:quote).permit(:price, :notes)
  end
end
