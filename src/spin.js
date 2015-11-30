
var Shape = require('./shape');
var TWEEN = require('tween.js');
var THREE = require('three.js');

module.exports = function createSpin() {
  var width, height;
  var dispatch;
  var shapes = [];

  var s = function setup(scene, data) {
    dispatch.addEventListener('spin', spin);
    var padding = 15;

    var pos = new THREE.Vector3(-Shape.width - padding, 0, 0);
    data.forEach(function(i) {

      var shape = new Shape(pos, i);
      pos.x += Shape.width + padding;
      // pos.z += Shape.width + padding;

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
    //
    // var gif = new GIF({
    //   workers: 2,
    //   quality: 10
    // });
    // var canvasElement = document.getElementsByTagName('canvas')[0];
    // gif.addFrame(canvasElement, {delay: 200});
    // gif.on('finished', function(blob) {
    //   window.open(URL.createObjectURL(blob));
    // });
    // gif.render();

    shapes.forEach(function(shape, i){
      shape.spin(i * 200);
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
