
var d3 = require('d3');

function getPairs(arr) {
  var pairs = [];
  for (var i = 0; i < arr.length - 1; i++) {
    for (var j = i; j < arr.length - 1; j++) {
      pairs.push([arr[i], arr[j+1]]);
    }
  }
  return pairs;
}

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

function findLinks(nest) {
  var allFolks = [];
  nest.forEach((conf) => {
    conf.values.forEach((year) => {
      allFolks = allFolks.concat(year.values);
      // = d3.map(year.values, d => d.id);


    });
  });
  var byFolk = d3.nest()
    .key(d => d.id)
    .entries(allFolks);

  var pairs = [];
  byFolk.filter(d => d.values.length > 1).forEach((d) => {
    pairs = pairs.concat(getPairs(d.values));
  });
  return pairs;
}

module.exports = function createChart() {
  var width = 900;
  var height = 500;
  var margin = {top: 80, right: 20, bottom: 20, left: 80};
  var g = null;
  var data = [];
  var links = [];
  var conf,year,node;

  var yearScale = d3.scale.ordinal()
    .domain([2013, 2014, 2015, 2016])
    .rangeRoundBands([0, width]);

  var chart = function(selection) {
    selection.each(function(rawData) {
      data = prepareData(rawData);
      links = findLinks(data);

      var svg = d3.select(this).selectAll("svg").data([data]);
      svg.enter().append("svg").append("g");

      svg.attr("width", width + margin.left + margin.right );
      svg.attr("height", height + margin.top + margin.bottom );
      g = svg.select("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

      g.append("g").attr("id", "links");
      g.append("g").attr("id", "nodes");
      update();
    });
  };

  function update() {
    conf = g.select("#nodes").selectAll(".conf")
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

    year = conf.selectAll(".year")
      .data(d => d.values)
      .enter()
      .append("g")
      .attr("class", "year")
      .attr("transform", (d,i) => `translate(${yearScale(d.key)},0)`);

    year.append("text")
      .attr("y", -50)
      .text(d => d.key);

    node = year.selectAll(".node")
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

    addLinks();
  }

  // TODO: UGLY HACK
  // http://stackoverflow.com/questions/26049488/how-to-get-absolute-coordinates-of-object-inside-a-g-group
  function makeAbsoluteContext(element, svgDocument) {
    return function(x,y) {
      var offset = svgDocument.getBoundingClientRect();
      var matrix = element.getScreenCTM();
      return {
        x: (matrix.a * x) + (matrix.c * y) + matrix.e - offset.left,
        y: (matrix.b * x) + (matrix.d * y) + matrix.f - offset.top
      };
    };
  }

  function addLinks() {
    var svgNode = d3.select("svg").node();
    links.forEach((p) => {
      var source = node.filter(e => p[0].conf_id === e.conf_id && p[0].id === e.id);
      var convert = makeAbsoluteContext(source.node(), svgNode);
      var sourceAbs = convert(0,0);
      var target = node.filter(e => p[1].conf_id === e.conf_id && p[1].id === e.id);
      convert = makeAbsoluteContext(target.node(), svgNode);
      var targetAbs = convert(0,0);

      p[0].loc = sourceAbs;
      p[1].loc = targetAbs;

    });
    g.select("#links").selectAll('.link')
      .data(links)
      .enter()
      .append("line")
      .attr("x1", (d) => d[0].loc.x - margin.left)
      .attr("x2", (d) => d[1].loc.x - margin.left)
      .attr("y1", (d) => d[0].loc.y - margin.top)
      .attr("y2", (d) => d[1].loc.y - margin.top)
      .attr("stroke", "#ddd")
      .attr("stroke-width", 1)
      .attr("pointer-events", "none");
  }

  function showName(d,i) {
    var n = node.filter(e => e.id === d.id);
    n.append("text")
      .text(() => d.name)
      .attr("text-anchor", "middle")
      .attr("dy", 20);
    n.select("circle")
      .classed("highlight", true);
  }

  function hideName(d,i) {
    node.select("text")
      .remove();
    node
      .select("circle")
      .classed("highlight", false);
  }

  return chart;
};
