
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

  var order = ['visualized', 'eyeo', 'tapestry', 'openvis'];

  var nest = d3.nest()
    .key(d => d.conf)
    .sortKeys((a,b) => order.indexOf(a) - order.indexOf(b))
    .key(d => d.year)
    .sortKeys(d3.ascending)
    .entries(data);

  return nest;
}

function groupByPeople(nest) {
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
  return byFolk;
}

function generateLinks(byFolk) {
  var pairs = [];
  byFolk.filter(d => d.values.length > 1).forEach((d) => {
    pairs = pairs.concat(getPairs(d.values));
  });
  return pairs;
}

module.exports = function createChart() {
  var width = 900;
  var height = 500;
  var margin = {top: 70, right: 90, bottom: 20, left: 80};
  var g = null;
  var data = [];
  var folks = {};
  var links = [];
  var conf,year,node;

  var radius = 6;
  var space = 1;
  var rowCount = 22;

  var yearScale = d3.scale.ordinal()
    .domain([2013, 2014, 2015])
    .rangeRoundBands([0, width]);

  var chart = function(selection) {
    selection.each(function(rawData) {
      data = prepareData(rawData);
      folks = groupByPeople(data);
      links = generateLinks(folks);
      folks = d3.map(folks, (d) => d.key);

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
      .attr("text-anchor", "end")
      .attr("dx", -12)
      .attr("dy", 4);

    conf.append("line")
      .attr("x1", 0)
      .attr("x2", width)
      .attr("y1", 0)
      .attr("y2", 0)
      .attr("opacity", 0.2)
      .style("stroke-width", 1);

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
      .each((d,i) => {
        d.row = Math.floor(i / rowCount);
        d.col = (i % rowCount);
        d.count = folks.get(d.id).values.length;
      })
      .attr("class", "node")
      .attr("transform", (d,i) => {
        var x = d.col * (radius * 2 + space);
        var y = d.row * (radius * 2 + space);
        return `translate(${x},${y})`;
      });
    node.append("circle")
      .attr("r", radius)
      .attr("cx", 0)
      .attr("cy", 0)
      .attr("opacity", (d) => 0.2 + (0.2 * d.count));
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
    // var line = d3.svg.line()
    //   .x(function(d) { return d.loc.x - margin.left; })
    //   .y(function(d) { return d.loc.y - margin.top; })
    //   .interpolate("cardinal");

    var diag = d3.svg.diagonal()
      .source((d) => d[0].loc)
      .target((d) => d[1].loc)
      .projection((d) => [d.x - margin.left, d.y - margin.top]);

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
      .data(links.filter(d => d[0].conf !== d[1].conf))
      .enter()
      .append("path")
      .attr("class", "link")
      .attr("stroke", "#ddd")
      .attr("fill", "none")
      .attr("stroke-width", 1)
      .attr("pointer-events", "none")
      .attr("d", diag);

    // g.select("#links").selectAll('.link')
    //   .data(links)
    //   .enter()
    //   .append("line")
    //   .attr("x1", (d) => d[0].loc.x - margin.left)
    //   .attr("x2", (d) => d[1].loc.x - margin.left)
    //   .attr("y1", (d) => d[0].loc.y - margin.top)
    //   .attr("y2", (d) => d[1].loc.y - margin.top)
    //   .attr("stroke", "#ddd")
    //   .attr("stroke-width", 1)
    //   .attr("pointer-events", "none");
  }

  function showName(d,i) {
    var n = node.filter(e => e.id === d.id);
    n.append("text")
      .text(() => d.name)
      .attr("text-anchor", "middle")
      .attr("y", (e) => e.row * (radius * 2) * -1)
      .attr("dy", -10);
    n.select("circle")
      .classed("highlight", true);
    g.select("#links").selectAll(".link").filter(e => {
      return e[0].id === d.id;
    })
      .each(e => console.log(e))
      .classed("highlight", true);
  }

  function hideName(d,i) {
    node.select("text")
      .remove();
    node
      .select("circle")
      .classed("highlight", false);
    g.select("#links").selectAll(".link")
      .classed("highlight", false);
  }

  return chart;
};
