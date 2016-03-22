
var d3 = require('d3');

var fish = require('../lib/fisheye');

var fisheye = d3.fisheye.circular()
    .radius(200)
    .distortion(2);

module.exports = function createChart() {
  var width = 500;
  var height = 1000;
  var g = null;
  var data = [];


  var yScale = d3.scale.ordinal();

  var wScale = d3.scale.pow().exponent(0.3)
    .domain([0, 100]).range([400, 5]).clamp(true);

  var fScale = d3.scale.pow().exponent(0.3)
    .domain([0, 100]).range([20, 0]).clamp(true);

  var hScale = d3.scale.pow().exponent(0.3)
    .domain([0, 100]).range([20, 5]).clamp(true);

  var chart = function(selection) {
    selection.each(function(rawData) {

      console.log(rawData);

      data = rawData;

      var svg = d3.select(this).selectAll("svg").data([data]);
      svg.enter().append("svg").append("g");

      svg.attr("width", width);
      svg.attr("height", height);
      g = svg.select("g");

      yScale.domain(data.map((d) => d.name))
        .rangeBands([30, height]);

      update();
      d3.select('body').on('mousemove', mousemove);
    });
  };

  function update() {
    var techG = g.selectAll(".tech")
      .data(data);

    var techE = techG.enter()
      .append("g")
      .attr("class", "tech")
      // .attr('transform', (d) => 'translate('+ 0 +','+ yScale(d.name) + ')')

    techE.append('rect')
      .attr("fill", "steelblue")
      .attr("x", 0)
      .attr("y", d => yScale(d.name))
      .attr("width", 10)
      .attr("height", yScale.rangeBand())
      .on("mouseover", function(d) { d3.select(this).attr("fill", "orange"); })
      .on("mouseout", function(d) { d3.select(this).attr("fill", "steelblue"); });

    techE.append('text')
      .attr('dx', 5)
      .attr('dy', (yScale.rangeBand() / 2))
      .style('font-size', 5)
      .attr('pointer-events', 'none')
      .attr("x", 0)
      .attr("y", d => yScale(d.name))
      .text((d) => d.name)
  }

  function mouseover(d,i) {

  }

  function mousemove() {
    // var e = d3.event;

    var c = d3.mouse(g.node());

    fisheye.focus(d3.mouse(g.node()));

    var tS = g.selectAll('.tech')
      .each((d, i) => {
        var y = yScale(d.name);
        var dy = y - c[1];
        var dist = Math.abs(dy);
        d.dist = dist;
        d.w = wScale(dist);
        d.h = hScale(dist);
        d.y = dy > 0 ? y + (d.h / 2) : y - (d.h / 2) ;
        // d.fisheye = fisheye(d);

      })
      tS.select('rect')
        .attr('y', (d) => d.y)
        .attr('width', (d) => d.w)
        .attr('height', (d) => d.h);

      tS.select('text')
        .style('font-size', (d) => fScale(d.dist))
        .attr('y', (d) => d.y)
        .attr('dy', (d) => d.h / 2)

    console.log(c);
  }

  return chart;
};
