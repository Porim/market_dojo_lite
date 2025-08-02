class DashboardController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]

  def index
    if user_signed_in?
      if current_user.buyer?
        @rfqs = current_user.rfqs.includes(:quotes)
        @active_auctions = Auction.active.includes(:rfq)
      else
        @active_rfqs = Rfq.active.includes(:quotes)
        @my_quotes = current_user.quotes.includes(:rfq)
        @active_auctions = Auction.active.includes(:rfq, :bids)
      end
    end
  end
end
