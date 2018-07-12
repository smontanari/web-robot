module.exports = function(gameCtx) {
  this.robot_status = function(data) {
    var robot = gameCtx.robotById(data.robot_id);
    if (robot === undefined) {
      robot = gameCtx.addRobot(data);
    } else {
      robot.move(data.position, data.facing);
    }
  };

  this.robot_exit = function(data) {
    gameCtx.removeRobot(data.robot_id);
  };

  this.robot_list = function(data) {
    gameCtx.setStatus(data);
  };
};
