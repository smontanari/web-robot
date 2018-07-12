require 'faye/websocket'
require 'json'

require_relative 'robots_store'

module WebRobot
  class RobotControl
    KEEPALIVE_TIME = 60 # in seconds

    def initialize(app, logger)
      @app = app
      @logger = logger
      @ws_clients = []
      @robot_store = RobotsStore.new(10)
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, { ping: KEEPALIVE_TIME })
        ws.on :open do |event|
          @logger.info "web socket open: #{ws.object_id}"
          @ws_clients << ws
        end

        ws.on :message do |event|
          @logger.info "web socket message: #{event.data}"
          direct_msg, broadcast_msg = @robot_store.process(JSON.parse(event.data))
          ws.send(direct_msg.to_json)
          @ws_clients.each { |client| client.send(broadcast_msg.to_json) } if broadcast_msg
        rescue => err
          @logger.error "#{err}\n#{err.backtrace.take(10).concat(['...']).join("\n")}"
        end

        ws.on :close do |event|
          @logger.info "web socket closed: #{ws.object_id}, #{event.code}, #{event.reason}"
          @ws_clients.delete(ws)
          ws = nil
        end

        # Return async Rack response
        ws.rack_response if ws
      else
        @app.call(env)
      end
    end
  end
end
