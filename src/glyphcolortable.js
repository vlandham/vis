
require('../scss/glyphcolortable.scss');
var d3 = require('d3');

module.exports = function createChart() {
  var width = 500;
  var height = 800;
  var table = null;
  var data = [];


  var yScale = d3.scale.ordinal();

  var fScale = d3.scale.pow().exponent(0.5)
    .domain([0, 100]).range([30, 6]).clamp(true);

  var alphaScale = d3.scale.pow().exponent(0.5)
    .domain([0, 100]).range([1.0, 0]).clamp(true);

  var restScale = d3.scale.linear().range([5, 10])

  // var colorScale = d3.scale.quantize()
    // .range(["#fee5d9","#fcae91","#fb6a4a","#de2d26","#a50f15"])
    // .range(['#ffffe0', '#ffe0a9', '#ffbe84', '#ff986d', '#f47361', '#e35056', '#cb2f44', '#ae112a', '#8b0000'])
    // .range(['#ffa500', '#ff8941', '#f86f53', '#ed5557', '#de3f53', '#cd2a47', '#b81736', '#a2051f', '#8b0000'])
    // .range(['#ffa500', '#e28101', '#c55e01', '#a83802', '#8b0000'])

  var colorScale = d3.scale.linear()
    // .range(["#fee5d9", "#a50f15"])
    // .range(["#fef0d9", "#b30000"])
    .range(["#fdd49e", "#b30000"])


  var chart = function(selection) {
    selection.each(function(rawData) {

      console.log(rawData);

      data = rawData.filter((d,i) => i < 100);

      data.forEach((d) => {
        d.glyph = d.name.slice(0,2);
        d.remainder = d.name.slice(2);
      });

      data = data.sort((a,b) => d3.ascending(a.name, b.name));

      // var svg = d3.select(this).append('svg')
      // svg.attr("width", width);
      // svg.attr("height", height);
      // var fo = svg.append('foreignObject')
      // fo.attr("width", width);
      // fo.attr("height", height);
      // fo.attr('x', 0)
      // fo.attr('y', 0)
      // fo = fo.append('xhtml:body');
      // fo.attr("xmlns", "http://www.w3.org/1999/xhtml")


      table = d3.select(this).selectAll("table").data([data]);
      table.enter().append("table")
        .classed('glyphcolortable', true)

      yScale.domain(data.map((d) => d.name))
        .rangeBands([30, height]);

      restScale.domain(d3.extent(data, (d) => d.count));
      colorScale.domain([0, d3.max(data, (d) => d.count)])

      update();
      d3.select('body').on('mousemove', mousemove);
    });
  };

  function update() {
    var techG = table.selectAll(".tech")
      .data(data);

    var techE = techG.enter()
      .append("tr")
      .attr("class", "tech")
      .style('font-size', (d) => fScale(999) + 'px')
    techE.append("td")
      // .style('width', '10px')
      // .style('height', '10px')
      // .style('margin-bottom', '5px')
      .append('div')
      .classed("box", true)
      .style('width', '3px')
      .style('height', '10px')
      .style('background-color', (d) => colorScale(d.count))
      .style('margin-right', '5px')
      // .style('padding-right', '8px')
    techE.append("td")
      .text((d) => d.glyph)
      .style('font-family', 'Courier')
      .style('color', '#F4F1F1')
      .on('click', click)
      .append('span')
      .text((d) => d.remainder)
      .style('opacity', 0.0)
      // .style('background-color', 'steelblue')

      // .attr('transform', (d) => 'translate('+ 0 +','+ yScale(d.name) + ')')

    // techE.append('td')
      // .attr("fill", "steelblue")
      // .attr("x", 0)
      // .attr("y", d => yScale(d.name))
      // .attr("width", 10)
      // .attr("height", yScale.rangeBand())
      // .on("mouseover", function(d) { d3.select(this).attr("fill", "orange"); })
      // .on("mouseout", function(d) { d3.select(this).attr("fill", "steelblue"); });

    // techE.append('text')
    //   .attr('dx', 5)
    //   .attr('dy', (yScale.rangeBand() / 2))
    //   .style('font-size', 5)
    //   .attr('pointer-events', 'none')
    //   .attr("x", 0)
    //   .attr("y", d => yScale(d.name))
    //   .text((d) => d.name)
    // mousemove();
  }

  function mouseover(d,i) {

  }

  function click(d,i) {
    // d.clicked = d.clicked ? false : true;
    // d3.select(this)
    //   .style('color', d.clicked ? 'orange' : '#F4F1F1' )

    d3.selectAll('.tech').each((t) => t.clicked = false)
    d3.selectAll('.box').style('opacity', 1.0)
    d.clicked = true
    d3.selectAll('.tech').selectAll('td')
      .style('color', (e) => e.clicked ? 'orange' : '#F4F1F1' )
    // d3.selectAll('.box').style('opacity', (e) => e.clicked ? 1.0 : 0.3)
    d3.selectAll('.box')
      // .style('background-color', (e) => e.clicked ? colorScale(e.count) : '#ddd')
      .style('opacity', (e) => e.clicked ? 1.0 : 0.3)

  }

  function mousemove() {
    // var e = d3.event;

    var c = d3.mouse(d3.select('body').node());

    var scrollY = window.scrollY;

    if(c[0] > 300) { c[1] = 99999; }

    var tS = table.selectAll('.tech')
      .each(function(d, i) {


        var box = d3.select(this).node().getBoundingClientRect();

        // if(i === 0) {
        //   console.log(box)
        // }
        var y = (box.top + (box.height / 2) + scrollY);
        var dist = Math.abs(y - c[1]);
        d.dist = dist;
        var f = fScale(d.dist);
        f = f < 2.1 ? restScale(d.count) : f;
        f = d.clicked ? Math.max(14,f) : f;
        d.font = f;

        // d.w = wScale(dist);
        // d.h = hScale(dist);
        // d.y = dy > 0 ? y + (d.h / 2) : y - (d.h / 2) ;

      })
      .style('font-size', (d) => d.font + 'px')
      .selectAll('span')
      .style('opacity', (d) => d.clicked ? 1.0 : alphaScale(d.dist))
      // tS.select('rect')
      //   .attr('y', (d) => d.y)
      //   .attr('width', (d) => d.w)
      //   .attr('height', (d) => d.h);

      // tS.select('td')
        // .attr('y', (d) => d.y)
        // .attr('dy', (d) => d.h / 2)

    // console.log(c);
  }

  return chart;
};
