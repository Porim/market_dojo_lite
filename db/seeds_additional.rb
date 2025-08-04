# This file adds additional seed data WITHOUT destroying existing data
# Safe for production use

require 'faker'

puts "🌱 Adding additional seed data (preserving existing data)..."

# Check if we already have demo accounts
demo_buyer = User.find_by(email: "buyer@demo.com")
demo_supplier = User.find_by(email: "supplier@demo.com")

if demo_buyer && demo_supplier
  puts "✓ Demo accounts already exist"
else
  puts "Creating demo accounts..."

  demo_buyer ||= User.create!(
    email: "buyer@demo.com",
    password: "password",
    name: "John Demo",
    role: "buyer",
    company_name: "Demo Buyer Corp",
    phone: "+44 20 1234 5678"
  )

  demo_supplier ||= User.create!(
    email: "supplier@demo.com",
    password: "password",
    name: "Sarah Demo",
    role: "supplier",
    company_name: "Demo Supplier Ltd",
    phone: "+44 161 234 5678"
  )

  puts "✓ Created demo accounts"
end

# Add some additional test RFQs if we don't have many
if Rfq.count < 50
  puts "\nAdding additional RFQs..."

  buyers = User.buyers.to_a
  suppliers = User.suppliers.to_a

  # Ensure we have at least demo buyer
  buyers << demo_buyer unless buyers.include?(demo_buyer)

  20.times do |i|
    rfq = Rfq.create!(
      title: "Additional #{Faker::Commerce.product_name} #{[ 'Supply', 'Contract', 'Procurement' ].sample}",
      description: Faker::Lorem.paragraphs(number: 3).join("\n\n"),
      user: buyers.sample,
      deadline: rand(1..30).days.from_now,
      status: "published"
    )

    # Add some quotes
    rand(2..5).times do
      Quote.create!(
        rfq: rfq,
        user: suppliers.sample,
        price: rand(5000..50000),
        notes: Faker::Lorem.paragraph(sentence_count: 2)
      )
    end
  end

  puts "✓ Added additional RFQs"
end

# Print summary
puts "\n📊 Current Database Status:"
puts "─" * 60
puts "Users: #{User.count} (#{User.buyers.count} buyers, #{User.suppliers.count} suppliers)"
puts "RFQs: #{Rfq.count}"
puts "  - Draft: #{Rfq.where(status: 'draft').count}"
puts "  - Published: #{Rfq.where(status: 'published').count}"
puts "  - Closed: #{Rfq.where(status: 'closed').count}"
puts "Quotes: #{Quote.count}"
puts "Auctions: #{Auction.count}"
puts "Bids: #{Bid.count}"
puts "─" * 60
puts "\n✅ Additional seeding completed!"
