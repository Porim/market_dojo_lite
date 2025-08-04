namespace :production do
  desc "Seed production database via Cloud Run job"
  task :seed do
    puts "🌱 Running production seed via Cloud Run job..."
    
    project_id = "market-dojo-lite-1754153513"
    region = "europe-west2"
    job_name = "market-dojo-lite-seed"
    
    # Check if job exists
    job_exists = system("gcloud run jobs describe #{job_name} --region=#{region} --project=#{project_id} > /dev/null 2>&1")
    
    if job_exists
      puts "Executing existing seed job..."
      system("gcloud run jobs execute #{job_name} --region=#{region} --project=#{project_id} --wait")
    else
      puts "Seed job not found. Creating and running it..."
      system("bin/seed-production")
    end
  end
  
  desc "Check production database stats"
  task :stats do
    puts "📊 Checking production database statistics..."
    
    project_id = "market-dojo-lite-1754153513"
    region = "europe-west2"
    service_name = "market-dojo-lite"
    
    # Create a one-off job to check stats
    stats_command = [
      "bundle", "exec", "rails", "runner",
      "puts '📊 Production Database Stats:'; " +
      "puts '─' * 60; " +
      "puts \"Users: #{User.count} (#{User.buyers.count} buyers, #{User.suppliers.count} suppliers)\"; " +
      "puts \"RFQs: #{Rfq.count} (#{Rfq.draft.count} draft, #{Rfq.published.count} published, #{Rfq.closed.count} closed)\"; " +
      "puts \"Quotes: #{Quote.count}\"; " +
      "puts \"Auctions: #{Auction.count} (#{Auction.active.count} active, #{Auction.completed.count} completed)\"; " +
      "puts \"Bids: #{Bid.count}\"; " +
      "puts '─' * 60"
    ].join(" ")
    
    system(
      "gcloud run jobs create #{service_name}-stats " +
      "--image=europe-west2-docker.pkg.dev/#{project_id}/#{service_name}/#{service_name}:latest " +
      "--region=#{region} " +
      "--project=#{project_id} " +
      "--set-env-vars='^##^RAILS_ENV=production##DATABASE_URL=PLACEHOLDER##RAILS_MASTER_KEY=PLACEHOLDER##SENTRY_DSN=PLACEHOLDER' " +
      "--set-secrets='DATABASE_URL=database-url:latest,RAILS_MASTER_KEY=rails-master-key:latest,SENTRY_DSN=sentry-dsn:latest' " +
      "--command='#{stats_command}' " +
      "--max-retries=0 " +
      "--task-timeout=60 " +
      "2>/dev/null || true"
    )
    
    system("gcloud run jobs execute #{service_name}-stats --region=#{region} --project=#{project_id} --wait")
    
    # Clean up the stats job
    system("gcloud run jobs delete #{service_name}-stats --region=#{region} --project=#{project_id} --quiet 2>/dev/null || true")
  end
end