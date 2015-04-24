
var chart = function() {
  var width = 600;
  var height = 600;

  var pillWidth = 200;
  var pillHeight = pillWidth / 5;
  var data = [];
  var margin = {top: 20, right: 20, bottom: 20, left: 20};
  var g = null;

  function pillPath(width, height) {

    var edge = width / 10;
    var halfHeight = height / 2;

    var path = "M 0," + halfHeight;
    path += " l " + edge + "," + (-1 * halfHeight);
    path += " l " + (width - (edge * 2)) + ",0";
    path += " l " + edge + "," + halfHeight;
    path += " l " + (-1 * edge) + "," + halfHeight;
    path += " l " + (-1 * (width - (edge * 2))) + ",0";
    path += " Z";

    return path;
  }

  function splitRect(selection, width, height, colors) {

    selection.selectAll("rect")
      .data(colors).enter()
      .append("rect")
      .attr("x", 0)
      .attr("y", function(d,i) { return (i * height / 2); })
      .attr("width", width)
      .attr("height", height / 2)
      .attr("fill", function(d) { return d; });
  }

  var chart = function(selection) {
    selection.each(function(rawData) {
      var svg = d3.select(this).selectAll("svg").data([data]);
      var gEnter = svg.enter().append("svg").append("g");

      svg.attr("width", width + margin.left + margin.right );
      svg.attr("height", height + margin.top + margin.bottom );

      var defs = svg.append("defs");
      var pill = defs.append("clipPath")
        .attr("id", "pill")
        .append("path")
        .attr("d", pillPath(pillWidth, pillHeight));

      g = svg.select("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

      g.append("g")
        .attr("class", "pill")
        .call(splitRect, pillWidth, pillHeight, ["#ddd","red"])
        .attr("clip-path", "url(#pill)");
    });
  };

  return chart;
};

function plotData(selector, data, plot) {
  d3.select(selector)
    .datum(data)
    .call(plot);
}

$(document).ready(function() {
  var plot = chart();

  function display(error, data) {
    plotData("#vis", data, plot);
  }

  queue()
    .defer(d3.csv, "data/test.csv")
    .await(display);
});
