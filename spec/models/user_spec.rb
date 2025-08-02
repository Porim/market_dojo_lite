require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:role) }
    it { should validate_presence_of(:company_name) }
    it { should validate_inclusion_of(:role).in_array(%w[buyer supplier]) }
  end

  describe 'associations' do
    it { should have_many(:rfqs).dependent(:destroy) }
    it { should have_many(:quotes).dependent(:destroy) }
    it { should have_many(:bids).dependent(:destroy) }
  end

  describe 'scopes' do
    let!(:buyer) { create(:user, role: 'buyer') }
    let!(:supplier) { create(:user, role: 'supplier') }

    it 'returns buyers' do
      expect(User.buyers).to include(buyer)
      expect(User.buyers).not_to include(supplier)
    end

    it 'returns suppliers' do
      expect(User.suppliers).to include(supplier)
      expect(User.suppliers).not_to include(buyer)
    end
  end

  describe '#buyer?' do
    it 'returns true for buyer role' do
      user = build(:user, role: 'buyer')
      expect(user.buyer?).to be true
    end

    it 'returns false for supplier role' do
      user = build(:user, role: 'supplier')
      expect(user.buyer?).to be false
    end
  end

  describe '#supplier?' do
    it 'returns true for supplier role' do
      user = build(:user, role: 'supplier')
      expect(user.supplier?).to be true
    end

    it 'returns false for buyer role' do
      user = build(:user, role: 'buyer')
      expect(user.supplier?).to be false
    end
  end
end