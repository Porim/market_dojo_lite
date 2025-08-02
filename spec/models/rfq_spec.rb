require 'rails_helper'

RSpec.describe Rfq, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:deadline) }
    it { should validate_inclusion_of(:status).in_array(%w[draft published closed]) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:quotes).dependent(:destroy) }
    it { should have_one(:auction).dependent(:destroy) }
  end

  describe 'scopes' do
    let!(:published_rfq) { create(:rfq, status: 'published') }
    let!(:draft_rfq) { create(:rfq, status: 'draft') }
    let!(:active_rfq) { create(:rfq, status: 'published', deadline: 1.week.from_now) }
    let!(:expired_rfq) { create(:rfq, status: 'published', deadline: 1.week.ago) }

    describe '.published' do
      it 'returns only published RFQs' do
        expect(Rfq.published).to include(published_rfq, active_rfq, expired_rfq)
        expect(Rfq.published).not_to include(draft_rfq)
      end
    end

    describe '.active' do
      it 'returns only published RFQs with future deadlines' do
        expect(Rfq.active).to include(active_rfq)
        expect(Rfq.active).not_to include(draft_rfq, expired_rfq)
      end
    end
  end

  describe 'callbacks' do
    describe '#set_default_status' do
      it 'sets status to draft by default' do
        rfq = build(:rfq, status: nil)
        rfq.valid?
        expect(rfq.status).to eq('draft')
      end

      it 'does not override provided status' do
        rfq = build(:rfq, status: 'published')
        rfq.valid?
        expect(rfq.status).to eq('published')
      end
    end
  end
end