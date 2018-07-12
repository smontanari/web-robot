var ko = require('knockout');

var ViewModel         = require('./view_model.js'),
    Grid              = require('./canvas_grid.js'),
    GameContext       = require('./game_context.js'),
    Client            = require('./client.js'),
    Controller        = require('./controller.js'),
    GridUpdateHandler = require('./grid_update_handler.js');

module.exports.run = function() {
  var canvasElement = document.querySelector('canvas');
  var grid = new Grid(canvasElement);
  var gameContext = new GameContext(grid);

  var gridUpdateHandler = new GridUpdateHandler(gameContext);
  var viewModel = new ViewModel(gameContext);
  var client = new Client(gridUpdateHandler);
  window.controller = new Controller(client, viewModel);

  ko.applyBindings(viewModel);
};
