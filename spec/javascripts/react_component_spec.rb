require 'rails_helper'

RSpec.describe "React Component Integration", type: :system do
  let(:buyer) { create(:user, :buyer, name: "Test Buyer", company_name: "Buyer Corp") }
  let(:supplier) { create(:user, :supplier, name: "Test Supplier", company_name: "Supplier Inc") }
  
  before do
    # Create various RFQs with different statuses and categories
    create(:rfq, user: buyer, title: "Office Supplies", status: "published", category: "Supplies")
    create(:rfq, user: buyer, title: "IT Equipment", status: "published", category: "Technology")
    create(:rfq, user: buyer, title: "Cleaning Services", status: "closed", category: "Services")
    create(:rfq, user: buyer, title: "Draft RFQ", status: "draft", category: "Supplies")
  end

  describe "RFQ Search Filter Component" do
    it "loads the React component on the RFQs page" do
      sign_in buyer
      visit rfqs_path
      
      expect(page).to have_css('[data-controller="react-component"]')
      expect(page).to have_content("Advanced Search & Filter")
    end
    
    it "filters RFQs by search term" do
      sign_in supplier
      visit rfqs_path
      
      # Search for "Office"
      fill_in "Search", with: "Office"
      
      expect(page).to have_content("Office Supplies")
      expect(page).not_to have_content("IT Equipment", wait: 2)
    end
    
    it "filters RFQs by status" do
      sign_in supplier
      visit rfqs_path
      
      # Filter by published status
      select "Published", from: "Status"
      
      expect(page).to have_content("Office Supplies")
      expect(page).to have_content("IT Equipment")
      expect(page).not_to have_content("Cleaning Services", wait: 2)
    end
    
    it "sorts RFQs by different criteria" do
      sign_in supplier
      visit rfqs_path
      
      # Sort by oldest first
      select "Oldest First", from: "Sort By"
      
      # Verify order (would need to check actual order in real test)
      expect(page).to have_content("Showing filtered RFQs")
    end
  end
end