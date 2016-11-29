
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
    const yPadding = 20;
    const cellWidth = width / data[0].length;
    const cellHeight = (height - (yPadding * data.length)) / data.length;

    const color = d3.scaleLinear()
      .domain(meta.extent)
      .range(['#ffe4c4', '#f9a743']);

    const y = d3.scaleLinear()
      .domain([0, meta.extent[1]])
      .range([0, cellHeight]);

    return {
      color,
      y,
      cellWidth,
      cellHeight,
      yPadding,
    };
  }

  function update() {
    const scales = updateScales();

    const rowE = g.selectAll('.row')
      .data(data)
      .enter()
      .append('g')
      .classed('row', true)
      .attr('transform', (d, i) => `translate(${0},${i * (scales.cellHeight + scales.yPadding)})`);

    rowE.selectAll('.rect')
      .data(d => d)
      .enter()
      .append('rect')
      .attr('class', 'rect')
      .attr('fill', '#f9a743')
      .attr('x', (d, i) => i * scales.cellWidth)
      .attr('y', d => scales.cellHeight - scales.y(d))
      .attr('width', scales.cellWidth)
      .attr('height', d => scales.y(d));
  }

  return chart;
}
