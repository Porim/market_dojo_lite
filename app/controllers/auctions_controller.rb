class AuctionsController < ApplicationController
  before_action :set_rfq, only: [ :show, :create ]
  before_action :require_buyer!, only: [ :create ]

  def index
    @auctions = Auction.includes(:rfq).order(created_at: :desc)
  end

  def show
    @auction = @rfq.auction

    if @auction.nil?
      redirect_to @rfq, alert: "No auction has been created for this RFQ yet."
      return
    end

    @bids = @auction.bids.includes(:user).order(created_at: :desc)
  end

  def create
    @auction = @rfq.build_auction(auction_params)
    @auction.status = "active"

    if @auction.save
      redirect_to rfq_auction_path(@rfq), notice: "Auction was successfully created."
    else
      redirect_to @rfq, alert: "Failed to create auction."
    end
  end

  def bid
    Rails.logger.debug "Bid params: #{params.inspect}"
    @auction = Auction.find(params[:id])
    @bid = @auction.bids.build(bid_params)
    @bid.user = current_user

    if @bid.save
      redirect_to rfq_auction_path(@auction.rfq), notice: "Bid placed successfully."
    else
      redirect_to rfq_auction_path(@auction.rfq), alert: @bid.errors.full_messages.join(", ")
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to auctions_path, alert: "Auction not found."
  end

  private

  def set_rfq
    @rfq = Rfq.find(params[:rfq_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to rfqs_path, alert: "RFQ not found."
  end

  def auction_params
    params.require(:auction).permit(:start_time, :end_time, :current_price)
  end

  def bid_params
    params.require(:bid).permit(:amount)
  end
end
