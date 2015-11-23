require('./scss/style.scss');

var queue = require('queue-async');
var d3 = require('d3');

var createScene = require('./scene');



// function plotData(selector, data, plot) {
//   d3.select(selector)
//     .datum(data)
//     .call(plot);
// }

var scene = createScene();
scene.setup();

function display(error, data) {
  scene.data(data);
}

queue()
  .defer(d3.csv, "data/test.csv")
  .await(display);
