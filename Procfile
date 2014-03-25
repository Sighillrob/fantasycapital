web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
resque: env TERM_CHILD=1 bundle exec rake resque:work
# The # of sidekiq workers matches the max # of simultaneous games we can track.
worker: bundle exec sidekiq -c 10 -v
#rtdata: bundle exec rake realtime:games
