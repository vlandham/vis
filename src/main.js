import * as d3 from 'd3';

import createChart from './chart';
import createHisto from './histo';

import '../index.html';
import './style';

const plot = createChart();
const histo = createHisto();

function display(error, heatmapD, histoD) {
  plot('#vis', heatmapD);
  histo('#histo', histoD);
}

d3.queue()
  .defer(d3.json, 'data/heatmap_data.json')
  .defer(d3.json, 'data/histogram_data.json')
  .await(display);
