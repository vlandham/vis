
import * as d3 from 'd3';

export default function createChart() {
  const width = 500;
  const height = 500;
  const margin = { top: 20, right: 20, bottom: 20, left: 20 };
  let g = null;
  let data = [];
  let meta = {};

  const chart = function wrapper(selection, rawData) {
    console.log(rawData);

    data = rawData.data;
    meta = rawData.meta;

    const svg = d3.select(selection).append('svg')
      .attr('width', width + margin.left + margin.right)
      .attr('height', height + margin.top + margin.bottom);

    g = svg.append('g')
      .attr('transform', `translate(${margin.left},${margin.top})`);
    update();
  };

  function updateScales() {
    const color = d3.scaleLinear()
      .domain(meta.extent)
      .range(['#ffe4c4', '#f9a743']);

    return {
      color,
    };
  }

  function update() {
    const scales = updateScales();
    const cellWidth = width / data[0].length;
    const cellHeight = height / data.length;

    const rowE = g.selectAll('.row')
      .data(data)
      .enter()
      .append('g')
      .classed('row', true)
      .attr('transform', (d, i) => `translate(${0},${i * cellHeight})`);

    rowE.selectAll('.rect')
      .data(d => d)
      .enter()
      .append('rect')
      .attr('class', 'rect')
      .attr('fill', scales.color)
      .attr('x', (d, i) => i * cellWidth)
      .attr('y', 0)
      .attr('width', cellWidth)
      .attr('height', cellHeight);
  }

  return chart;
}
