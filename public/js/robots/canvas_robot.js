var ko        = require('knockout');
var Constants = require('./constants.js');

var blueRobotImage = new Image();
var redRobotImage = new Image();
blueRobotImage.src = Constants.IMG_BLUE_ROBOT;
redRobotImage.src = Constants.IMG_RED_ROBOT;

var CanvasRobot = function(grid, data, isMyRobot) {
  this.grid = grid;
  this.robotImage = isMyRobot ? redRobotImage : blueRobotImage;
  this.id = data.robot_id;
  this.name = data.name;
  this.direction = ko.observable(null);
  this.isMyRobot = isMyRobot;
  this.place(data.position, data.facing);
};

CanvasRobot.prototype.place = function(position, facing) {
  this.direction(facing);
  this.cellPosition = position;
  this.gridCell = this.grid.placeRobot(position, this);
};

CanvasRobot.prototype.erase = function() {
  this.gridCell.releaseRobot();
};

CanvasRobot.prototype.move = function(position, facing) {
  this.erase();
  this.place(position, facing);
};

module.exports = CanvasRobot;
