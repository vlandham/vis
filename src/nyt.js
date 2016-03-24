module.exports = function() {

var width,
    height = 225;

var graphic = d3.select(".container");

var collection = graphic.select("#vis")
    .datum(function(d) {
      return {
        slug: this.getAttribute("data-slug"),
        size: this.getAttribute("data-size")
      };
    });

var canvas = collection
  .append("canvas");

var pixelRatio = 1,
    storeRatio = 1;

if (window.devicePixelRatio >= 2
    && screen.availWidth >= 1280 // iPad can’t even handle it
    && canvas.node().getContext("2d").webkitBackingStorePixelRatio !== 2) { // Safari can’t even
  pixelRatio = 2;
  storeRatio = 2;
}

canvas
    .attr("height", height * storeRatio)
    .style("height", height + "px");

var description = collection.select(".description"),
    annotations = collection.select(".annotations");

annotations.selectAll("li")
    .datum(function() {
      return {
        range: JSON.parse(this.getAttribute("data-range"))
      };
    });

d3.select(window)
    .on("scroll", scroll)
    // .on("resize", resize);

// d3.select("#fullscreen")
//     .style("display", null)
//     .on("click", function requestFullScreen() {
//       d3.event.preventDefault();
//
//       var element = document.documentElement;
//       if (element.requestFullscreen) element.requestFullscreen();
//       else if (element.mozRequestFullScreen) element.mozRequestFullScreen();
//       else if (element.webkitRequestFullscreen) element.webkitRequestFullscreen();
//
//       function cancelFullScreen() {
//         d3.event.preventDefault();
//         if (document.cancelFullScreen) document.cancelFullScreen();
//         else if (document.mozCancelFullScreen) document.mozCancelFullScreen();
//         else if (document.webkitCancelFullScreen) document.webkitCancelFullScreen();
//
//         d3.select(this)
//             .text("View Full Screen")
//             .on("click", requestFullScreen);
//       }
//
//       d3.select(this)
//           .text("Exit Full Screen")
//           .on("click", cancelFullScreen);
//     });

resize();

// Recompute bounding boxes due to reflow.
function resize() {
  width = 1000

  annotations
      .style("width", width + "px");

  collection.select("canvas")
      .attr("width", width * storeRatio)
      .style("width", width + "px")
      .each(function(d) {
        var context = d.context = this.getContext("2d");
        context.scale(storeRatio, storeRatio);
        context.strokeStyle = "rgba(0,0,0,0.8)";
        if (d.enabled) d.resize();
      });

  scroll();
}

// Recompute which canvases are visible in the viewport.
function scroll() {
  var dy = innerHeight;
  if (!canvas
      .filter(function() {
        var box = this.getBoundingClientRect();
        return box.bottom > 0 && box.top < dy;
      })
      .each(enableFisheye)
      .empty()) {
    canvas = canvas.filter(function(d) { return !d.enabled; });
  }
}

function enableFisheye(d) {
  d.enabled = true;

  var that = this,
      link = that.parentNode,
      div = link.parentNode,
      touchtime;

  var normalWidth = width / d.size,
      image = new Image,
      imageWidth = 105,
      imageHeight = 225,
      desiredDistortion = 0,
      desiredFocus,
      progress = 0,
      idle = true;

  var x = fisheye()
      .distortion(0)
      .extent([0, width]);

  var annotation = d3.select(div).selectAll("li");

  image.src = "http://graphics8.nytimes.com/newsgraphics/2013/09/13/fashion-week-editors-picks/assets/thumbs-" + pixelRatio + "/" + d.slug + ".jpg";
  image.onload = initialize;

  d3.timer(function() {
    if (progress < 0) return true;
    var context = d.context;
    context.clearRect(0, 0, width, 2);
    context.fillStyle = "#777";
    context.fillRect(0, 0, ++progress, 2);
  });

  d.resize = function() {
    var f = x.focus() / x.extent()[1],
        d1 = imageWidth / normalWidth - 1,
        d0 = x.distortion() / d1;
    normalWidth = width / d.size;
    x.distortion(d0 * d1).extent([0, width]).focus(f * width);
    render();
  };

  function initialize() {
    progress = -1;

    d3.select(that)
        .on("mousedown", mousedown)
        .on("mouseover", mouseover)
        .on("mousemove", mousemove)
        .on("mouseout", mouseout)
        .on("touchstart", touchstart)
        .on("touchmove", mousemove)
        .on("touchend", mouseout);

    render();
  }

  function render() {
    annotation
        .style("left", function(d) { return Math.round(x(d.range[0] * normalWidth)) - 4 + "px"; })
        .style("width", function(d) { return Math.round(x((d.range[d.range.length - 1] + 1) * normalWidth)) - Math.round(x(d.range[0] * normalWidth)) - 1 + "px"; })
      .select(".annotation")
        .style("left", function(d) { return Math.min(0, (width - 90) - (x(d.range[0] * normalWidth) - 4)) + "px"; });

    var context = d.context;
    context.clearRect(0, 0, width, height);

    for (var i = 0, n = d.size; i < n; ++i) {
      var x0 = x(i * normalWidth),
          x1 = x((i + 1) * normalWidth),
          dx = Math.min(imageWidth, x1 - x0);
      context.drawImage(image, Math.round((i * imageWidth + (imageWidth - dx) / 2) * pixelRatio), 0, dx * pixelRatio, imageHeight * pixelRatio, x0, 0, dx, height);
      context.beginPath();
      context.moveTo(x0, 0);
      context.lineTo(x0, height);
      context.stroke();
    }

    context.strokeRect(0, 0, width, height);
  }

  function move() {
    if (idle) d3.timer(function() {
      var currentDistortion = x.distortion(),
          currentFocus = currentDistortion ? x.focus() : desiredFocus;
      idle = Math.abs(desiredDistortion - currentDistortion) < .01 && Math.abs(desiredFocus - currentFocus) < .5;
      x.distortion(idle ? desiredDistortion : currentDistortion + (desiredDistortion - currentDistortion) * .14);
      x.focus(idle ? desiredFocus : currentFocus + (desiredFocus - currentFocus) * .14);
      render();
      return idle;
    });
  }

  function mouseover() {
    desiredDistortion = imageWidth / normalWidth - 1;
    mousemove();
  }

  function mouseout() {
    desiredDistortion = 0;
    mousemove();
  }

  function mousemove() {
    desiredFocus = Math.max(0, Math.min(width - 1e-6, d3.mouse(that)[0]));
    move();
  }

  function mousedown() {
    var m = Math.max(0, Math.min(width - 1e-6, d3.mouse(that)[0]));
    for (var i = 0, n = d.size; i < n && x(i * normalWidth) < m; ++i);
    link.href = "http://www.nytimes.com/fashion/runway/" + d.slug + "/spring-2014-rtw/" + i + "?fingerprint=true";
  }

  function touchstart() {
    d3.event.preventDefault();
    mouseover();
    if (d3.event.touches.length === 1) {
      var now = Date.now();
      if (now - touchtime < 500) mousedown(), link.click();
      touchtime = now;
    }
  }
}

function fisheye() {
  var min = 0,
      max = 1,
      distortion = 3,
      focus = 0;

  function G(x) {
    return (distortion + 1) * x / (distortion * x + 1);
  }

  function fisheye(x) {
    var Dmax_x = (x < focus ? min : max) - focus,
        Dnorm_x = x - focus;
    return G(Dnorm_x / Dmax_x) * Dmax_x + focus;
  }

  fisheye.extent = function(_) {
    if (!arguments.length) return [min, max];
    min = +_[0], max = +_[1];
    return fisheye;
  };

  fisheye.distortion = function(_) {
    if (!arguments.length) return distortion;
    distortion = +_;
    return fisheye;
  };

  fisheye.focus = function(_) {
    if (!arguments.length) return focus;
    focus = +_;
    return fisheye;
  };

  return fisheye;
}

}
