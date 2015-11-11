
var d3 = require('d3');

function prepareData(rawData) {
  var data = rawData.map(rd => {
    var d = {};
    d.conf_id = rd.conf_id;
    d.conf = rd.conf;
    d.year = +rd.year;
    d.name = rd.name;
    d.id = rd.id;

    return d;
  });

  var nest = d3.nest()
    .key(d => d.conf)
    .key(d => d.year)
    .sortKeys(d3.ascending)
    .entries(data);

  return nest;
}

module.exports = function createChart() {
  var width = 900;
  var height = 500;
  var margin = {top: 80, right: 20, bottom: 20, left: 80};
  var g = null;
  var data = [];

  var yearScale = d3.scale.ordinal()
    .domain([2013, 2014, 2015, 2016])
    .rangeRoundBands([0, width]);

  var chart = function(selection) {
    selection.each(function(rawData) {
      data = prepareData(rawData);

      console.log(data);

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
    var conf = g.selectAll(".conf")
      .data(data)
      .enter()
      .append("g")
      .attr("class", (d) => `conf ${d.key}`)
      .attr("transform", (d,i) => `translate(0,${i * (height / data.length)})`);

    conf.append("text")
      .text(d => d.key)
      .attr("text-anchor", "end");

    conf.append("line")
      .attr("x1", 0)
      .attr("x2", width)
      .attr("y1", 0)
      .attr("y2", 0)
      .style("stroke-width", "2");

    var year = conf.selectAll(".year")
      .data(d => d.values)
      .enter()
      .append("g")
      .attr("class", "year")
      .attr("transform", (d,i) => `translate(${yearScale(d.key)},0)`);

    year.append("text")
      .attr("y", -50)
      .text(d => d.key);

    var node = year.selectAll(".node")
      .data(d => d.values)
      .enter()
      .append('g')
      .attr("class", "node")
      .attr("transform", (d,i) => `translate(${i * yearScale.rangeBand() / 20},0)`);
    node.append("circle")
      .attr("r", 6)
      .attr("cx", 0)
      .attr("cy", 0);
    node.on("mouseover", showName);
    node.on("mouseout", hideName);
  }

  function showName(d,i) {
    d3.select(this).append("text")
      .text(() => d.name)
      .attr("text-anchor", "middle")
      .attr("dy", 20);

  }

  function hideName(d,i) {
    d3.select(this).select("text")
      .remove();

  }

  return chart;
};
