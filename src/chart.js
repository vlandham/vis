
import * as d3 from 'd3';
import { Graph } from '@dagrejs/graphlib';

function graphlibToD3(graph) {

}

function d3ToGraphlib(data) {
  const g = new Graph();
  data.nodes.forEach(n => {
    g.setNode(n.id, n);
  });

  data.edges.forEach(e => {
    g.setEdge(e.source.id, e.target.id, e);
  });

  return g;
}

function dist(a, b) { return Math.pow(a.x - b.x, 2) + Math.pow(a.y - b.y, 2); }

function gridify(data, width, height) {
  console.log(data);
  const gridWidth = width / 10;

  const grid = {};
  grid.cells = [];
  grid.init = () => {
    const cols = width / gridWidth;
    const rows = height / gridWidth;
    d3.range(cols).forEach(col => {
      d3.range(rows).forEach(row => {

        const cell = { x: col * gridWidth, y: row * gridWidth };
        grid.cells.push(cell);

      });
    });
  }


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

  grid.init();
  data.nodes.forEach(node => {
    const cell = grid.occupy(node);
    console.log(cell)
    node.x = cell.x;
    node.y = cell.y;
  })
  // const g = d3ToGraphlib(data)
  // console.log(g)
}

export default function createChart() {
  const width = 500;
  const height = 500;
  const margin = { top: 20, right: 20, bottom: 20, left: 20 };
  let g = null;
  let data = { nodes: [{id: 'a'}, {id: 'b'}], edges: [{source: 'a', target: 'b'}] };
  let edges = null;
  let nodes = null;
  let simulation = null;

  const chart = function wrapper(selection, rawData) {
    console.log(rawData);

    // data = rawData;

    const svg = d3.select(selection).append('svg')
      .attr('width', width + margin.left + margin.right)
      .attr('height', height + margin.top + margin.bottom);

    g = svg.append('g')
      .attr('transform', `translate(${margin.left},${margin.top})`);

    g.append('g').classed('edges', true);
    g.append('g').classed('nodes', true);

    setup();
    update();
    simulation.restart();
  };

  function setup() {
    setupSimulation();
  }

  function update() {
    updateNodes();
    updateEdges();
    updatePos();
  }

  function updateNodes() {
    nodes = g.select('.nodes').selectAll('.node')
      .data(data.nodes, d => d.id);

    const nodesE = nodes.enter().append('circle')
      .classed('node', true)
      .attr('cx', d => d.x)
      .attr('cy', d => d.y);

    nodes.exit().remove();

    nodes = nodes.merge(nodesE)
      .attr('r', 5)
      .style('fill', '#777')
      .style('stroke', 'white')
      // .style('cursor', 'pointer')
      .style('stroke-width', 1.0);
  }

  function updateEdges() {
    edges = g.select('.edges').selectAll('.edge')
      .data(data.edges);

    const edgesE = edges.enter().append('line')
      .classed('edge', true)
      .style('stroke-width', 2)
      .style('stroke', '#ddd');

    edges.exit().remove();
    edges = edges.merge(edgesE);
  }

  function updatePos() {
    nodes
      .attr('cx', d => d.x)
      .attr('cy', d => d.y);

    edges
      .attr('x1', d => d.source.x)
      .attr('y1', d => d.source.y)
      .attr('x2', d => d.target.x)
      .attr('y2', d => d.target.y);
  }

  function setupSimulation() {
    simulation = d3.forceSimulation()
      .velocityDecay(0.2)
      .alphaMin(0.1)
      .on('end', ended);

    simulation.stop();

    simulation.nodes(data.nodes);

    const linkForce = d3.forceLink()
      .distance(100)
      .strength(1)
      .links(data.edges)
      .id(n => n.id);

    simulation.force('links', linkForce);
    simulation.force('center', d3.forceCenter(width / 2, (height / 2) - 160));

    // setup many body force to have nodes repel one another
    // increasing the chargePower here to make nodes stand about
    const chargePower = 1.0;
    function charge(d) {
      return -Math.pow(d.radius, 2.0) * chargePower;
    }
    simulation.force('charge', d3.forceManyBody().strength(charge).distanceMax(100));
  }

  function ended() {
    gridify(data, width, height);
    console.log(data)
    updateNodes();
    updatePos();
  }

  return chart;
}
