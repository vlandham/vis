import * as d3 from 'd3';

import createChart from './chart';

import '../index.html';
import './style';

const plot = createChart();

function display(error, data) {
  plot('#vis', data);
}

d3.queue()
  .defer(d3.csv, 'data/test.csv')
  .await(display);
