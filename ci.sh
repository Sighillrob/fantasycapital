#!/bin/sh

rvm use 2.0.0
bundle install
export RAILS_ENV=test
bundle exec rake db:schema:load
bundle exec rake db:test:prepare
bundle exec rspec
