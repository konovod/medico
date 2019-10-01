require "./game"

game = Game.new
game.reset
game.next_day

puts game.for_json
