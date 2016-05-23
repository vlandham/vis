
var d3 = require('d3');
var topojson = require('topojson');
var tooltip = require('./tooltip');

var mains = [/cal/, /admiral/, /alaska/, /delridge/];


module.exports = function createChart() {
  var width = 1000;
  var height = 800;
  var margin = {top: 20, right: 20, bottom: 20, left: 20};
  var g;
  var geojson;

  var tip = tooltip("tooltip", 240);

  var projection = d3.geo.mercator()
    .scale(100)
    .translate([width / 2, height / 2]);

  var path = d3.geo.path()
    .projection(projection);

  var zoom = d3.behavior.zoom();
    // .translate(projection.translate())
    // .scale(projection.scale())
    // .scaleExtent([height, 8 * height])
    // .on("zoom", zoomed);

  var chart = function(selection) {
    selection.each(function(rawData) {
      geojson = rawData;
      var svg = d3.select(this).append('svg');
      svg.attr("width", width + margin.left + margin.right );
      svg.attr("height", height + margin.top + margin.bottom );
      g = svg.append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

      var westSeattle = topojson.feature(geojson, geojson.objects.west_seattle_s);
      var center = d3.geo.centroid(westSeattle);
      var offset = [width / 2, height / 2];
      var scale  = 150;
      projection = d3.geo.mercator().scale(scale).center(center)
          .translate(offset);


      path = d3.geo.path().projection(projection);

      var bounds  = path.bounds(westSeattle);
      var hscale  = scale * width  / (bounds[1][0] - bounds[0][0]);
      var vscale  = scale * height / (bounds[1][1] - bounds[0][1]);
      scale   = (hscale < vscale) ? hscale : vscale;
      offset  = [width - (bounds[0][0] + bounds[1][0]) / 2,
                        height - (bounds[0][1] + bounds[1][1]) / 2];

      projection = d3.geo.mercator().center(center)
        .scale(scale).translate(offset);
      path = path.projection(projection);

      var features = westSeattle.features.filter(function(d) { return d.properties.name; });


      zoom = d3.behavior.zoom()
        .translate(projection.translate())
        .scale(projection.scale())
        // .scaleExtent([226098, 826098])
        .on("zoom", zoomed);

      g.selectAll("street")
        .data(features)
        .enter().append('path')
        .attr('class', 'street')
        .attr("d",path)
        .on('mouseover', mouseover)
        .on('mouseout', mouseout)
        .classed('main', function(d) {
          var m = false;
          mains.forEach(function(main) {
            if(d.properties.name && d.properties.name.toLowerCase().match(main)) {
              m = true;
            }

          });
          return m;

        });

      g.selectAll("hover")
        .data(features)
        .enter().append('path')
        .attr('class', 'hover')
        .attr("d",path)
        .on('mouseover', mouseover)
        .on('mouseout', mouseout)
        .classed('highlight', false);

      g.call(zoom);
    });
  };

  function zoomed() {
    projection.translate(d3.event.translate).scale(d3.event.scale);
    g.selectAll("path").attr("d", path);
  }

  function mouseover(d) {
    console.log(d);

    tip.showTooltip(d.properties.name, d3.event);

    if(d.properties.name)  {

      g.selectAll('.street').filter(function(s) {
        return d.properties.name == s.properties.name;
      })
      .classed('hovered', true);
    }
    // d3.select(this).classed('hovered', true);

  }

  function mouseout() {
    tip.hideTooltip();
    g.selectAll('.street').classed('hovered', false);

  }

  chart.highlight = function(roadRegEx) {
    var re = new RegExp(roadRegEx);
    if (roadRegEx.length == 0) {

      re = new RegExp('NOTHINGMACHTES');

    }
    g.selectAll('path')
      .classed('highlight', function(d) {
        return d.properties.name && d.properties.name.toLowerCase().match(re);
      });
      // .each(function(d) { console.log(d); })
  };

  return chart;
};
