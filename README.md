# Market Dojo Lite

A simplified eProcurement platform demonstration built with Ruby on Rails 8, showcasing core functionality similar to Market Dojo's procurement software.

## Overview

Market Dojo Lite is a weekend project demonstrating proficiency in building modern web applications with Rails. It includes:

- Multi-tenant architecture (Buyers and Suppliers)
- RFQ (Request for Quotation) management
- Quote submission system
- Real-time reverse auctions
- Responsive design with Tailwind CSS
- ActionCable for live updates

## Tech Stack

- **Ruby on Rails 8.0.2** - Latest version showcasing modern Rails features
- **SQLite** - Database for simplicity
- **Hotwire (Turbo + Stimulus)** - For real-time features
- **Tailwind CSS v4** - Modern styling
- **Devise** - Authentication
- **ActionCable** - WebSocket connections for live auctions

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

## Key Files

- `app/models/` - Business logic and associations
- `app/controllers/` - RESTful controllers with authorization
- `app/views/` - ERB templates with Tailwind styling
- `app/javascript/controllers/auction_controller.js` - Real-time auction updates
- `app/channels/auction_channel.rb` - WebSocket handling

## Development Process

This project was built in a 48-hour sprint focusing on:
1. Core functionality over extensive features
2. Clean, readable code
3. Modern Rails best practices
4. Responsive, professional UI
5. Demonstrable real-time capabilities

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