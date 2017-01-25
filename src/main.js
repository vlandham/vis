import * as d3 from 'd3';

import createChart from './canvasChart';

import '../index.html';
import './style';

const plot = createChart();
const plot2 = createChart().radius(50);
const plot3 = createChart().radius(10);

function display() {
  plot('#vis');
  plot2('#vis');
  plot3('#vis');
}

display();
