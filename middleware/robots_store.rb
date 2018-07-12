require 'securerandom'

require_relative '../models/robots'

module WebRobot
  class RobotsStore
    def initialize(grid_size)
      @semaphore = Mutex.new
      @robots = {}
      @space = Robots::TabletopSpace::Tabletop.new(grid_size)
    end

    def process(message)
      message_id = message['id']
      action = message['payload']['action']
      content = message['payload']['content']
      self.send(action, message_id, content)
    rescue => error
      [{ id: message_id, error: error.to_s }]
    end

    private

    def list(message_id, _)
      [{
        id: message_id,
        payload: @robots.values.reject(&:not_placed?).map(&:status)
      }]
    end

    def create(message_id, content)
      3.times do
        robot = @semaphore.synchronize do
          uid = SecureRandom.uuid
          unless @robots.key?(uid)
            Robots::Robot.new(uid, content['name']).tap do |robot|
              @robots[uid] = robot
              robot.enter_space @space
            end
          end
        end
        return [{ id: message_id, payload: { robot_id: robot.id } }] if robot
      end
      raise StandardError.new('Could not generate unique robot id')
    end

    def destroy(message_id, content)
      robot = @robots.delete(content['robot_id'])
      [{ id: message_id }].tap do |response|
        response << ({ id: 'robot_exit', payload: { robot_id: robot.id } }) unless robot.not_placed?
        robot.exit_space
      end
    end

    def execute(message_id, content)
      robot = @robots.fetch(content['robot_id'])
      robot.execute_command(content['command'])
      [{ id: message_id }, { id: 'robot_status', payload: robot.status }]
    end
  end
end
