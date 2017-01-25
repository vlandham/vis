
import * as d3 from 'd3';

export default function createChart() {
  const width = 300;
  const height = 300;
  let ctx = null;
  let particles = [];
  let t = null;
  let numParticles = 200;
  const particleR = 2.5;
  let spaceR = 100;
  let running = true;

  const tau = 2 * Math.PI;

  function setupParticles() {
    particles = new Array(numParticles);

    for (let i = 0; i < numParticles; ++i) {
      particles[i] = {
        x: width / 2,
        y: height / 2,
        vx: 0,
        vy: 0,
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

    t = d3.timer(update);

    // update();
    // d3.timer();
  };

  function update(elapsed) {
    ctx.save();
    ctx.clearRect(0, 0, width, height);

    // ctx.arc(width / 2, height / 2, width / 4, 0, tau);
    // ctx.clip();

    const spaceX = width / 2;
    const spaceY = height / 2;

    for (let i = 0; i < numParticles; ++i) {
      const p = particles[i];
      p.x += p.vx;
      p.y += p.vy;

      if (Math.pow(p.x - spaceX, 2) + Math.pow(p.y - spaceY, 2) > Math.pow(spaceR, 2)) {
        p.x = width / 2;
        p.y = height / 2;
      }
      // if (p.x < -width) {
      //   p.x = width / 2;
      // } else if (p.x > width) {
      //   p.x = width / 2;
      // }
      // if (p.y < -height) {
      //   p.y = height / 2;
      // } else if (p.y > height) {
      //   p.y -= height / 2;
      // }

      p.vx += 0.2 * (Math.random() - 0.5) - 0.01 * p.vx;
      p.vy += 0.2 * (Math.random() - 0.5) - 0.01 * p.vy;

      ctx.beginPath();
      ctx.arc(p.x, p.y, particleR, 0, tau);
      ctx.fill();
    }
    ctx.restore();
  }

  function toggle() {
    if (running) {
      running = false;
      t.stop();
    } else {
      running = true;
      t.restart(update);
    }
  }

  chart.radius = function radius(_) {
    if (!arguments.length) {
      return spaceR;
    }

    spaceR = _;
    return this;
  };

  chart.count = function count(_) {
    if (!arguments.length) {
      return numParticles;
    }

    numParticles = _;
    return this;
  };

  return chart;
}
