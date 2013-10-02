(function() {
  (function(Raphael) {
    var ColorPicker, angle, doc, pi, win;
    angle = function(x, y) {
      return (x < 0) * 180 + Math.atan(-y / -x) * 180 / pi;
    };
    Raphael.colorpicker = function(x, y, size, initcolor, element, selectors, dimensions, separation, isColorblind) {
      return new ColorPicker(x, y, size, initcolor, element, selectors, dimensions, separation, isColorblind);
    };
    Raphael.fn.colorPickerIcon = function(x, y, r, element, isColorblind) {
      var arc, circle, data, gradient, padding, square, steps, triangle, wheel;
      padding = 2 * r / 200;
      arc = d3.svg.arc().innerRadius(0).outerRadius(r).startAngle(function(d) {
        return d.startAngle;
      }).endAngle(function(d) {
        return d.endAngle;
      });
      steps = 2;
      data = d3.range(180).map(function(d, i) {
        i *= steps;
        return {
          startAngle: i * (pi / 180),
          endAngle: (i + 2) * (pi / 180),
          fill: d3.hsl(i, 1, .5).toString()
        };
      });
      wheel = d3.select("#" + element).insert('svg', 'svg').style('position', "absolute");
      gradient = wheel.append("svg:defs").append("svg:radialGradient").attr("id", "gradient").attr("cx", "50%").attr("cy", "50%").attr("fx", "50%").attr("fy", "50%").attr("r", "50%").attr("spreadMethod", "pad");
      gradient.append("svg:stop").attr("offset", "20%").attr("stop-color", "rgb(100,100,100)").attr("stop-opacity", 1);
      gradient.append("svg:stop").attr("offset", "100%").attr("stop-color", "rgb(100,100,100)").attr("stop-opacity", 0);
      wheel.attr("id", "icon").append('g').attr("transform", "translate(" + x + "," + y + ") rotate(90) scale(-1,1)").selectAll('path').data(data).enter().append('path').attr("d", arc).attr("stroke-width", 1).attr("stroke", function(d) {
        return d.fill;
      }).attr("fill", function(d) {
        return d.fill;
      });
      wheel.append("circle").attr("cx", r + padding).attr("cy", r + padding).attr("r", r + padding).attr("fill", "url('#gradient')");
      if (isColorblind) {
        square = superformula().type("square").size(r).segments(50);
        circle = superformula().type("circle").size(r).segments(50);
        triangle = superformula().type("triangle").size(r).segments(50);
        wheel.append("g").classed("trig", true).attr("transform", "translate(" + (r * Math.sin(5.9) + r - r / 5) + "," + (r * Math.cos(5.9) + r - r / 5) + ")").append("path").attr("d", function(d, i) {
          return triangle();
        }).attr("fill", "transparent").attr("stroke", "black").attr("stroke-width", "3").attr("opacity", 0.2);
        wheel.append("g").attr("transform", "translate(" + (r * Math.sin(3.6) + r + r / 13) + "," + (r * Math.cos(3.6) + r + r / 13) + ")").append("path").attr("d", function(d, i) {
          return circle();
        }).attr("fill", "transparent").attr("stroke", "black").attr("stroke-width", "3").attr("opacity", 0.2);
        return wheel.append("g").attr("transform", "translate(" + (r * Math.sin(1.5) + r - r / 20) + "," + (r * Math.cos(1.5) + r - r / 20) + ")").append("path").attr("d", function(d, i) {
          return square();
        }).attr("fill", "transparent").attr("stroke", "black").attr("stroke-width", "3").attr("opacity", 0.2);
      }
    };
    pi = Math.PI;
    doc = document;
    win = window;
    ColorPicker = function(x, y, size, initcolor, element, selectors, dimensions, separation, isColorblind) {
      var B, H, S, bpad, containerEl, cursorAttrIn, cursorAttrOut, fi, h, handleScroll, height, i, isH, isHS, isHSB, isiPad, offset, padding, r, s, size2, size20, style, t, w1, w3, wh, wheel, wheelEl, width, xy;
      if (size == null) {
        size = 200;
      }
      if (initcolor == null) {
        initcolor = "#fff";
      }
      if (selectors == null) {
        selectors = 1;
      }
      if (dimensions == null) {
        dimensions = 3;
      }
      if (separation == null) {
        separation = 0;
      }
      if (isColorblind == null) {
        isColorblind = false;
      }
      isiPad = false;
      w3 = 3 * size / 200;
      w1 = size / 200;
      fi = 1.6180339887;
      if (dimensions === 1) {
        isH = true;
      }
      if (dimensions === 2) {
        isHS = true;
      }
      if (dimensions === 3) {
        isHSB = true;
      }
      size20 = size / 25;
      size2 = size / 2;
      padding = 2 * size / 200;
      height = size + padding;
      bpad = 1;
      if (dimensions === 3) {
        bpad = 10;
      }
      width = size + padding * bpad;
      t = this;
      H = 1;
      S = 1;
      B = 1;
      s = size - (size20 * 4);
      r = (element ? Raphael(element, width, height) : Raphael(x, y, width, height));
      r.colorPickerIcon(size2, size2, size2 - padding, element, isColorblind);
      xy = s / 6 + size20 * 2 + padding;
      wh = s * 2 / 3 - padding * 2;
      w1 < 1 && (w1 = 1);
      w3 < 1 && (w3 = 1);
      t.selectors = selectors;
      t.bcirc = r.circle(size2, size2, size2 - w1 * 3).attr({
        fill: "#000",
        "stroke-width": w3,
        "opacity": 0,
        "stroke": "#000"
      });
      if (isH) {
        t.bcirc.attr({
          fill: "#fff",
          opacity: 1,
          r: size2 - (size20 + size20 / 3),
          "stroke-width": 0,
          stroke: "transparent"
        });
      }
      cursorAttrOut = {
        "stroke": "#fff",
        "opacity": .5,
        "stroke-width": w1 + 2
      };
      cursorAttrIn = {
        "stroke": "#333",
        "opacity": 1,
        "stroke-width": w1 + 2
      };
      t.cursor = [];
      for (i = 0; 0 <= selectors ? i < selectors : i > selectors; 0 <= selectors ? i++ : i--) {
        t.cursor[i] = r.set();
        t.cursor[i].push(r.circle(size2, size2, size20 / 2).attr(cursorAttrOut).toFront());
        t.cursor[i].push(t.cursor[i][0].clone().attr(cursorAttrIn).toFront());
      }
      t.disc = r.circle(size2, size2, size2 - padding).attr({
        fill: "#000",
        "fill-opacity": 0,
        stroke: "none",
        cursor: "crosshair"
      });
      style = t.disc.node.style;
      style.unselectable = "on";
      style.MozUserSelect = "none";
      style.WebkitUserSelect = "none";
      h = size20 * 2 + 2;
      if (isHSB) {
        t.brect = r.rect(size + padding + 0.5, w1 * 4 + 0.5, padding * 8, h * 9 - padding).attr({
          "stroke-width": 0,
          fill: "270-#fff-#fff"
        });
        t.cursorb = r.set();
        t.cursorb.push(r.rect(size + 0.5 + w1 + 1, padding + 0.5, padding * 8 + 1, 10).attr({
          stroke: "#fff",
          opacity: .5,
          "stroke-width": 1
        }));
        t.cursorb.push(t.cursorb[0].clone().attr({
          stroke: "#000",
          opacity: 1,
          "stroke-width": w1
        }));
        t.btop = t.brect.clone().attr({
          stroke: "#000",
          fill: "#000",
          opacity: 0
        });
        style = t.btop.node.style;
        style.unselectable = "on";
        style.MozUserSelect = "none";
        style.WebkitUserSelect = "none";
        t.bheight = 10;
        t.miny = padding + t.bheight - 5;
        t.maxy = t.brect.attr("height") + padding - 5;
        t.btop.drag((function(dx, dy, x, y) {
          return t.docOnMove(dx, dy, x, y - offset.top);
        }), (function(x, y) {
          t.bOnTheMove = true;
          return t.setB(y - t.y - offset.top);
        }), function() {
          return t.bOnTheMove = false;
        });
        wheel = function(e) {
          var delta;
          delta = 0;
          if (!e) {
            e = window.event;
          }
          if (e.wheelDelta) {
            delta = e.wheelDelta / 120;
          }
          if (window.opera) {
            delta = delta * .1;
          } else if (e.detail) {
            delta = -e.detail;
          }
          if (delta) {
            handleScroll(delta);
          }
          if (e.preventDefault) {
            e.preventDefault();
            return e.returnValue = false;
          }
        };
        handleScroll = function(delta) {
          var offset;
          offset = 1;
          if (window.navigator.vendor) {
            offset = 10;
          }
          delta = t.cursorb[0].attr("y") - delta * offset;
          return t.setB(delta);
        };
        if (window.addEventListener) {
          window.addEventListener('DOMMouseScroll', wheel, false);
        }
        window.onmousewheel = document.onmousewheel = wheel;
      }
      t.H = t.S = t.B = 1;
      t.padding = padding;
      t.raphael = r;
      t.size2 = size2;
      t.size20 = size20;
      t.isH = isH;
      t.isHS = isHS;
      t.isHSB = isHSB;
      t.rd = 0;
      t.separation = separation;
      t.innerCircle = size2 - (size20 + w3 + size20 / 3);
      t.x = x;
      t.y = y;
      
      wheelEl = document.getElementById(element);
      
      if (element !== "wheel") containerEl = document.getElementById("popcontainer");
      else containerEl = document.getElementById("container");
      
      offset = {
        top: wheelEl.offsetTop + containerEl.offsetTop,
        left: wheelEl.offsetLeft + containerEl.offsetLeft
      };
      
      window.onresize = function() {
        return offset = {
          top: wheelEl.offsetTop + containerEl.offsetTop,
          left: wheelEl.offsetLeft + containerEl.offsetLeft
        };
      };

      var screen_move = function(e) {
        e.preventDefault();
        if (offset.top) return t.setHS(e.pageX - offset.left, e.pageY - offset.top);
        else {
          return offset = {
            top: wheelEl.offsetTop,
            left: wheelEl.offsetLeft
          };
        }
      };

      window.onmousemove = screen_move; 
      window.ontouchmove = screen_move; 

      t.color(initcolor || "#fff");
      return this.onchanged && this.onchanged(this.color());
    };
    ColorPicker.prototype.setB = function(y) {
      y = ~~y;
      y < this.miny && (y = this.miny + 0.5);
      y > this.maxy && (y = this.maxy);
      this.cursorb[0].attr({
        y: y
      });
      this.cursorb[1].attr({
        y: y - 1
      });
      this.B = Math.max(Math.min(((y - this.miny) / (this.maxy - this.miny) - 1) * -1, .9999), .01);
      this.bcirc.attr({
        "opacity": (this.B - 1) * -1
      });
      return this.onchange && this.onchange(this.color());
    };
    ColorPicker.prototype.setHS = function(x, y) {
      var R, Rn, X, Y, d, distance, extraPad, i, innerRadius, rd, _ref;
      X = x - this.size2;
      Y = y - this.size2;
      extraPad = 0;
      if (this.isH) {
        extraPad = this.size20 / 4;
      }
      R = this.size2 - this.size20 / 2 - this.padding - extraPad;
      d = angle(X, Y);
      rd = d * pi / 180;
      this.rd = rd;
      isNaN(d) && (d = 0);
      if (X * X + Y * Y > R * R || this.isH) {
        x = R * Math.cos(rd) + this.size2;
        y = R * Math.sin(rd) + this.size2;
        X = x - this.size2;
        Y = y - this.size2;
      }
      innerRadius = R / 3 + R / 8;
      for (i = 0, _ref = this.selectors; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
        if (i === 0 && this.separation === 0.5) {
          rd -= 0.5;
        }
        Rn = Math.max(Math.sqrt((X * X) + (Y * Y)), innerRadius);
        var x = Rn * Math.cos(rd) + this.size2;
        // console.log(x);
        this.cursor[i].attr({
          cx: Rn * Math.cos(rd) + this.size2,
          cy: Rn * Math.sin(rd) + this.size2
        });
        rd += this.separation;
      }
      this.H = (1 - d / 360) % 1;
      distance = Math.max((X * X + Y * Y) / R / R, 0.3);
      this.S = Math.min(distance, 1);
      if (this.isHSB) {
        this.brect.attr({
          fill: "270-hsb(" + [this.H, this.S] + ",1)-#000"
        });
      }
      return this.onchange && this.onchange(this.color());
    };
    ColorPicker.prototype.docOnMove = function(dx, dy, x, y) {
      if (this.hsOnTheMove) {
        this.setHS(x - this.x, y - this.y);
      }
      if (this.bOnTheMove) {
        return this.setB(y - this.y);
      }
    };
    ColorPicker.prototype.remove = function() {
      this.raphael.remove();
      return this.color = function() {
        return false;
      };
    };
    ColorPicker.prototype.color = function(color) {
      var R, d, hex, rd, x, y;
      if (color) {
        color = Raphael.getRGB(color);
        hex = color.hex;
        color = Raphael.rgb2hsb(color.r, color.g, color.b);
        d = color.h * 360;
        this.H = color.h;
        this.S = color.s;
        this.B = Math.min(color.b, .9999);
        if (this.isHSB) {
          this.cursorb.attr({
            y: this.cursorb[0].attr("height")
          });
          this.cursorb[1].attr({
            y: this.cursorb[1].attr("height") - 1
          });
          this.bcirc.attr({
            "opacity": (this.B - 1) * -1
          });
          this.brect.attr({
            fill: "270-hsb(" + [this.H, this.S] + ",1)-#000"
          });
        }
        d = (1 - this.H) * 360;
        rd = d * pi / 180;
        R = (this.size2 - this.size20 / 2 - this.padding) * this.S;
        x = Math.cos(rd) * R + this.size2;
        y = Math.sin(rd) * R + this.size2;
        // this.cursor[0].attr({
        //   cx: x,
        //   cy: y
        // });
        return this;
      } else {
        return Raphael.hsl2rgb(this.H, this.S, this.B / 2).hex;
      }
    };
    return ColorPicker.prototype.coordinates = function(color) {
      var R, d, hex, rd, x, y;
      if (color) {
        color = Raphael.getRGB(color);
        hex = color.hex;
        color = Raphael.rgb2hsb(color.r, color.g, color.b);
        d = color.h * 360;
        // this.H = color.h;
        // this.S = color.s;
        // this.B = Math.min(color.b, .9999);
        // if (this.isHSB) {
        //   this.cursorb.attr({
        //     y: this.cursorb[0].attr("height")
        //   });
        //   this.cursorb[1].attr({
        //     y: this.cursorb[1].attr("height") - 1
        //   });
        //   this.bcirc.attr({
        //     "opacity": (this.B - 1) * -1
        //   });
        //   this.brect.attr({
        //     fill: "270-hsb(" + [this.H, this.S] + ",1)-#000"
        //   });
        // }
        d = (1 - color.h) * 360;
        rd = d * pi / 180;
        R = (this.size2 - this.size20 / 2 - this.padding) * color.s;
        x = Math.cos(rd) * R + this.size2;
        y = Math.sin(rd) * R + this.size2;
        // this.cursor[0].attr({
        //   cx: x,
        //   cy: y
        // });
        return {'x':x,'y':y};
      } else {
        return Raphael.hsl2rgb(this.H, this.S, this.B / 2).hex;
      }
    };    
  })(window.Raphael);
}).call(this);
