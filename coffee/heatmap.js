(function() {
  var heatmapChart, root;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  heatmapChart = function() {
    var buildRow, chart, height, margin, mouseout, mouseover, onClick, width, xScale, xValue, yScale, yValue, zScale, zValue;
    margin = {
      top: 20,
      right: 20,
      bottom: 20,
      left: 20
    };
    width = 800;
    height = 800;
    xValue = function(d) {
      return d.x;
    };
    yValue = function(d) {
      return d.y;
    };
    zValue = function(d) {
      return parseFloat(d.z);
    };
    xScale = d3.scale.ordinal().rangeBands([0, width]);
    yScale = d3.scale.ordinal().rangeBands([0, height]);
    zScale = d3.scale.linear().range(['#C6DBEF', '#08306B']);
    onClick = function(d, i) {
      return console.log(d);
    };
    chart = function(selection) {
      return selection.each(function(data) {
        var column, g, gEnter, row, svg;
        data = data.map(function(d, i) {
          var new_data;
          new_data = d;
          new_data.x = xValue.call(data, d, i);
          new_data.y = yValue.call(data, d, i);
          new_data.z = zValue.call(data, d, i);
          return new_data;
        });
        console.log(data);
        xScale.domain(data.map(function(d) {
          return d.x;
        }));
        yScale.domain(data.map(function(d) {
          return d.y;
        }));
        zScale.domain(d3.extent(data, function(d) {
          return d.z;
        }));
        svg = d3.select(this).selectAll("svg").data([data]);
        gEnter = svg.enter().append("svg").append("g");
        svg.attr("width", width + margin.left + margin.right);
        svg.attr("height", height + margin.top + margin.bottom);
        g = svg.select("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");
        g.append("rect").attr("class", "background").attr("width", width).attr("height", height);
        row = g.selectAll(".row").data(data).enter().append("g").attr("class", "row").attr("transform", function(d, i) {
          return "translate(" + 0 + "," + (yScale(d.y)) + ")";
        }).each(buildRow);
        row.append("line").attr("x1", 0).attr("x2", width).attr("class", "row_line");
        row.append("text").attr("x", -6).attr("y", yScale.rangeBand() / 2).attr("dy", ".32em").attr("text-anchor", "end").text(function(d, i) {
          return d.y;
        });
        column = g.selectAll(".column").data(data).enter().append("g").attr("class", "column").attr("transform", function(d, i) {
          return "translate(" + (xScale(d.x)) + ") rotate(" + (-90) + ")";
        });
        column.append("text").attr("x", 6).attr("y", xScale.rangeBand() / 2).attr("dy", ".32em").attr("text-anchor", "start").text(function(d, i) {
          return d.x;
        });
        return column.append("line").attr("x1", -width).attr("class", "col_line");
      });
    };
    buildRow = function(row) {
      var cell;
      return cell = d3.select(this).selectAll(".cell").data([row]).enter().append("rect").attr("class", "cell").attr("x", function(d) {
        return xScale(d.x);
      }).attr("width", xScale.rangeBand()).attr("height", yScale.rangeBand()).attr("fill", function(d) {
        return zScale(d.z);
      }).on("mouseover", mouseover).on("mouseout", mouseout).on("click", onClick);
    };
    mouseover = function(p, i) {
      d3.selectAll(".row text").classed("active", function(d, i) {
        return d.y === p.y;
      });
      return d3.selectAll(".column text").classed("active", function(d, i) {
        return d.x === p.x;
      });
    };
    mouseout = function(p, i) {
      return d3.selectAll("text").classed("active", false);
    };
    chart.width = function(_) {
      if (!arguments.length) return width;
      width = _;
      return chart;
    };
    chart.height = function(_) {
      if (!arguments.length) return height;
      height = _;
      return chart;
    };
    chart.margin = function(_) {
      if (!arguments.length) return margin;
      margin = _;
      return chart;
    };
    chart.x = function(_) {
      if (!arguments.length) return xValue;
      xValue = _;
      return chart;
    };
    chart.y = function(_) {
      if (!arguments.length) return yValue;
      yValue = _;
      return chart;
    };
    chart.z = function(_) {
      if (!arguments.length) return zValue;
      zValue = _;
      return chart;
    };
    chart.scale = function(_) {
      if (!arguments.length) return zScale;
      zScale = _;
      return chart;
    };
    return chart;
  };

  root.heatmapChart = heatmapChart;

}).call(this);
