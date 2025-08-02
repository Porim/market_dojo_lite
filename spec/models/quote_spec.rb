require 'rails_helper'

RSpec.describe Quote, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than(0) }

    describe 'uniqueness validation' do
      let(:rfq) { create(:rfq) }
      let(:user) { create(:user, role: 'supplier') }
      let!(:existing_quote) { create(:quote, rfq: rfq, user: user) }

      it 'prevents duplicate quotes from same user for same RFQ' do
        duplicate_quote = build(:quote, rfq: rfq, user: user)
        expect(duplicate_quote).not_to be_valid
        expect(duplicate_quote.errors[:user_id]).to include("has already submitted a quote for this RFQ")
      end

      it 'allows quotes from different users for same RFQ' do
        other_user = create(:user, role: 'supplier')
        new_quote = build(:quote, rfq: rfq, user: other_user)
        expect(new_quote).to be_valid
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:rfq) }
    it { should belong_to(:user) }
  end

  describe 'scopes' do
    let!(:quote1) { create(:quote, price: 1000) }
    let!(:quote2) { create(:quote, price: 500) }
    let!(:quote3) { create(:quote, price: 750) }

    describe '.by_price' do
      it 'orders quotes by price ascending' do
        expect(Quote.by_price).to eq([ quote2, quote3, quote1 ])
      end
    end
  end
end
