require 'rails_helper'

RSpec.describe "Documents", type: :request do
  let(:buyer) { create(:user, :buyer) }
  let(:supplier) { create(:user, :supplier) }
  let(:other_buyer) { create(:user, :buyer) }
  let(:rfq) { create(:rfq, user: buyer) }

  before do
    rfq.documents.attach(
      io: StringIO.new('PDF content'),
      filename: 'test.pdf',
      content_type: 'application/pdf'
    )
  end

  let(:document) { rfq.documents.first }

  describe "GET /documents/:signed_id" do
    context "as the RFQ owner" do
      before { sign_in buyer }

      it "allows download" do
        get document_path(document.signed_id, disposition: 'attachment')
        expect(response).to redirect_to(/rails\/active_storage\/blobs/)
      end
    end

    context "as a supplier with published RFQ" do
      before do
        rfq.update!(status: 'published')
        sign_in supplier
      end

      it "allows download" do
        get document_path(document.signed_id, disposition: 'attachment')
        expect(response).to redirect_to(/rails\/active_storage\/blobs/)
      end
    end

    context "as a supplier with draft RFQ" do
      before do
        rfq.update!(status: 'draft')
        sign_in supplier
      end

      it "denies access" do
        get document_path(document.signed_id, disposition: 'attachment')
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include('You are not authorized')
      end
    end

    context "as another buyer" do
      before { sign_in other_buyer }

      it "denies access" do
        get document_path(document.signed_id, disposition: 'attachment')
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include('You are not authorized')
      end
    end

    context "as a supplier who submitted a quote" do
      before do
        rfq.update!(status: 'draft')
        create(:quote, rfq: rfq, user: supplier)
        sign_in supplier
      end

      it "allows download" do
        get document_path(document.signed_id, disposition: 'attachment')
        expect(response).to redirect_to(/rails\/active_storage\/blobs/)
      end
    end

    context "when not authenticated" do
      it "redirects to sign in" do
        get document_path(document.signed_id, disposition: 'attachment')
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
