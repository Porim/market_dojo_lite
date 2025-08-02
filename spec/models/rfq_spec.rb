require 'rails_helper'

RSpec.describe Rfq, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:deadline) }
    it { should validate_inclusion_of(:status).in_array(%w[draft published closed]) }

    it 'validates presence of status' do
      rfq = build(:rfq)
      rfq.status = ''
      expect(rfq).not_to be_valid
      expect(rfq.errors[:status]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:quotes).dependent(:destroy) }
    it { should have_one(:auction).dependent(:destroy) }
    it { should have_many_attached(:documents) }
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

  describe 'document attachments' do
    let(:rfq) { create(:rfq) }

    context 'when attaching valid documents' do
      it 'accepts PDF files' do
        rfq.documents.attach(
          io: StringIO.new('PDF content'),
          filename: 'test.pdf',
          content_type: 'application/pdf'
        )
        expect(rfq).to be_valid
      end

      it 'accepts Word documents' do
        rfq.documents.attach(
          io: StringIO.new('DOC content'),
          filename: 'test.docx',
          content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        )
        expect(rfq).to be_valid
      end

      it 'accepts Excel spreadsheets' do
        rfq.documents.attach(
          io: StringIO.new('XLS content'),
          filename: 'test.xlsx',
          content_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        )
        expect(rfq).to be_valid
      end
    end

    context 'when attaching invalid documents' do
      it 'rejects files with invalid content types' do
        rfq.documents.attach(
          io: StringIO.new('EXE content'),
          filename: 'malicious.exe',
          content_type: 'application/x-msdownload'
        )
        expect(rfq).not_to be_valid
        expect(rfq.errors[:documents]).to include('must be PDF, DOC, DOCX, XLS, or XLSX')
      end

      it 'rejects files larger than 10MB' do
        large_content = 'x' * (11.megabytes)
        rfq.documents.attach(
          io: StringIO.new(large_content),
          filename: 'large.pdf',
          content_type: 'application/pdf'
        )
        expect(rfq).not_to be_valid
        expect(rfq.errors[:documents].first).to match(/is too large/)
      end
    end

    it 'can attach multiple documents' do
      rfq.documents.attach([
        { io: StringIO.new('PDF 1'), filename: 'doc1.pdf', content_type: 'application/pdf' },
        { io: StringIO.new('PDF 2'), filename: 'doc2.pdf', content_type: 'application/pdf' }
      ])
      expect(rfq.documents.count).to eq(2)
      expect(rfq).to be_valid
    end
  end
end
