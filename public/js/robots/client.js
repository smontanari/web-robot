var CanvasRobot   = require('./canvas_robot.js'),
    MessageBroker = require('./message_broker.js');

module.exports = function(gridUpdateHandler) {
  var broker = new MessageBroker();

  broker.subscribe(['robot_status', 'robot_exit'], function(eventName, data) {
    gridUpdateHandler[eventName](data);
  });

  broker.connect().then(function() {
    return broker.sendMessage('list');
  }).then(gridUpdateHandler.robot_list);

  this.startSession = function(name) {
    return broker.sendMessage('create', { name: name })
      .then(function(data) { return data.robot_id; });
  };

  this.stopSession = function(sessionRobotId) {
    return broker.sendMessage('destroy', { robot_id: sessionRobotId })
      .then(function() { sessionRobotId = null; });
  };

  this.execute = function(sessionRobotId, command) {
    return broker.sendMessage('execute', { robot_id: sessionRobotId, command: command });
  };
};
