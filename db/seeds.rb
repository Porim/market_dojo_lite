# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require 'faker'

puts "🌱 Starting comprehensive database seed..."

# Clear existing data
puts "Cleaning existing data..."
Bid.destroy_all
Auction.destroy_all
Quote.destroy_all
Rfq.destroy_all
User.destroy_all

puts "✓ Database cleaned"

# Arrays for varied data
company_types = ['Corp', 'Ltd', 'Inc', 'Group', 'Holdings', 'International', 'Solutions', 'Services']
industries = ['Technology', 'Manufacturing', 'Retail', 'Healthcare', 'Finance', 'Construction', 'Logistics', 'Energy']

# Create buyers with varied companies
puts "\nCreating buyers..."
buyers = []
20.times do |i|
  buyers << User.create!(
    email: "buyer#{i+1}@example.com",
    password: "password123",
    name: Faker::Name.name,
    role: "buyer",
    company_name: "#{Faker::Company.name} #{company_types.sample}",
    phone: Faker::PhoneNumber.phone_number
  )
end

# Create main demo buyer
demo_buyer = User.create!(
  email: "buyer@demo.com",
  password: "password",
  name: "John Demo",
  role: "buyer",
  company_name: "Demo Buyer Corp",
  phone: "+44 20 1234 5678"
)
buyers << demo_buyer

puts "✓ Created #{buyers.count} buyers"

# Create suppliers
puts "\nCreating suppliers..."
suppliers = []
30.times do |i|
  suppliers << User.create!(
    email: "supplier#{i+1}@example.com",
    password: "password123",
    name: Faker::Name.name,
    role: "supplier",
    company_name: "#{Faker::Company.name} #{['Supplies', 'Industries', 'Manufacturing', 'Trading', 'Distribution'].sample}",
    phone: Faker::PhoneNumber.phone_number
  )
end

# Create main demo supplier
demo_supplier = User.create!(
  email: "supplier@demo.com",
  password: "password",
  name: "Sarah Demo",
  role: "supplier",
  company_name: "Demo Supplier Ltd",
  phone: "+44 161 234 5678"
)
suppliers << demo_supplier

puts "✓ Created #{suppliers.count} suppliers"

# Create RFQs with various statuses and dates for analytics
puts "\nCreating RFQs..."
rfqs = []

# Historical closed RFQs (for analytics data)
40.times do |i|
  created_date = Faker::Date.between(from: 6.months.ago, to: 1.month.ago)
  deadline = created_date + rand(7..21).days
  
  rfq = Rfq.create!(
    title: "#{['Urgent', 'Annual', 'Q1', 'Q2', 'Emergency', 'Scheduled'].sample} #{Faker::Commerce.product_name} #{['Supply', 'Contract', 'Procurement', 'Order'].sample}",
    description: Faker::Lorem.paragraphs(number: 3).join("\n\n"),
    user: buyers.sample,
    deadline: deadline,
    status: "closed",
    created_at: created_date,
    updated_at: deadline + 1.day
  )
  
  # Add quotes from multiple unique suppliers
  num_quotes = [rand(3..8), suppliers.count].min
  participating_suppliers = suppliers.sample(num_quotes)
  participating_suppliers.each do |supplier|
    quote_date = Faker::Date.between(from: rfq.created_at, to: rfq.deadline)
    Quote.create!(
      rfq: rfq,
      user: supplier,
      price: rand(10000..100000),
      notes: Faker::Lorem.paragraph(sentence_count: 4),
      created_at: quote_date,
      updated_at: quote_date
    )
  end
  
  rfqs << rfq
end

# Currently active RFQs
25.times do |i|
  created_date = Faker::Date.between(from: 14.days.ago, to: 1.day.ago)
  deadline = Faker::Date.between(from: 1.day.from_now, to: 21.days.from_now)
  
  rfq = Rfq.create!(
    title: "#{['New', 'Repeat', 'Special', 'Standard'].sample} #{Faker::Commerce.product_name} #{['Requirements', 'Tender', 'RFQ', 'Bidding'].sample}",
    description: Faker::Lorem.paragraphs(number: 4).join("\n\n"),
    user: buyers.sample,
    deadline: deadline,
    status: "published",
    created_at: created_date,
    updated_at: created_date
  )
  
  # Add some quotes (not all suppliers have quoted yet)
  num_quotes = [rand(0..5), suppliers.count].min
  participating_suppliers = suppliers.sample(num_quotes)
  participating_suppliers.each do |supplier|
    Quote.create!(
      rfq: rfq,
      user: supplier,
      price: rand(5000..80000),
      notes: Faker::Lorem.paragraph(sentence_count: 3),
      created_at: Faker::Date.between(from: rfq.created_at, to: Date.today),
      updated_at: Date.today
    )
  end
  
  rfqs << rfq
end

# Draft RFQs
10.times do |i|
  rfq = Rfq.create!(
    title: "DRAFT: #{Faker::Commerce.product_name} #{['Specification', 'Requirements', 'Proposal'].sample}",
    description: Faker::Lorem.paragraphs(number: 2).join("\n\n"),
    user: buyers.sample,
    deadline: Faker::Date.between(from: 7.days.from_now, to: 30.days.from_now),
    status: "draft"
  )
  rfqs << rfq
end

puts "✓ Created #{rfqs.count} RFQs"

# Create special RFQs for demo users
puts "\nCreating demo RFQs..."

