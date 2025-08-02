require 'rails_helper'

RSpec.describe Auction, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:end_time) }
    it { should validate_inclusion_of(:status).in_array(%w[pending active completed]) }
    it { should validate_numericality_of(:current_price).is_greater_than_or_equal_to(0).allow_nil }
  end

  describe 'associations' do
    it { should belong_to(:rfq) }
    it { should have_many(:bids).dependent(:destroy) }
  end

  describe 'scopes' do
    let!(:active_auction) { create(:auction, status: 'active', start_time: 1.hour.ago, end_time: 1.hour.from_now) }
    let!(:upcoming_auction) { create(:auction, status: 'pending', start_time: 1.hour.from_now, end_time: 2.hours.from_now) }
    let!(:completed_auction) { create(:auction, status: 'completed') }

    describe '.active' do
      it 'returns only active auctions within time range' do
        expect(Auction.active).to include(active_auction)
        expect(Auction.active).not_to include(upcoming_auction, completed_auction)
      end
    end

    describe '.upcoming' do
      it 'returns only pending auctions with future start time' do
        expect(Auction.upcoming).to include(upcoming_auction)
        expect(Auction.upcoming).not_to include(active_auction, completed_auction)
      end
    end

    describe '.completed' do
      it 'returns only completed auctions' do
        expect(Auction.completed).to include(completed_auction)
        expect(Auction.completed).not_to include(active_auction, upcoming_auction)
      end
    end
  end

  describe '#active?' do
    it 'returns true when status is active and within time range' do
      auction = build(:auction, status: 'active', start_time: 1.hour.ago, end_time: 1.hour.from_now)
      expect(auction.active?).to be true
    end

    it 'returns false when status is not active' do
      auction = build(:auction, status: 'pending', start_time: 1.hour.ago, end_time: 1.hour.from_now)
      expect(auction.active?).to be false
    end

    it 'returns false when outside time range' do
      auction = build(:auction, status: 'active', start_time: 2.hours.ago, end_time: 1.hour.ago)
      expect(auction.active?).to be false
    end
  end

  describe '#time_remaining' do
    it 'returns time remaining in seconds for active auction' do
      auction = create(:auction, status: 'active', start_time: 1.hour.ago, end_time: 30.minutes.from_now)
      expect(auction.time_remaining).to be_within(5).of(1800)
    end

    it 'returns 0 for inactive auction' do
      auction = create(:auction, status: 'completed')
      expect(auction.time_remaining).to eq(0)
    end
  end
end
