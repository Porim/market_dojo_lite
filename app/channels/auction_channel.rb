class AuctionChannel < ApplicationCable::Channel
  def subscribed
    auction = Auction.find(params[:auction_id])
    stream_from "auction_#{auction.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
