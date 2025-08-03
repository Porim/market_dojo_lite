require 'rails_helper'

RSpec.describe "Api::V1::Rfqs", type: :request do
  let(:buyer) { create(:user, :buyer) }
  let(:supplier) { create(:user, :supplier) }
  let(:headers) { { 'Authorization' => "Bearer #{buyer.api_token}" } }
  let(:supplier_headers) { { 'Authorization' => "Bearer #{supplier.api_token}" } }

  describe "GET /api/v1/rfqs" do
    let!(:buyer_rfq) { create(:rfq, user: buyer, status: 'draft') }
    let!(:published_rfq) { create(:rfq, :published) }

    context "as a buyer" do
      it "returns buyer's own RFQs" do
        get api_v1_rfqs_path, headers: headers

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['rfqs'].count).to eq(1)
        expect(json['rfqs'].first['id']).to eq(buyer_rfq.id)
      end
    end

    context "as a supplier" do
      it "returns only published RFQs" do
        get api_v1_rfqs_path, headers: supplier_headers

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['rfqs'].count).to eq(1)
        expect(json['rfqs'].first['id']).to eq(published_rfq.id)
      end
    end

    it "supports pagination" do
      create_list(:rfq, 25, :published)

      get api_v1_rfqs_path, headers: supplier_headers, params: { page: 2, per_page: 10 }

      json = JSON.parse(response.body)
      expect(json['rfqs'].count).to eq(10)
      expect(json['meta']['current_page']).to eq(2)
      expect(json['meta']['total_count']).to eq(26) # 25 + 1 from before
    end
  end

  describe "POST /api/v1/rfqs" do
    let(:rfq_params) do
      {
        rfq: {
          title: "New RFQ",
          description: "Description",
          deadline: 1.week.from_now,
          status: "published"
        }
      }
    end

    context "as a buyer" do
      it "creates a new RFQ" do
        expect {
          post api_v1_rfqs_path, headers: headers, params: rfq_params
        }.to change(Rfq, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['rfq']['title']).to eq("New RFQ")
      end

      it "sends notifications when published" do
        # Ensure we only have one supplier with email preferences
        User.where.not(id: [ buyer.id, supplier.id ]).destroy_all
        EmailPreference.destroy_all
        create(:email_preference, user: supplier, rfq_created: true)

        expect {
          post api_v1_rfqs_path, headers: headers, params: rfq_params
        }.to have_enqueued_mail(NotificationMailer, :rfq_created).once
      end
    end

    context "as a supplier" do
      it "returns forbidden error" do
        post api_v1_rfqs_path, headers: supplier_headers, params: rfq_params

        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Only buyers can perform this action')
      end
    end
  end

  describe "GET /api/v1/rfqs/:id" do
    it "returns RFQ details with quotes and documents" do
      # Create RFQ owned by the buyer
      rfq = create(:rfq, :published, user: buyer)
      quote = create(:quote, rfq: rfq)
      rfq.documents.attach(
        io: StringIO.new('test'),
        filename: 'test.pdf',
        content_type: 'application/pdf'
      )

      get api_v1_rfq_path(rfq), headers: headers

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['rfq']['id']).to eq(rfq.id)
      expect(json['rfq']['quotes'].count).to eq(1)
      expect(json['rfq']['documents'].count).to eq(1)
    end
  end

  describe "PUT /api/v1/rfqs/:id" do
    let(:rfq) { create(:rfq, user: buyer) }

    it "updates the RFQ" do
      put api_v1_rfq_path(rfq), headers: headers, params: {
        rfq: { title: "Updated Title" }
      }

      expect(response).to have_http_status(:success)
      expect(rfq.reload.title).to eq("Updated Title")
    end
  end

  describe "DELETE /api/v1/rfqs/:id" do
    let!(:rfq) { create(:rfq, user: buyer) }

    it "deletes the RFQ" do
      expect {
        delete api_v1_rfq_path(rfq), headers: headers
      }.to change(Rfq, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
