require_relative 'tabletop_space/movement'
require_relative 'tabletop_space/facing'
require_relative 'tabletop_space/dsl_support'
require_relative 'tabletop_space/tabletop'

module Robots
  module TabletopSpace
    include TabletopSpace::Movement
    include TabletopSpace::DSLSupport
  end
end
