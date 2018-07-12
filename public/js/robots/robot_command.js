var ko = require('knockout');

module.exports = function(text) {
  this.text = text;
  this.error = ko.observable(null);
};
