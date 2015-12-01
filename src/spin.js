
var Shape = require('./shape');
var TWEEN = require('tween.js');
var THREE = require('three.js');
var utl = require('./utility');
var d3 = require('d3');

module.exports = function createSpin() {
  var width, height;
  var dispatch;
  var shapes = [];

  function prepareData(rdata) {
    var data = utl.textToSentences(rdata).map(function(s) { return utl.stringToWords(utl.removePunctuation(s)); });

    return data;
  }

  var s = function setup(scene, rdata) {
    var data = prepareData(rdata);
    data = data.slice(1,20);
    var maxLength = d3.max(data, function(s) { return s.length; });
    dispatch.addEventListener('spin', spin);
    var padding = 15;

    var sizeScale = d3.scale.sqrt().range([5, 40])
      .domain([0,15]);

    var startX = -1 * ((maxLength / 2) * (Shape.width + padding));
    var startY = (data.length / 2) * (Shape.height + padding);
    var pos = new THREE.Vector3(startX, startY, 0);
    data.forEach(function(sentence, yi) {
      sentence.forEach(function(word, xi) {

        var d = {"word":word, "size":sizeScale(word.length), xi: xi, yi:yi};

        var shape = new Shape(pos, d);
        pos.x += Shape.width + padding;
        // pos.z += Shape.width + padding;

        shapes.push(shape);
        scene.add(shape);

      });
      pos.x = startX;
      pos.y -= Shape.height + padding;
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
      shape.spin(shape.data.xi * 200);
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
