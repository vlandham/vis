
var d3 = require('d3');

module.exports = function createChart() {
  var width = 500;
  var height = 500;
  var margin = {top: 20, right: 20, bottom: 20, left: 20};
  var g = null;
  var data = [];

  var chart = function(selection) {
    selection.each(function(rawData) {

      console.log(rawData);

      var svg = d3.select(this).selectAll("svg").data([data]);
      svg.enter().append("svg").append("g");

      svg.attr("width", width + margin.left + margin.right );
      svg.attr("height", height + margin.top + margin.bottom );
      g = svg.select("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
    });
  };

  return chart;
};
