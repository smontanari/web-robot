(function() {
  window.System.config({
    map: {
      knockout: '/lib/knockout-latest.js'
    }
  });
  window.System.import('/js/robots/bootstrap.js').then(function(module) { module.run(); });
})();
