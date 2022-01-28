require "./game"

require "kemal"
# require "kemal-session"
# require "random/secure"

error 404 do
  text = "Страница не найдена"
  render "src/web/views/error.ecr", "src/web/views/layout.ecr"
end
error 403 do
  text = "Доступ запрещен"
  render "src/web/views/error.ecr", "src/web/views/layout.ecr"
end
get "/" do |env|
  env.response.status_code = 403
end

def cmd_react(game, cmd)
  case cmd
  when "d"
    game.next_day
  when "r"
    game.reset
  when /m (.*)/
    game.make_patient $1.to_i
  end

  game.for_json
end

ws "/ws" do |socket|
  game = Game.new
  puts "Opening socket"
  socket.send game.for_json
  socket.on_message do |message|
    puts "socket: #{message}"
    socket.send cmd_react(game, message)
  end
  socket.on_close do
    puts "Closing socket"
  end
end

Kemal.run do |config|
  server = config.server.not_nil!
  server.bind_tcp "0.0.0.0", 3000, reuse_port: true
end
