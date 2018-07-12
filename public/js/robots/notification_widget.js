var ko = require('knockout');

module.exports = function() {
  var self = this;
  var fadeCounter = 0;

  this.top = ko.observable('0px');
  this.left = ko.observable('0px');
  this.content = ko.observable();
  this.isVisible = ko.observable(false);

  this.fadeInOut = function(content, position) {
    if (this.isVisible()) {
      this.isVisible(false);
    }
    fadeCounter++;
    this.content(content);
    this.left(position.x + 'px');
    this.top(position.y + 'px');
    this.isVisible(true);
    setTimeout(function() {
      if (fadeCounter == 1) {
        self.isVisible(false);
      }
      fadeCounter--;
    }, 1500);
  };
};
