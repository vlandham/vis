
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

      data = rawData;

      var svg = d3.select(this).selectAll("svg").data([data]);
      svg.enter().append("svg").append("g");

      svg.attr("width", width + margin.left + margin.right );
      svg.attr("height", height + margin.top + margin.bottom );
      g = svg.select("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
      update();
    });
  };

  function update() {
    g.selectAll(".rect")
      .data(data)
      .enter()
      .append("rect")
      .attr("class", "rect")
      .attr("fill", "steelblue")
      .attr("x", d => d.x * 10)
      .attr("y", d => d.y * 10)
      .attr("width", 10)
      .attr("height", 10);
      // .on("mouseover", d => d3.select(this).attr("fill", "orange"));
  }

  return chart;
};
