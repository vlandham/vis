
import * as d3 from 'd3';
//http://stackoverflow.com/questions/25582882/javascript-math-random-normal-distribution-gaussian-bell-curve
// returns a gaussian random function with the given mean and stdev.
function gaussian(mean, stdev) {
    var y2;
    var use_last = false;
    return function() {
        var y1;
        if(use_last) {
           y1 = y2;
           use_last = false;
        }
        else {
            var x1, x2, w;
            do {
                 x1 = 2.0 * Math.random() - 1.0;
                 x2 = 2.0 * Math.random() - 1.0;
                 w  = x1 * x1 + x2 * x2;
            } while( w >= 1.0);
            w = Math.sqrt((-2.0 * Math.log(w))/w);
            y1 = x1 * w;
            y2 = x2 * w;
            use_last = true;
       }

       var retval = mean + stdev * y1;
       if(retval > 0)
           return retval;
       return -retval;
   }
}

function randomIntFromInterval(min,max)
{
    return Math.floor(Math.random()*(max-min+1)+min);
}


export default function createHopPlot() {
  const width = 200;
  const height = 200;
  let ctx = null;
  let data = [];
  let t = null;
  let dataN = 200;
  const particleR = 2.5;
  let spaceR = 100;
  let running = true;
  let color = [0,0,0,0.8]
  let barWidth = 8;
  let trails = false;

  let interval = 140;

  const tau = 2 * Math.PI;

  function setupParticles() {
    data = new Array(dataN);

    const standard = gaussian(100, 15);

    for (let i = 0; i < dataN; ++i) {
      data[i] = {
        y: standard()
      };
    }
  }

  const chart = function wrapper(selection) {
    setupParticles();

    const div = d3.select(selection).append('div')
      .attr('class', 'vis')
      .style('width', width + 'px');

    const canvas = div.append('canvas')
      .attr('width', width)
      .attr('height', height);

    div.append('button')
      .attr('class', 'toggle-btn')
      .on('click', toggle)
      .text('start/stop');

    const scale = window.devicePixelRatio;
    ctx = canvas.node().getContext('2d');
    if (scale > 1) {
      canvas.style('width', width + 'px');
      canvas.style('height', height + 'px');
      canvas.attr('width', width * scale);
      canvas.attr('height', height * scale);
      ctx.scale(scale, scale);
    }

    // update();

    t = d3.interval(update, interval);

    // update();
    // d3.timer();
  };

  function update(elapsed) {
    ctx.save();
    // ctx.globalAlpha = 0.2;
    if (trails) {

      ctx.fillStyle = "rgba(255, 255, 255, 0.5)";
      ctx.fillRect(0, 0, width, height);
    } else {

      ctx.fillStyle = "rgb(255, 255, 255)";
      ctx.fillRect(0, 0, width, height);
    }
    ctx.fillStyle = "black";
    // ctx.globalAlpha = 1.0;
    // ctx.clearRect();


    const point = data[randomIntFromInterval(0, dataN - 1)];
    point.x = width / 2;

    ctx.fillRect(50, point.y, width - 100, barWidth);
    ctx.restore();
  }

  function toggle() {
    if (running) {
      running = false;
      t.stop();
    } else {
      running = true;
      t = d3.interval(update, interval);
    }
  }

  chart.radius = function radius(_) {
    if (!arguments.length) {
      return spaceR;
    }

    spaceR = _;
    return this;
  };

  chart.interval = function setinterval(_) {
    if (!arguments.length) {
      return interval;
    }

    interval = _;
    return this;
  };

  chart.trails = function settrails(_) {
    if (!arguments.length) {
      return trails;
    }

    trails = _;
    return this;
  };

  chart.count = function count(_) {
    if (!arguments.length) {
      return dataN;
    }

    dataN = _;
    return this;
  };

  return chart;
}
