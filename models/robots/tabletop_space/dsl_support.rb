module Robots
  module TabletopSpace
    module DSLSupport
      [:north, :east, :south, :west].each do |name|
        define_method(name) {Facing.const_get(name.capitalize)}
      end

      def find_movement_action method
        /^(?<action_name>move|right|left)$/ =~ method
        action_name
      end
    end
  end
end
