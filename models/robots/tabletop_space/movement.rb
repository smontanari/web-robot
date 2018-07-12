module Robots
  module TabletopSpace
    module Movement
      def enter_space space
        @tabletop = space
      end

      def exit_space
        @tabletop.remove(self)
        @tabletop = nil
        self.current_position = nil
        self.current_facing = nil
      end

      def place x, y, facing
        raise StandardError.new('Robot already in position') if self.current_position
        self.current_facing = facing
        self.current_position = @tabletop.move_to(self, x, y)
      end

      def action_move(step = 1)
        self.send("move_#{self.current_facing.to_s.downcase}".to_sym, step)
      end

      [:action_right, :action_left].each do |action|
        /action_(?<orientation>\w+)/ =~ action
        define_method(action) do
          self.current_facing = self.current_facing.send("rotate_#{orientation}".to_sym)
        end
      end

      private

      def move_north step
        self.current_position = @tabletop.move_to(self, self.current_position.x, self.current_position.y + step)
      end
      def move_east step
        self.current_position = @tabletop.move_to(self, self.current_position.x + step, self.current_position.y)
      end
      def move_south step
        self.current_position = @tabletop.move_to(self, self.current_position.x, self.current_position.y - step)
      end
      def move_west step
        self.current_position = @tabletop.move_to(self, self.current_position.x - step, self.current_position.y)
      end
    end
  end
end
