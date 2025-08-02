# Market Dojo Lite

A simplified eProcurement platform demonstration built with Ruby on Rails 8, showcasing core functionality similar to Market Dojo's procurement software. This project specifically demonstrates proficiency in the technologies mentioned in Market Dojo's job specification.

## Overview

Market Dojo Lite is a weekend project demonstrating proficiency in building modern web applications with Rails. Built using **Agile development practices** with a focus on clean, test-driven code. It includes:

- Multi-tenant SaaS architecture (Buyers and Suppliers)
- RFQ (Request for Quotation) management
- Quote submission system
- Real-time reverse auctions
- Analytics dashboard with charts
- Comprehensive RSpec test suite
- Responsive design with HTML, CSS, and JavaScript

## Tech Stack (Aligned with Job Requirements)

### Required Technologies ✅
- **Ruby on Rails 8.0.2** - Latest Rails version
- **HTML/CSS/JavaScript** - Modern frontend with Stimulus.js
- **RSpec** - Comprehensive test suite with TDD approach
- **PostgreSQL/SQLite** - Relational database with SQL
- **Git** - Version control with clean commit history
- **Linux/Cloud** - Deployed on cloud infrastructure (Fly.io)

### Additional Technologies
- **Hotwire (Turbo + Stimulus)** - For real-time features
- **React** - Modern JavaScript framework for interactive UI components
- **Tailwind CSS v4** - Modern styling framework
- **Devise** - Authentication system
- **ActionCable** - WebSocket connections for live auctions
- **Chartkick** - Analytics visualizations
- **Factory Bot & Faker** - Test data generation

### Cloud & DevOps
- Designed for **Google Cloud Platform (GCP)** compatibility
- Currently deployed on Fly.io (similar cloud architecture)
- Docker containerized for easy deployment
- GitHub Actions for CI/CD

## Features

### For Buyers
- Create and manage RFQs
- Review supplier quotes
- Start reverse auctions
- Real-time auction monitoring
- Dashboard with procurement overview

### For Suppliers
- Browse available RFQs
- Submit competitive quotes
- Participate in live auctions
- Track quote history
- Real-time bid updates

### Advanced Features
- **React-powered Search & Filter** - Advanced RFQ filtering with real-time updates
- **Analytics Dashboard** - Comprehensive procurement insights with charts
- **Real-time Auctions** - WebSocket-powered reverse auctions

## Getting Started

### Prerequisites
- Ruby 3.4.1
- Rails 8.0.2
- Node.js (for Tailwind CSS)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/market_dojo_lite.git
cd market_dojo_lite
```

2. Install dependencies:
```bash
bundle install
```

3. Setup database:
```bash
rails db:create
rails db:migrate
rails db:seed
```

4. Start the server:
```bash
bin/dev
```

Visit http://localhost:3000

### Running Tests (RSpec)

```bash
# Run all tests
rspec

# Run specific test files
rspec spec/models/
rspec spec/requests/

# Run with coverage
bundle exec rspec
```

### Demo Accounts

The seed data creates several demo accounts:

**Buyers:**
- buyer1@example.com / password123 (ABC Corp)
- buyer2@example.com / password123 (XYZ Ltd)

**Suppliers:**
- supplier1@example.com / password123 (Wilson Supplies)
- supplier2@example.com / password123 (Brown Industries)
- supplier3@example.com / password123 (Green Solutions)

## Architecture Decisions

### Database Design
- **Users** - Single table with role-based separation (buyer/supplier)
- **RFQs** - Belong to buyers, have many quotes
- **Quotes** - Connect suppliers to RFQs
- **Auctions** - One per RFQ, enable real-time bidding
- **Bids** - Track auction participation

### Real-time Features
- ActionCable channels for auction updates
- Stimulus controllers for client-side interactivity
- Turbo for seamless page updates

### Security
- Devise for authentication
- Role-based access control
- CSRF protection
- Strong parameters

## Test-Driven Development (TDD)

This project was built using TDD practices with RSpec:

- **Model Specs** - Complete coverage of business logic
- **Request Specs** - Integration tests for all controllers
- **Factory Bot** - Test data generation
- **Shoulda Matchers** - Clean validation testing

Example test coverage includes:
- User authentication and authorization
- RFQ creation and management workflows
- Quote submission validation
- Auction bidding rules
- Role-based access control

## Key Files

- `app/models/` - Business logic and associations
- `app/controllers/` - RESTful controllers with authorization
- `app/views/` - ERB templates with Tailwind styling
- `app/javascript/controllers/auction_controller.js` - Real-time auction updates
- `app/javascript/components/RFQSearchFilter.jsx` - React component for advanced filtering
- `app/channels/auction_channel.rb` - WebSocket handling
- `spec/` - Comprehensive RSpec test suite

## Development Process

This project was built in a 48-hour sprint using **Agile development methodology**:

### Sprint Planning
1. User story creation (buyer and supplier personas)
2. Feature prioritization based on core eProcurement needs
3. Test-first development approach with RSpec

### Implementation
1. Core functionality over extensive features
2. Clean, readable code following Rails conventions
3. Modern Rails best practices
4. Responsive, professional UI
5. Demonstrable real-time capabilities
6. Continuous integration mindset

### Technologies Demonstrated
- ✅ Ruby on Rails (8.0.2)
- ✅ HTML, CSS, JavaScript
- ✅ React for interactive UI components
- ✅ TDD with RSpec
- ✅ SQL (SQLite/PostgreSQL ready)
- ✅ Git version control
- ✅ Linux/Cloud deployment
- ✅ Agile development practices

## Future Enhancements

Given more time, potential improvements include:
- Advanced search and filtering
- Email notifications
- File attachments for RFQs
- Analytics dashboard with charts
- API for third-party integrations
- Comprehensive test suite
- Performance optimizations

## Deployment

Ready for deployment on Fly.io:

```bash
fly launch
fly deploy
```

## Why This Demonstrates Market Dojo Understanding

This project shows understanding of:
- eProcurement domain concepts
- Multi-sided marketplace dynamics
- Real-time bidding mechanisms
- Enterprise software UI/UX patterns
- Modern web application architecture

Built specifically to demonstrate capabilities relevant to Market Dojo's technology stack and business domain.