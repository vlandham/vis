require('./scss/pure.css');
require('./scss/style.scss');

var queue = require('queue-async');
var d3 = require('d3');
var THREE = require('three.js');

var dispatch = new THREE.EventDispatcher();

var createScene = require('./scene');



// function plotData(selector, data, plot) {
//   d3.select(selector)
//     .datum(data)
//     .call(plot);
// }

var scene = createScene()
  .dispatch(dispatch);

scene.setup();

function display(error, data) {
  scene.data(data);
}

queue()
  .defer(d3.csv, "data/test.csv")
  .await(display);

d3.select("#menu a").on("click", function() {
  dispatch.dispatchEvent({type: 'grid'})
  d3.event.preventDefault();

});
