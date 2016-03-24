require('../index.html');
require('./style');

require('./menu');

var queue = require('queue-async');
var d3 = require('d3');
var createPlot = require('./vis');
var createSideTable = require('./sidetable');
var createTable = require('./table');
var createBarTable = require('./bartable');
var createGlyphTable = require('./glyphtable');
var createDots = require('./dots');
var createSquare = require('./squares');
var createColorGlyph = require('./glyphcolortable');


function plotData(selector, data, plot) {
  d3.select(selector)
    .datum(data)
    .call(plot);
}

function processData(data) {
  data.forEach((d) => d.count = +d.count)
  return data;
}

var plotType = window.location.hash || '#default';
function display(error, data) {
  data = processData(data)

  var plot;
  if(plotType === '#top') {
    plot = createSideTable();

  } else if(plotType === '#bar') {
    plot = createBarTable();

  } else if(plotType === '#glyph') {
    plot = createGlyphTable();
  } else if(plotType === '#dots') {
    plot = createDots();
  } else if(plotType === '#box') {
    plot = createSquare();
  } else if(plotType === '#glyphcolor') {
    plot = createColorGlyph();
  } else {
    plot = createTable();
  }
  plotData("#vis",  data, plot);
}

queue()
  .defer(d3.csv, "data/segments.csv")
  .await(display);
