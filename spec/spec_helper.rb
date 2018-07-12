require_relative 'support/struct_matcher'
require_relative '../middleware/robot_control'
require_relative '../middleware/robots_store'
require_relative '../models/robots'

Robots::Matchers.define_struct_matcher :be_a_tabletop_position, Robots::TabletopSpace::Position
