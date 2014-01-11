namespace :projection do
  desc "Fetch data from STATS" 
  task fetch_stats: :environment do
  end

  desc "Run all tasks needed to build project"
  task run_all: [:environment, :fetch_stats] do
  end

end
