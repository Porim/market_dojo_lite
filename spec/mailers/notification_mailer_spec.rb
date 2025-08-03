require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  describe "rfq_created" do
    let(:buyer) { create(:user, :buyer) }
    let(:supplier) { create(:user, :supplier) }
    let(:rfq) { create(:rfq, user: buyer) }
    let(:mail) { NotificationMailer.rfq_created(rfq, supplier) }

    it "renders the headers" do
      expect(mail.subject).to eq("New RFQ: #{rfq.title}")
      expect(mail.to).to eq([ supplier.email ])
      expect(mail.from).to eq([ "from@example.com" ])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(rfq.title)
      expect(mail.body.encoded).to match(buyer.company_name)
      expect(mail.body.encoded).to match(supplier.name)
    end
  end

  describe "quote_received" do
    let(:buyer) { create(:user, :buyer) }
    let(:supplier) { create(:user, :supplier) }
    let(:rfq) { create(:rfq, user: buyer) }
    let(:quote) { create(:quote, rfq: rfq, user: supplier) }
    let(:mail) { NotificationMailer.quote_received(quote) }

    it "renders the headers" do
      expect(mail.subject).to eq("New quote received for: #{rfq.title}")
      expect(mail.to).to eq([ buyer.email ])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(rfq.title)
      expect(mail.body.encoded).to match(Regexp.escape(ERB::Util.html_escape(supplier.company_name)))
      expect(mail.body.encoded).to match("£")
    end
  end

  describe "auction_started" do
    let(:rfq) { create(:rfq) }
    let(:auction) { create(:auction, rfq: rfq) }
    let(:participant) { create(:user, :supplier) }
    let(:mail) { NotificationMailer.auction_started(auction, participant) }

    it "renders the headers" do
      expect(mail.subject).to eq("Auction started: #{rfq.title}")
      expect(mail.to).to eq([ participant.email ])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(rfq.title)
      expect(mail.body.encoded).to match("Live Auction Started")
    end
  end
end
