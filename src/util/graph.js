
import { Graph } from '@dagrejs/graphlib';


export function linkEdges(data) {
  const nodeMap = {};
  data.nodes.forEach(n => (nodeMap[n.id] = n));
  data.edges.forEach((e) => {
    e.source = nodeMap[e.source];
    e.target = nodeMap[e.target];
  });

  return data;
}

export function graphlibToD3(graph) {
  const data = { nodes: [], edges: [] };
  const nodeMap = {}

  graph.nodes().forEach((nName) => {
    const n = graph.node(nName);
    if (n) {
      nodeMap[nName] = n
    }
  });
  graph.edges().forEach((eName) => {
    const source = nodeMap[eName.v];
    const target = nodeMap[eName.w];
    data.edges.push({ source, target });
  });

  Object.keys(nodeMap).forEach((k) => {
    data.nodes.push(nodeMap[k])
  });

  return data;
}

export function d3ToGraphlib(data) {
  const g = new Graph();
  g.setGraph({});
  data.nodes.forEach((n) => {
    // console.log(n.id)
    g.setNode(n.id, n);
  });

  data.edges.forEach((e) => {
    // check if this is a string or an object
    if (e.source !== null && typeof e.source === 'object') {
      g.setEdge(e.source.id, e.target.id, e);
    } else {
      g.setEdge(e.source, e.target, e);
    }
  });

  return g;
}