# Active RFQ from demo buyer with quotes
demo_rfq1 = demo_buyer.rfqs.create!(
  title: "Office Furniture Supply - Q1 2025",
  description: "We are looking for suppliers to provide office furniture for our new London headquarters.\n\nRequirements:\n- 50 Executive desks\n- 100 Ergonomic chairs\n- 10 Meeting room tables\n- 20 Storage cabinets\n\nDelivery required within 4 weeks of order. Installation services preferred.",
  deadline: 7.days.from_now,
  status: "published"
)

# Add quotes from multiple suppliers including demo supplier
# Ensure unique suppliers by excluding demo supplier from the sample
other_suppliers = suppliers.reject { |s| s == demo_supplier }.sample(4)
[demo_supplier, *other_suppliers].each_with_index do |supplier, index|
  Quote.create!(
    rfq: demo_rfq1,
    user: supplier,
    price: 35000 + (index * 2000),
    notes: supplier == demo_supplier ? 
      "We can provide all items from our premium range with a 5-year warranty. Free delivery and installation included." :
      Faker::Lorem.paragraph(sentence_count: 3)
  )
end

# Another active RFQ from demo buyer
demo_rfq2 = demo_buyer.rfqs.create!(
  title: "IT Equipment Procurement - Laptops and Accessories",
  description: "Procurement of IT equipment for new hires in 2025.\n\nSpecifications:\n- 30 Business laptops (Intel i7, 16GB RAM, 512GB SSD)\n- 30 USB-C docking stations\n- 30 External monitors (27-inch, 4K)\n- 30 Wireless keyboard and mouse sets\n\nPreferred brands: Dell, HP, or Lenovo",
  deadline: 10.days.from_now,
  status: "published"
)

# Create some auctions
puts "\nCreating auctions..."

# Historical auction
historical_auction_rfq = buyers.sample.rfqs.create!(
  title: "AUCTION: Bulk Paper Supply - 10,000 reams",
  description: "Reverse auction for office paper supply. A4 80gsm white paper. Delivery to multiple locations required.",
  deadline: 1.month.ago,
  status: "closed",
  created_at: 2.months.ago,
  updated_at: 1.month.ago
)

historical_auction = historical_auction_rfq.create_auction!(
  status: "completed",
  start_time: 2.months.ago,
  end_time: 1.month.ago,
  current_price: 35000, # Set higher initial price
  created_at: 2.months.ago,
  updated_at: 1.month.ago
)

# Skip bids for historical auction to avoid ActionCable issues
puts "  - Historical auction created (no bids due to production constraints)"

# Active auction from demo buyer
auction_rfq = demo_buyer.rfqs.create!(
  title: "AUCTION: Stationery Supply Contract - 2025",
  description: "Reverse auction for annual stationery supply contract.\n\nItems include:\n- Pens, pencils, markers\n- Notebooks and notepads\n- Folders and binders\n- General office supplies\n\nEstimated annual value: £40,000-50,000",
  deadline: 4.hours.from_now,
  status: "published"
)

active_auction = auction_rfq.create_auction!(
  status: "active",
  start_time: 1.hour.ago,
  end_time: 3.hours.from_now,
  current_price: 45000
)

# Skip bids for active auction to avoid ActionCable issues
puts "  - Active auction created (bids disabled in production seed)"

# Another active auction
auction_rfq2 = buyers.sample.rfqs.create!(
  title: "AUCTION: Cleaning Services - Central London Offices",
  description: "Reverse auction for cleaning services contract. 5 floors, approximately 50,000 sq ft total. Evening cleaning required Mon-Fri.",
  deadline: 2.hours.from_now,
  status: "published"
)

active_auction2 = auction_rfq2.create_auction!(
  status: "active",
  start_time: 30.minutes.ago,
  end_time: 1.hour.from_now,
  current_price: 120000
)

# Skip bids to avoid ActionCable issues
puts "  - Second auction created (bids disabled in production seed)"

puts "✓ Created auctions with bids"

# Create RFQs with specific patterns for analytics
puts "\nCreating RFQs for analytics patterns..."

# Seasonal patterns
seasons = ['Spring', 'Summer', 'Autumn', 'Winter']
4.times do |quarter|
  10.times do |i|
    date = (3 - quarter).months.ago + i.days
    rfq = buyers.sample.rfqs.create!(
      title: "#{seasons[quarter]} #{Faker::Commerce.product_name} Order",
      description: "Seasonal procurement for #{seasons[quarter]} #{Date.today.year}",
      deadline: date + 14.days,
      status: "closed",
      created_at: date,
      updated_at: date + 15.days
    )
    
    # Add quotes from unique suppliers
    num_quotes = [rand(2..5), suppliers.count].min
    quote_suppliers = suppliers.sample(num_quotes)
    quote_suppliers.each do |supplier|
      Quote.create!(
        rfq: rfq,
        user: supplier,
        price: rand(15000..60000),
        notes: "Seasonal pricing applied",
        created_at: date + rand(1..10).days
      )
    end
  end
end

# Print summary
puts "\n📊 Seed Summary:"
puts "─" * 60
puts "Users: #{User.count} (#{User.buyers.count} buyers, #{User.suppliers.count} suppliers)"
puts "RFQs: #{Rfq.count}"
puts "  - Draft: #{Rfq.where(status: 'draft').count}"
puts "  - Published: #{Rfq.where(status: 'published').count}"
puts "  - Closed: #{Rfq.where(status: 'closed').count}"
puts "Quotes: #{Quote.count}"
puts "Auctions: #{Auction.count} (#{Auction.active.count} active)"
puts "Bids: #{Bid.count}"
puts "─" * 60
puts "\n✅ Demo accounts:"
puts "Buyer: buyer@demo.com / password"
puts "Supplier: supplier@demo.com / password"
puts "\n🌱 Database seeding completed!"