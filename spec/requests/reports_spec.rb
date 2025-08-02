require 'rails_helper'

RSpec.describe "Reports", type: :request do
  let(:buyer) { create(:user, :buyer) }
  let(:supplier) { create(:user, :supplier) }

  before { sign_in buyer }

  describe "GET /reports" do
    it "displays the reports dashboard" do
      get reports_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Advanced Reports")
      expect(response.body).to include("Spend Analysis")
      expect(response.body).to include("Supplier Performance")
    end

    context "as a supplier" do
      before { sign_in supplier }

      it "denies access" do
        get reports_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /reports/spend_analysis" do
    let!(:rfq) { create(:rfq, user: buyer, status: 'closed') }
    let!(:quote1) { create(:quote, rfq: rfq, price: 100) }
    let!(:quote2) { create(:quote, rfq: rfq, price: 150) }

    it "displays spend analysis report" do
      get spend_analysis_reports_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Spend Analysis")
      expect(response.body).to include("Total Spend")
    end

    it "exports CSV data" do
      get spend_analysis_reports_path(format: :csv)

      expect(response).to have_http_status(:success)
      expect(response.content_type).to include('text/csv')
      expect(response.headers['Content-Disposition']).to include('spend_analysis')
    end
  end

  describe "GET /reports/supplier_performance" do
    let!(:supplier1) { create(:user, :supplier) }
    let!(:rfq) { create(:rfq, user: buyer, status: 'published') }
    let!(:quote) { create(:quote, rfq: rfq, user: supplier1, price: 100) }

    it "displays supplier performance report" do
      get supplier_performance_reports_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Supplier Performance")
      expect(response.body).to include(supplier1.company_name)
    end
  end

  describe "GET /reports/rfq_analytics" do
    let!(:rfq1) { create(:rfq, user: buyer, status: 'published') }
    let!(:rfq2) { create(:rfq, user: buyer, status: 'closed') }

    it "displays RFQ analytics" do
      get rfq_analytics_reports_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("RFQ Analytics")
    end
  end
end
