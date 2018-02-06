import * as d3 from 'd3';

/**
 * Distance between two 'nodes'
 *
 * @param {Object} a
 * @param {Object} b
 */
function dist(a, b) { return Math.pow(a.x - b.x, 2) + Math.pow(a.y - b.y, 2); }

/**
 * GRID
 */
const grid = {};
grid.cells = [];
grid.init = (data, width, height) => {
  const gridWidth = width / 10;
  const colsNum = width / gridWidth;
  const rowsNum = height / gridWidth;
  d3.range(colsNum).forEach((col) => {
    d3.range(rowsNum).forEach((row) => {
      const cell = { x: col * gridWidth, y: row * gridWidth };
      grid.cells.push(cell);
    });
  });
};


grid.occupy = (node) => {
  let minDist = 100000;
  let candidate = null;

  grid.cells.forEach(c => {
    if (!c.occupied) {
      const d = dist(node, c);
      if (d < minDist) {
        minDist = d;
        candidate = c;
      }
    }
  });

  if (candidate) {
    candidate.occupied = true;
  }

  return candidate;
};

//--------
//--------

/**
 *
 * @param {Array} data
 * @param {Number} width
 * @param {Number} height
 */
function gridify(data, width, height) {
  console.log(data);


  grid.init(data, width, height);
  data.nodes.forEach(node => {
    const cell = grid.occupy(node);
    node.x = cell.x;
    node.y = cell.y;
  });
  // const g = d3ToGraphlib(data)
  // console.log(g)
}

export default function createLayout() {
  let simulation = null;
  let width = 0;
  let height = 0;
  const callbacks = {
    end: () => {},
    tick: () => {},
  };
  let data = [];

  const inner = function wrapper(rawData, widthIn, heightIn) {
    data = rawData;
    width = widthIn;
    height = heightIn;
    setup();
    simulation.restart();
  };

  function setup() {
    setupData();
    setupSimulation();
  }

  function setupData() {
    data.nodes.forEach(n => {
      n.radius = 10;
      if (n.startNode) {
        n.fx = height / 20;
        n.fy = width / 20;
      }
    });
  }

  function setupSimulation() {
    simulation = d3.forceSimulation()
      .velocityDecay(0.2)
      .alphaMin(0.1)
      .on('tick', ticked)
      .on('end', ended);

    simulation.stop();

    simulation.nodes(data.nodes);

    const linkForce = d3.forceLink()
      .distance(100)
      .strength(0.5)
      .links(data.edges)
      .id(n => n.id);

    simulation.force('links', linkForce);
    simulation.force('center', d3.forceCenter(width / 2, (height / 2)));

    // setup many body force to have nodes repel one another
    // increasing the chargePower here to make nodes stand about
    // const chargePower = 1.0;
    const chargePower = 0.8;
    function charge(d) {
      return -Math.pow(d.radius, 2.0) * chargePower;
    }

    simulation.force('charge', d3.forceManyBody().strength(charge)); //.distanceMax(100));
  }

  function ended() {
    gridify(data, width, height);
    console.log(data);
    callbacks['end']();
  }

  function ticked() {
    callbacks['tick']();
  }

  inner.on = function on(event, callback) {
    callbacks[event] = callback;
  };

  return inner;
}
