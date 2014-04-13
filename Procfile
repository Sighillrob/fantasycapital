web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
resque: env TERM_CHILD=1 bundle exec rake resque:work
# The # of sidekiq workers matches the max # of simultaneous games we can track.
# NOTE this number should match the # of DB connections available in 
# config/initializers/sidekiq.rb
worker: bundle exec sidekiq -c 10 -v
#rtdata: bundle exec rake realtime:games_old

# run realtime process for all games of one day 
# NOTE: if you change the name 'rtdata' below, make sure to change rake
# realtime:games_parallel task too
rtdata: bundle exec rake realtime:games

# check if 'rtdata' task should be started. This will be called periodically 
# via the heroku scheduler
check_start_realtime: bundle exec rake realtime:check_start_realtime

simdata: bundle exec rake realtime:games_playback

