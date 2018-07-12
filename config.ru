require 'logger'
require_relative 'app'
require_relative 'middleware/robot_control'

logger = ::Logger.new(STDOUT)

use Rack::CommonLogger, logger
use WebRobot::RobotControl, logger

run WebRobot::App
