#!/usr/bin/env ruby
# Test script to verify N+1 query fix

require_relative 'config/environment'

# Create test data
buyer = User.find_or_create_by!(email: 'test_buyer@example.com') do |u|
  u.name = 'Test Buyer'
  u.role = 'buyer'
  u.company_name = 'Test Buyer Co'
  u.phone = '123-456-7890'
  u.password = 'password123'
end

# Create suppliers
suppliers = 5.times.map do |i|
  User.find_or_create_by!(email: "supplier#{i}@example.com") do |u|
    u.name = "Supplier #{i}"
    u.role = 'supplier'
    u.company_name = "Supplier Co #{i}"
    u.phone = "555-000#{i}"
    u.password = 'password123'
  end
end

# Create RFQs and quotes
3.times do |i|
  rfq = Rfq.find_or_create_by!(
    title: "Test RFQ #{i}",
    user: buyer
  ) do |r|
    r.description = "Test description #{i}"
    r.deadline = 1.week.from_now
    r.status = ['published', 'closed'].sample
  end
  
  # Each supplier quotes on each RFQ
  suppliers.each_with_index do |supplier, idx|
    Quote.find_or_create_by!(
      rfq: rfq,
      user: supplier
    ) do |q|
      q.price = 1000 + (idx * 100) + rand(50)
      q.delivery_date = 2.weeks.from_now
      q.details = "Quote details from #{supplier.company_name}"
    end
  end
end

puts "Test data created successfully!"
puts "Buyers: #{User.buyers.count}"
puts "Suppliers: #{User.suppliers.count}"
puts "RFQs: #{Rfq.count}"
puts "Quotes: #{Quote.count}"

# Now test the controller action with query logging
ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.verbose_query_logs = true

puts "\n\n=== Testing supplier_performance action ===\n\n"

controller = ReportsController.new
controller.instance_variable_set(:@current_user, buyer)
controller.define_singleton_method(:current_user) { @current_user }
controller.define_singleton_method(:params) { ActionController::Parameters.new }

# Count queries
query_count = 0
ActiveSupport::Notifications.subscribe('sql.active_record') do |*args|
  query_count += 1
end

# Execute the action
controller.supplier_performance

ActiveSupport::Notifications.unsubscribe('sql.active_record')

puts "\n\n=== Results ==="
puts "Total queries executed: #{query_count}"
puts "Suppliers found: #{controller.instance_variable_get(:@suppliers).count}"
puts "Win rates calculated: #{controller.instance_variable_get(:@win_rates).count}"

# Clean up test data
User.where(email: ['test_buyer@example.com'] + suppliers.map(&:email)).destroy_all