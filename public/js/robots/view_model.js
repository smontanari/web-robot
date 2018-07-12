var ko                 = require('knockout'),
    NotificationWidget = require('./notification_widget.js'),
    RobotCommand       = require('./robot_command.js'),
    Constants          = require('./constants.js');

module.exports = function(gameCtx) {
  this.robotName = ko.observable('');
  this.inputCommand = ko.observable('');
  this.isConnected = ko.observable(false);
  this.allCommands = ko.observableArray();
  this.notification = new NotificationWidget();

  gameCtx.allowNotifications(this.notification.fadeInOut.bind(this.notification));

  this.beginGame = function(myRobotId, placeCommandHandler) {
    this.isConnected(true);
    gameCtx.initialize(myRobotId, placeCommandHandler);
  };

  this.endGame = function() {
    this.robotName('');
    this.isConnected(false);
    this.allCommands([]);
    gameCtx.myRobot(null);
  };

  this.readCommand = function() {
    var cmdInput = this.inputCommand();
    if (cmdInput.length > 0) {
      var robotCommand = new RobotCommand(cmdInput);
      this.allCommands.unshift(robotCommand);
      if (this.allCommands().length > Constants.MAX_COMMAND_LOG_SIZE) {
        this.allCommands.pop();
      }
      this.inputCommand('');
      return robotCommand;
    }
    return null;
  };

  this.isMyRobotOnGrid = ko.pureComputed(function() {
    var robot = gameCtx.myRobot();
    return robot && robot.direction() !== null;
  });

  this.myRobotDirection = ko.pureComputed(function() {
    var robot = gameCtx.myRobot();
    if (robot) {
      return 'move-' + robot.direction().toLowerCase();
    }
    return '';
  });
};
