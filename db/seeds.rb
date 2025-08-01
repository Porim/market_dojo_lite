# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create buyers
buyer1 = User.create!(
  email: "buyer1@example.com",
  password: "password123",
  name: "John Smith",
  role: "buyer",
  company_name: "ABC Corp",
  phone: "01234567890"
)

buyer2 = User.create!(
  email: "buyer2@example.com",
  password: "password123",
  name: "Jane Doe",
  role: "buyer",
  company_name: "XYZ Ltd",
  phone: "09876543210"
)

# Create suppliers
supplier1 = User.create!(
  email: "supplier1@example.com",
  password: "password123",
  name: "Bob Wilson",
  role: "supplier",
  company_name: "Wilson Supplies",
  phone: "01122334455"
)

supplier2 = User.create!(
  email: "supplier2@example.com",
  password: "password123",
  name: "Alice Brown",
  role: "supplier",
  company_name: "Brown Industries",
  phone: "05566778899"
)

supplier3 = User.create!(
  email: "supplier3@example.com",
  password: "password123",
  name: "Charlie Green",
  role: "supplier",
  company_name: "Green Solutions",
  phone: "07788990011"
)

# Create RFQs
rfq1 = buyer1.rfqs.create!(
  title: "Office Furniture Supply",
  description: "We need 50 office desks and 100 ergonomic chairs for our new office location. Delivery required by end of next month.",
  deadline: 7.days.from_now,
  status: "published"
)

rfq2 = buyer1.rfqs.create!(
  title: "IT Equipment Procurement",
  description: "Looking for suppliers of: 30 laptops (min spec: i5, 16GB RAM, 512GB SSD), 30 monitors (27\", 4K), and necessary peripherals.",
  deadline: 10.days.from_now,
  status: "published"
)

rfq3 = buyer2.rfqs.create!(
  title: "Cleaning Services Contract",
  description: "Annual cleaning services contract for 3 office buildings. Daily cleaning required Mon-Fri, deep clean monthly.",
  deadline: 14.days.from_now,
  status: "published"
)

rfq4 = buyer2.rfqs.create!(
  title: "Catering Services",
  description: "Daily lunch catering for 200 employees. Vegetarian and vegan options required. Contract period: 1 year.",
  deadline: 5.days.from_now,
  status: "draft"
)

# Create quotes
Quote.create!(
  rfq: rfq1,
  user: supplier1,
  price: 45000,
  notes: "Can deliver all items within 3 weeks. Price includes delivery and assembly."
)

Quote.create!(
  rfq: rfq1,
  user: supplier2,
  price: 42000,
  notes: "Bulk discount applied. 5 year warranty on all items."
)

Quote.create!(
  rfq: rfq1,
  user: supplier3,
  price: 48000,
  notes: "Premium quality furniture with 10 year warranty."
)

Quote.create!(
  rfq: rfq2,
  user: supplier2,
  price: 75000,
  notes: "All items in stock. Can deliver within 1 week."
)

Quote.create!(
  rfq: rfq2,
  user: supplier3,
  price: 72000,
  notes: "Includes 3 year warranty and on-site support."
)

Quote.create!(
  rfq: rfq3,
  user: supplier1,
  price: 120000,
  notes: "Annual price. Eco-friendly cleaning products used."
)

# Create an active auction
auction = rfq1.create_auction!(
  status: "active",
  start_time: 1.hour.ago,
  end_time: 4.hours.from_now,
  current_price: 42000
)

# Create some bids
Bid.create!(
  auction: auction,
  user: supplier2,
  amount: 41000
)

Bid.create!(
  auction: auction,
  user: supplier1,
  amount: 40500
)

puts "Seed data created successfully!"
puts "Buyers: #{User.buyers.count}"
puts "Suppliers: #{User.suppliers.count}"
puts "RFQs: #{Rfq.count}"
puts "Quotes: #{Quote.count}"
puts "Active Auctions: #{Auction.active.count}"