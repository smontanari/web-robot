module Robots
  module TabletopSpace
    module Facing
      DIRECTIONS = [:North, :East, :South, :West]
      DIRECTIONS.each do |direction|
        face = Object.new
        const_set direction, face
        face.instance_eval do
          @name = direction

          def rotate_right
            Facing.const_get DIRECTIONS.rotate(DIRECTIONS.index(@name) + 1).first
          end
          def rotate_left
            Facing.const_get DIRECTIONS[DIRECTIONS.index(@name) - 1]
          end
          def to_s
            @name.to_s.upcase
          end
        end
      end
    end
  end
end
