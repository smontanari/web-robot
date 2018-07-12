var Constants = require('./constants.js');

var ROBOT_IMG_ROTATION = {
  NORTH: -Math.PI / 2,
  EAST: 0,
  SOUTH: Math.PI / 2,
  WEST: Math.PI
};

var GRID_UNIT_SIZE = Constants.CANVAS_SIZE / Constants.GRID_CELL_SIZE;

var GridCell = function(ctx, x, y) {
  this.gridPosition = { x: x + 1, y: 10 - y };
  this.ctx = ctx;
  this.x = x * Constants.GRID_CELL_SIZE;
  this.y = y * Constants.GRID_CELL_SIZE;
  this.w = Constants.GRID_CELL_SIZE;
  this.h = Constants.GRID_CELL_SIZE;
  this.robot = null;
};

GridCell.prototype.highlight = function() {
  this.ctx.clearRect(this.x, this.y, this.w, this.h);
  this.ctx.setLineDash([]);
  this.ctx.strokeStyle = 'white';
  this.ctx.lineWidth = 2;
  this.ctx.strokeRect(this.x, this.y, this.w, this.h);
};
GridCell.prototype.releaseRobot = function() {
  this.robot = null;
  this.ctx.clearRect(this.x + 1, this.y + 1, (this.w - 2), (this.h - 2));
};
GridCell.prototype.putRobot = function(robot) {
  this.robot = robot;
  this.drawRobot();
};
GridCell.prototype.taken = function() {
  return this.robot !== null;
};
GridCell.prototype.drawRobot = function() {
  this.ctx.save();
  this.ctx.translate(this.x, this.y);
  this.ctx.translate(25, 25);
  this.ctx.rotate(ROBOT_IMG_ROTATION[this.robot.direction()]);
  this.ctx.drawImage(this.robot.robotImage, -24, -24, 48, 48);
  this.ctx.restore();
};

var Grid = function(canvasElement) {
  var self = this;
  canvasElement.width = Constants.CANVAS_SIZE;
  canvasElement.height = Constants.CANVAS_SIZE;

  var ctx = canvasElement.getContext('2d');
  var placeCommandHandler;

  var gridCells = [];
  for (var x = 0; x < GRID_UNIT_SIZE; x++) {
    gridCells[x] = [];
    for (var y = 0; y < GRID_UNIT_SIZE; y++) {
      gridCells[x][y] = new GridCell(ctx, x, y);
    }
  };

  var withGridMouseCell = function(eventTarget, handler) {
    var [x, y] = [eventTarget.offsetX, eventTarget.offsetY]
      .map(function(mouseCoordinate) {
        return Math.floor(mouseCoordinate / Constants.GRID_CELL_SIZE);
      })
      .filter(function(coordinate) {
        return (coordinate >= 0 && coordinate < GRID_UNIT_SIZE);
      });

    if (x !== undefined && y !== undefined) {
      handler(gridCells[x][y]);
    }
  };

  var reset = function() {
    ctx.clearRect(0, 0, Constants.CANVAS_SIZE, Constants.CANVAS_SIZE);
    ctx.setLineDash([3, 3]);
    ctx.strokeStyle = 'black';
    ctx.lineWidth = 0.5;
    for (var index = 0; index < GRID_UNIT_SIZE; index++) {
      ctx.beginPath();
      ctx.moveTo(Constants.GRID_CELL_SIZE * (index + 1), 0);
      ctx.lineTo(Constants.GRID_CELL_SIZE * (index + 1), Constants.CANVAS_SIZE);
      ctx.moveTo(0, Constants.GRID_CELL_SIZE * (index + 1));
      ctx.lineTo(Constants.CANVAS_SIZE, Constants.GRID_CELL_SIZE * (index + 1));
      ctx.stroke();
      ctx.closePath();
    }
    gridCells.forEach(function(cellRow) {
      cellRow.forEach(function(c) {
        if (c.taken()) {
          c.drawRobot();
        }
      });
    });
  };

  var highlight = function(cell) {
    if (cell.taken()) {
      return;
    }
    reset();
    cell.highlight();
  };

  var onMouseOut = function(event) {
    reset();
  };

  var onMouseMove = function(event) {
    withGridMouseCell(event, highlight);
  };
  var onCellDblClick = function(event) {
    withGridMouseCell(event, function(cell) {
      if (!cell.taken()) {
        reset();
        placeCommandHandler(cell.gridPosition);
      }
    });
  };

  this.notificationHandler = function(handler) {
    canvasElement.addEventListener('click', function(event) {
      var mousePosition = { x: event.clientX, y: event.clientY };
      withGridMouseCell(event, function(cell) {
        if (cell.taken()) {
          handler(cell.robot.name, mousePosition);
        }
      });
    });
  };

  this.placeRobot = function(position, robot) {
    var cell = gridCells[position.x - 1][GRID_UNIT_SIZE - position.y];
    cell.putRobot(robot);
    return cell;
  };

  this.enablePlacing = function(handler) {
    placeCommandHandler = handler;
    canvasElement.addEventListener('mouseout', onMouseOut);
    canvasElement.addEventListener('mousemove', onMouseMove);
    canvasElement.addEventListener('dblclick', onCellDblClick);
  };

  this.disablePlacing = function() {
    canvasElement.removeEventListener('mouseout', onMouseOut);
    canvasElement.removeEventListener('mousemove', onMouseMove);
    canvasElement.removeEventListener('dblclick', onCellDblClick);
  };

  reset();
};

module.exports = Grid;
