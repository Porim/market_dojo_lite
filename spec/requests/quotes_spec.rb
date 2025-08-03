require 'rails_helper'

RSpec.describe "Quotes", type: :request do
  let(:supplier) { create(:user, :supplier) }
  let(:buyer) { create(:user, :buyer) }
  let(:rfq) { create(:rfq, :published) }

  describe "POST /rfqs/:rfq_id/quotes" do
    context "as a supplier" do
      before { sign_in supplier }

      it "creates a quote for published RFQ" do
        quote_params = {
          quote: {
            price: 5000,
            notes: "Can deliver within 2 weeks"
          }
        }

        expect {
          post rfq_quotes_path(rfq), params: quote_params
        }.to change(Quote, :count).by(1)

        expect(response).to redirect_to(rfq_path(rfq))
        follow_redirect!
        expect(response.body).to include("Quote was successfully submitted")
      end

      it "prevents duplicate quotes" do
        create(:quote, rfq: rfq, user: supplier)

        quote_params = {
          quote: {
            price: 4500,
            notes: "Updated quote"
          }
        }

        expect {
          post rfq_quotes_path(rfq), params: quote_params
        }.not_to change(Quote, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "cannot quote on draft RFQ" do
        draft_rfq = create(:rfq, status: 'draft')

        post rfq_quotes_path(draft_rfq), params: { quote: { price: 1000 } }

        expect(response).to have_http_status(:not_found)
      end
    end

    context "as a buyer" do
      before { sign_in buyer }

      it "denies access" do
        post rfq_quotes_path(rfq), params: { quote: { price: 1000 } }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Access denied")
      end
    end
  end
end
