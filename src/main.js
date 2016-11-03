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

function cleanData(rawData) {
  rawData.forEach(function(datum) {
    datum.values.forEach(function(value) {
      var dateValues = value.time.split('-');
      var currentYear = new Date().getFullYear();
      value.date = new Date(currentYear, (+dateValues[0] - 1), +dateValues[1])
    });
  });
  return rawData;
}

function display(error, data) {
  data =  cleanData(data);
  d3.select('#vis')
    .selectAll('.chart')
    .data(data)
    .enter()
    .append('div')
    .classed('chart', true)
    .each(function(d, i) {
      plotData(this, d, plot);
    });
}

queue()
  .defer(d3.json, "data/seasons.json")
  .await(display);
