var ko          = require('knockout');
var CanvasRobot = require('./canvas_robot.js');

module.exports = function(grid) {
  var robotsCollection = [];
  var myRobotId = null;

  this.myRobot = ko.observable(null);

  this.allowNotifications = function(handler) {
    grid.notificationHandler(handler);
  };

  this.initialize = function(id, placeCommandHandler) {
    myRobotId = id;
    grid.enablePlacing(placeCommandHandler);
  };

  this.setStatus = function(robotsStatus) {
    robotsCollection = robotsStatus.map(function(status) {
      return new CanvasRobot(grid, status);
    });
  };

  this.addRobot = function(data) {
    var robot = new CanvasRobot(grid, data, data.robot_id === myRobotId);
    robotsCollection.push(robot);
    if (robot.isMyRobot) {
      grid.disablePlacing();
      this.myRobot(robot);
    }
    return robot;
  };

  this.removeRobot = function(id) {
    var robot = this.robotById(id);
    if (robot !== undefined) {
      robot.erase();
      robotsCollection = robotsCollection.filter(function(r) { return r.id !== robot.id; });
    }
  };

  this.robotById = function(id) {
    return robotsCollection.find(function(r) { return r.id === id });
  };
};
