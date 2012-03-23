(function() {
  var heatmapChart, root;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  heatmapChart = function() {
    var buildRow, chart, height, margin, mouseout, mouseover, onClick, orders, svg, transition_time, width, xScale, xValue, yScale, yValue, zScale, zValue;
    margin = {
      top: 20,
      right: 20,
      bottom: 20,
      left: 20
    };
    width = 800;
    height = 800;
    transition_time = 800;
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
    svg = null;
    orders = {
      x: null,
      y: null
    };
    onClick = function(d, i) {
      return console.log(d);
    };
    chart = function(selection) {
      return selection.each(function(data) {
        var column, data_counts, g, gEnter, row, row_text, unique_x_names, unique_y_names;
        data = data.map(function(d, i) {
          var new_data;
          new_data = d;
          new_data.x = xValue.call(data, d, i);
          new_data.y = yValue.call(data, d, i);
          new_data.z = zValue.call(data, d, i);
          return new_data;
        });
        data_counts = {};
        data.forEach(function(d) {
          var _base, _name, _name2;
          if (data_counts[_name = d.x] == null) data_counts[_name] = {};
          if ((_base = data_counts[d.x])[_name2 = d.y] == null) _base[_name2] = 0;
          return data_counts[d.x][d.y] += 1;
        });
        console.log(data_counts);
        unique_x_names = d3.keys(data_counts);
        unique_y_names = {};
        d3.entries(data_counts).forEach(function(e) {
          return d3.keys(e.value).forEach(function(k) {
            var _ref;
            return (_ref = unique_y_names[k]) != null ? _ref : unique_y_names[k] = 1;
          });
        });
        unique_y_names = d3.keys(unique_y_names);
        console.log(unique_y_names);
        orders = {
          x: {
            original: data.map(function(d) {
              return d.x;
            }),
            name_asc: data.map(function(d) {
              return d.x;
            }).sort(function(a, b) {
              return d3.ascending(a, b);
            }),
            name_dsc: data.map(function(d) {
              return d.x;
            }).sort(function(a, b) {
              return d3.descending(a, b);
            })
          },
          y: {
            original: data.map(function(d) {
              return d.y;
            }),
            name_asc: data.map(function(d) {
              return d.y;
            }).sort(function(a, b) {
              return d3.ascending(a, b);
            }),
            name_dsc: data.map(function(d) {
              return d.y;
            }).sort(function(a, b) {
              return d3.descending(a, b);
            })
          }
        };
        xScale.domain(orders.x.original);
        yScale.domain(orders.y.original);
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
        row_text = g.selectAll("row_text").data(unique_y_names).enter().append("g").attr("class", "row_text").attr("transform", function(d, i) {
          return "translate(" + 0 + "," + (yScale(d)) + ")";
        });
        row_text.append("line").attr("x1", 0).attr("x2", width).attr("class", "row_line");
        row_text.append("text").attr("x", -6).attr("y", yScale.rangeBand() / 2).attr("dy", ".32em").attr("text-anchor", "end").text(function(d, i) {
          return d;
        });
        console.log(unique_x_names);
        console.log(xScale(unique_x_names[1]));
        column = g.selectAll(".column").data(unique_x_names).enter().append("g").attr("class", "column").attr("transform", function(d, i) {
          return "translate(" + (xScale(d)) + ") rotate(" + (-90) + ")";
        });
        column.append("text").attr("x", 6).attr("y", xScale.rangeBand() / 2).attr("dy", ".32em").attr("text-anchor", "start").text(function(d, i) {
          return d;
        });
        column.append("line").attr("x1", -width).attr("class", "col_line");
        d3.select("#order_row").on("change", function() {
          return chart.order("y", this.value);
        });
        return d3.select("#order_col").on("change", function() {
          return chart.order("x", this.value);
        });
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
      d3.selectAll(".row_text text").classed("active", function(d, i) {
        return d === p.y;
      });
      return d3.selectAll(".column text").classed("active", function(d, i) {
        return d === p.x;
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
    chart.order = function(axis, value) {
      var delay, scale, t;
      scale = axis === "x" ? xScale : yScale;
      scale.domain(orders[axis][value]);
      t = svg.transition().duration(transition_time);
      delay = 2.5;
      t.selectAll(".row").delay(function(d, i) {
        return yScale(d.y) * delay;
      }).attr("transform", function(d, i) {
        return "translate(0," + (yScale(d.y)) + ")";
      }).selectAll(".cell").delay(function(d) {
        return xScale(d.x) * delay;
      }).attr("x", function(d) {
        return xScale(d.x);
      });
      t.selectAll(".row_text").delay(function(d, i) {
        return yScale(d) * delay;
      }).attr("transform", function(d, i) {
        return "translate(0," + (yScale(d)) + ")";
      });
      return t.selectAll(".column").delay(function(d, i) {
        return xScale(d) * delay;
      }).attr("transform", function(d, i) {
        return "translate(" + (xScale(d)) + ")rotate(-90)";
      });
    };
    return chart;
  };

  root.heatmapChart = heatmapChart;

}).call(this);
