import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["timer", "currentPrice", "bidHistory"]
  
  connect() {
    this.setupTimer()
    this.setupActionCable()
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
    if (this.timer) {
      clearInterval(this.timer)
    }
  }

  setupTimer() {
    const endTime = new Date(this.data.get("endTime"))
    
    this.timer = setInterval(() => {
      const now = new Date()
      const diff = endTime - now
      
      if (diff <= 0) {
        this.timerTarget.textContent = "Auction Ended"
        clearInterval(this.timer)
      } else {
        const minutes = Math.floor(diff / 60000)
        const seconds = Math.floor((diff % 60000) / 1000)
        this.timerTarget.textContent = `${minutes}m ${seconds}s`
      }
    }, 1000)
  }

  setupActionCable() {
    const auctionId = this.data.get("id")
    if (!auctionId) return

    const consumer = createConsumer()
    this.subscription = consumer.subscriptions.create(
      { channel: "AuctionChannel", auction_id: auctionId },
      {
        received: (data) => {
          if (data.action === "new_bid") {
            // Update the page with Turbo Stream or manually update DOM
            if (data.html) {
              // If server sends HTML, update the bid history
              if (this.hasBidHistoryTarget) {
                this.bidHistoryTarget.innerHTML = data.html
              }
            }
            // Update current price if available
            if (data.current_price && this.hasCurrentPriceTarget) {
              this.currentPriceTarget.textContent = `£${data.current_price}`
            }
          }
        }
      }
    )
  }
}