require 'csv'

CSV.foreach(ARGV[0]) do |row|
puts "Contest.create(sport: \"#{row[1]}\", contest_type: \"#{row[0]}\", entry_fee: #{row[3].to_f}, prize: #{row[4].to_f}, contest_start:  Time.now + 60*60*12)"
end
