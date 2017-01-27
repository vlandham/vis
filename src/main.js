
import createWanderingDots from './wanderingDots';
import createWanderingHull from './wanderingHull';
import createHopPlot from './hopPlot';

import '../index.html';
import './style';

const plot = createWanderingDots();
const plot2 = createWanderingDots().radius(50);
const plot3 = createWanderingDots().radius(10);

const hulPlot = createWanderingHull();
const hulPlot2 = createWanderingHull().radius(50);
const hulPlot3 = createWanderingHull().radius(10);

const hplot1 = createHopPlot();
const hplot2 = createHopPlot().interval(1000);
const hplot3 = createHopPlot().trails(true);
const hplot4 = createHopPlot().interval(1000).trails(true);

function display() {
  plot('#dot');
  plot2('#dot');
  plot3('#dot');
  hulPlot('#hull');
  hulPlot2('#hull');
  hulPlot3('#hull');
  hplot1('#hop');
  hplot2('#hop');
  hplot3('#hop');
  hplot4('#hop');
}

display();
