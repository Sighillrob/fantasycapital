require 'csv'

arr_of_arrs = CSV.read(ARGV[0])

names = []
arr_of_arrs[0].each do |a_n|
  names << a_n
end

arr_of_arrs[1..-1].each do |row|
  puts "p = Player.create(name: \"#{row[0]}\", team: \"#{row[1]}\", position: \"#{row[2]}\", age: #{row[3].to_i})"
  col_n = row.length - 1
  (4..col_n).each do |col|
    puts "PlayerPerfIndex.create(player: p, index_name: \"#{names[col]}\", index_value: \"#{row[col]}\")"
  end
end
