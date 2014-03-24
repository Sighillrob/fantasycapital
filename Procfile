web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
resque: env TERM_CHILD=1 bundle exec rake resque:work
worker: bundle exec sidekiq -c 25 -v
#rtdata: bundle exec rake realtime:games
