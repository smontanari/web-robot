module Robots
  module TabletopSpace
    class Position < Struct.new(:x, :y)
      def to_s
        "#{self.x},#{self.y}"
      end
    end
  end
end