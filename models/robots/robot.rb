module Robots
  class Robot
    include CommandDSLEnabled
    include TabletopSpace
    attr_reader :id
    attr_accessor :current_position, :current_facing

    def initialize(id, name)
      @id = id
      @name = name
    end

    def method_missing method, *args
      action_name = find_movement_action(method)
      super if action_name.nil?
      raise StandardError, 'Robot not placed on the map' if not_placed?
      self.send("action_#{action_name}".to_sym, *args)
    end

    def status
      {
        robot_id: @id,
        name: @name,
        position: current_position.to_h,
        facing: current_facing
      }
    end

    def not_placed?
      current_position.nil?
    end
  end
end
