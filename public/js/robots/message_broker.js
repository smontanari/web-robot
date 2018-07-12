module.exports = function(cmdErrorHandler) {
  var socket;
  var messageResolvers = {};
  var eventSubscribers = {};

  var uuid = function() {
    function _p8(s) {
      var p = (Math.random().toString(16)+"000000000").substr(2,8);
      return s ? "-" + p.substr(0,4) + "-" + p.substr(4,4) : p ;
    }
    return _p8() + _p8(true) + _p8(true) + _p8();
  };

  var handleError = function(err) {
    console.log('web socket error', err);
  };

  var receiveMessage = function(msg) {
    var message = JSON.parse(msg.data);
    resolveFn = messageResolvers[message.id];
    eventCallback = eventSubscribers[message.id];
    if (resolveFn) {
      console.info('Received response:', message);
      resolveFn(message);
      delete messageResolvers[message.id];
    } else if (eventCallback) {
      console.info('Received event:', message);
      eventCallback(message.id, message.payload);
    } else {
      console.error('Received unknown message:', message);
    }
  };

  this.connect = function(event) {
    return new Promise(function(resolve, reject) {
      if (socket === undefined || socket.readyState === WebSocket.CLOSED || socket.readyState === WebSocket.CLOSING) {
        try {
          socket = new WebSocket('ws://' + window.document.location.host + '/');
          socket.onerror = handleError;
          socket.onmessage = receiveMessage;
          socket.onopen = function(event) {
            console.log('Connection established: ', event);
            resolve();
          };
        } catch(e) {
          reject(e);
        }
      } else {
        resolve();
      }
    });
  };

  this.subscribe = function(events, callback) {
    events.forEach(function(eventName) {
      eventSubscribers[eventName] = callback;
    });
  };

  this.sendMessage = function(action, content) {
    return new Promise(function(resolve, reject) {
      var message = {
        id: uuid(),
        payload: { action: action, content: content }
      };
      try {
        console.info('Sending message:', message);
        socket.send(JSON.stringify(message));
      } catch(ex) {
        handleError(ex);
        reject(ex);
      }
      messageResolvers[message.id] = function(msg) {
        if (msg.payload) {
          resolve(msg.payload);
        } else if (msg.error) {
          reject(msg.error);
        } else {
          resolve();
        }
      };
    });
  };
};
