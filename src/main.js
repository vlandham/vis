require('../index.html');
require('./style');
var queue = require('queue-async');
var d3 = require('d3');
var createPlot = require('./vis');


var plot = createPlot();

function plotData(selector, data, plot) {
  d3.select(selector)
    .datum(data)
    .call(plot);
}

function processData(data) {
  data.forEach((d) => d.count = +d.count)
  return data;
}

function display(error, data) {
  data = processData(data)
  plotData("#vis",  data, plot);
}

queue()
  .defer(d3.csv, "data/segments.csv")
  .await(display);
