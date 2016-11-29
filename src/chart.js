
import * as d3 from 'd3';

export default function createChart() {
  const width = 500;
  const height = 500;
  const margin = { top: 20, right: 20, bottom: 20, left: 20 };
  let g = null;
  let data = [];

  const chart = function wrapper(selection, rawData) {
    console.log(rawData);

    data = rawData;

    const svg = d3.select(selection).append('svg')
      .attr('width', width + margin.left + margin.right)
      .attr('height', height + margin.top + margin.bottom);

    g = svg.append('g')
      .attr('transform', `translate(${margin.left},${margin.top})`);
    update();
  };

  function update() {
    g.selectAll('.rect')
      .data(data)
      .enter()
      .append('rect')
      .attr('class', 'rect')
      .attr('fill', 'steelblue')
      .attr('x', d => d.x * 10)
      .attr('y', d => d.y * 10)
      .attr('width', 10)
      .attr('height', 10)
      .on('mouseover', () => d3.select(this).attr('fill', 'orange'))
      .on('mouseout', () => d3.select(this).attr('fill', 'steelblue'));
  }

  return chart;
}
