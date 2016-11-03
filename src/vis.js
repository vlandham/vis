
var d3 = require('d3');

module.exports = function createChart() {
  var width = 500;
  var height = 100;
  var margin = {top: 20, right: 20, bottom: 25, left: 20};
  var g = null;
  var data = [];

  var colors = d3.scale.category20();

  var yScale = d3.scale.linear()
    .domain([0.0, 1.0])
    .range([height, 0]);

  var currentYear = new Date().getFullYear();

  var dateMin = new Date(currentYear, 0, 1);
  var dateMax = new Date(currentYear, 11, 1);

  var xScale = d3.time.scale()
    .domain([dateMin, dateMax])
    .range([0, width])

  var xAxis = d3.svg.axis()
    .scale(xScale)
    .orient("bottom")
    .tickFormat(d3.time.format("%b"));

  var area = d3.svg.area()
    .x(function(d) { return xScale(d.date); })
    .y0(height)
    .y1(function(d) { return yScale(d.amount); })
    .interpolate("basis");


  var chart = function(selection) {
    selection.each(function(rawData) {

      data = rawData;

      var svg = d3.select(this).selectAll("svg").data([data]);
      svg.enter().append("svg").append("g");

      svg.attr("width", width + margin.left + margin.right );
      svg.attr("height", height + margin.top + margin.bottom );
      g = svg.select("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

      g.append('text')
        .classed('title', true)
        .attr('font-size', '20px')
        .text(function(d) { return d.name; });

      g.append("path")
        .datum(data)
        .attr("class", "area")
        .attr("fill", function(d) { return (d.color) ? d.color : colors(d.name)})
        .attr("d", function(d) { return area(d.values); } );

      g.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis);

    });
  };


  return chart;
};
