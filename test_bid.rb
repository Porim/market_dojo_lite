#!/usr/bin/env ruby
# Test script to verify bidding functionality

require_relative 'config/environment'

# Find or create test users
buyer = User.find_or_create_by(email: "test_buyer@example.com") do |u|
  u.password = "password123"
  u.role = "buyer"
  u.company_name = "Test Buyer Co"
end

supplier = User.find_or_create_by(email: "test_supplier@example.com") do |u|
  u.password = "password123"
  u.role = "supplier"
  u.company_name = "Test Supplier Co"
end

# Create an RFQ
rfq = Rfq.create!(
  title: "Test RFQ for Bidding",
  description: "Testing bid functionality",
  deadline: 1.week.from_now,
  user: buyer
)

# Create an auction
auction = rfq.create_auction!(
  start_time: Time.current,
  end_time: 1.hour.from_now,
  current_price: 1000.00,
  status: "active"
)

puts "Created auction ##{auction.id} for RFQ '#{rfq.title}'"
puts "Current price: £#{auction.current_price}"

# Test creating a bid
begin
  bid = auction.bids.create!(
    amount: 950.00,
    user: supplier
  )
  puts "✅ Successfully created bid ##{bid.id} for £#{bid.amount}"
  puts "✅ Auction current price updated to: £#{auction.reload.current_price}"
rescue => e
  puts "❌ Error creating bid: #{e.message}"
  puts e.backtrace.first(5)
end

# Clean up
rfq.destroy
buyer.destroy if buyer.rfqs.empty?
supplier.destroy if supplier.quotes.empty? && supplier.bids.empty?

puts "\nTest completed!"
