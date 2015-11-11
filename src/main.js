var queue = require('queue-async');
var d3 = require('d3');
var createPlot = require('./vis');


var plot = createPlot();

function plotData(selector, data, plot) {
  d3.select(selector)
    .datum(data)
    .call(plot);
}

function display(error, data) {
  plotData("#vis",  data, plot);
}

queue()
  .defer(d3.csv, "data/conf_speakers.csv")
  .await(display);
