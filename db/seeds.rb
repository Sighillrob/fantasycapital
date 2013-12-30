# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Contest.delete_all
PlayerStat.delete_all
Player.delete_all
SportPosition.delete_all
LineupSpotProto.delete_all

Dir[Rails.root.join("db/seeds/*.rb")].entries.sort.each { |f| require f }
