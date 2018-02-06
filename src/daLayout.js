import dagre from 'dagre';
import * as d3 from 'd3';
import { d3ToGraphlib, graphlibToD3, linkEdges } from './util/graph';

export default function createLayout() {
  let data = [];
  let width = null;
  let height = null;
  const callbacks = {
    end: () => {},
    tick: () => {},
  };

  const inner = function wrapper(rawData, widthIn, heightIn) {
    data = rawData;
    width = widthIn;
    height = heightIn;
    setup();
  };

  function setupData() {
    data.nodes.forEach((n) => {
      n.width = 150;
      n.height = 100;
    });
  }

  function setup() {

    setupData();

    const daGraph = d3ToGraphlib(data);
    dagre.layout(daGraph);

    console.log(daGraph)
    fixGraph(daGraph)
    linkEdges(data)
    // const graph = graphlibToD3(daGraph);
    // console.log(graph)
    callbacks['end']();
  }

  function fixGraph(graph) {
    let minX = Infinity;
    let minY = Infinity;
    let maxX = -Infinity;
    let maxY = -Infinity;

    graph.nodes().forEach((nName) => {
      console.log(nName)
      const n = graph.node(nName);
      if (n) {
        minX = n.x < minX ? n.x : minX;
        maxX = n.x > maxX ? n.x : maxX;
        minY = n.y < minY ? n.y : minY;
        maxY = n.y > maxY ? n.y : maxY;
      }
    });

    const xScale = d3.scaleLinear()
      .domain([minX, maxX])
      .range([0, width]);

    const yScale = d3.scaleLinear()
      .domain([minY, maxY])
      .range([0, height])

    graph.nodes().forEach((nName) => {
      console.log(nName)
      const n = graph.node(nName)
      if (n) {
        n.orgX = n.x;
        n.orgY = n.y;
        n.x = xScale(n.x);
        n.y = yScale(n.y);
      }
    });
  }

  inner.on = function on(event, callback) {
    callbacks[event] = callback;
  };

  return inner;
};
