
var Shape = require('./shape');
var TWEEN = require('tween.js');

module.exports = function createSpin() {
  var width, height;
  var dispatch;
  var shapes = [];

  var s = function setup(scene, data) {
    dispatch.addEventListener('spin', spin);
    data.forEach(function(i) {
      var shape = new Shape(i);
      shapes.push(shape);
      scene.add(shape);
    });

  };

  s.update = function() {
    shapes.forEach(function(shape){
      shape.update();
    });
    TWEEN.update();
  };

  function spin() {

    shapes.forEach(function(shape){
      shape.spin();
    });
  }


  s.dispatch = function(_) {
    if (!arguments.length) {
      return dispatch;
    }
    dispatch = _;
    return s;
  };

  s.width = function(_) {
    if (!arguments.length) {
      return width;
    }
    width = _;
    return s;
  };

  s.height = function(_) {
    if (!arguments.length) {
      return height;
    }
    width = _;
    return s;
  };


  return s;
};
