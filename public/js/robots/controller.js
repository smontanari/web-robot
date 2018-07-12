module.exports = function(client, viewModel) {
  var self = this;
  var sessionRobotId;
  var placeCommandHandler = function(position) {
    viewModel.inputCommand('place ' + [position.x, position.y, 'north'].join(','));
    self.sendCommand();
  };

  this.enterGame = function() {
    if (viewModel.robotName().length > 0) {
      client.startSession(viewModel.robotName())
      .then(function(robotId) {
        sessionRobotId = robotId;
        viewModel.beginGame(sessionRobotId, placeCommandHandler);
      });
    }
  };

  this.exitGame = function() {
    client.stopSession(sessionRobotId).then(function() {
      viewModel.endGame();
    });
  };

  this.sendCommand = function() {
    var cmd = viewModel.readCommand();
    if (cmd) {
      client.execute(sessionRobotId, cmd.text).catch(
        function(err) { cmd.error(err); }
      );
    }
  };

  ['left', 'right', 'move'].forEach(function(command) {
    self['executeCommand_' + command]  = function() {
      viewModel.inputCommand(command);
      self.sendCommand();
    };
  });
};
