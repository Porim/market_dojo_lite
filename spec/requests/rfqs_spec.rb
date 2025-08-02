require 'rails_helper'

RSpec.describe "Rfqs", type: :request do
  let(:buyer) { create(:user, :buyer) }
  let(:supplier) { create(:user, :supplier) }

  describe "GET /rfqs" do
    context "as a buyer" do
      before { sign_in buyer }

      it "shows only buyer's RFQs" do
        buyer_rfq = create(:rfq, user: buyer)
        other_rfq = create(:rfq, :published)

        get rfqs_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include(buyer_rfq.title)
        expect(response.body).not_to include(other_rfq.title)
      end
    end

    context "as a supplier" do
      before { sign_in supplier }

      it "shows only published RFQs" do
        published_rfq = create(:rfq, :published)
        draft_rfq = create(:rfq, status: 'draft')

        get rfqs_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include(published_rfq.title)
        expect(response.body).not_to include(draft_rfq.title)
      end
    end
  end

  describe "POST /rfqs" do
    context "as a buyer" do
      before { sign_in buyer }

      it "creates a new RFQ with valid params" do
        rfq_params = {
          rfq: {
            title: "New Office Supplies",
            description: "Need supplies for new office",
            deadline: 1.week.from_now,
            status: "draft"
          }
        }

        expect {
          post rfqs_path, params: rfq_params
        }.to change(Rfq, :count).by(1)

        expect(response).to redirect_to(rfq_path(Rfq.last))
        follow_redirect!
        expect(response.body).to include("RFQ was successfully created")
      end

      it "fails with invalid params" do
        rfq_params = {
          rfq: {
            title: "",
            description: "",
            deadline: nil,
            status: "draft"
          }
        }

        expect {
          post rfqs_path, params: rfq_params
        }.not_to change(Rfq, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      context "with file attachments" do
        it "creates RFQ with valid attachments" do
          rfq_params = {
            rfq: {
              title: "RFQ with attachments",
              description: "Test RFQ with files",
              deadline: 1.week.from_now,
              status: "draft",
              documents: [
                fixture_file_upload('test.pdf', 'application/pdf')
              ]
            }
          }

          expect {
            post rfqs_path, params: rfq_params
          }.to change(Rfq, :count).by(1)

          rfq = Rfq.last
          expect(rfq.documents).to be_attached
          expect(rfq.documents.count).to eq(1)
          expect(rfq.documents.first.filename.to_s).to eq('test.pdf')
        end

        it "rejects invalid file types" do
          rfq_params = {
            rfq: {
              title: "RFQ with invalid file",
              description: "Test RFQ",
              deadline: 1.week.from_now,
              status: "draft",
              documents: [
                fixture_file_upload('malicious.exe', 'application/x-msdownload')
              ]
            }
          }

          post rfqs_path, params: rfq_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('must be PDF, DOC, DOCX, XLS, or XLSX')
        end
      end
    end

    context "as a supplier" do
      before { sign_in supplier }

      it "denies access" do
        post rfqs_path, params: { rfq: { title: "Test" } }

        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("Access denied")
      end
    end
  end

  describe "PUT /rfqs/:id" do
    let(:rfq) { create(:rfq, user: buyer) }

    context "as the RFQ owner" do
      before { sign_in buyer }

      it "updates the RFQ" do
        put rfq_path(rfq), params: { rfq: { title: "Updated Title" } }

        expect(response).to redirect_to(rfq_path(rfq))
        expect(rfq.reload.title).to eq("Updated Title")
      end
    end

    context "as another buyer" do
      let(:other_buyer) { create(:user, :buyer) }
      before { sign_in other_buyer }

      it "denies access" do
        expect {
          put rfq_path(rfq), params: { rfq: { title: "Hacked" } }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
