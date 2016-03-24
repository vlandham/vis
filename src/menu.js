

var d3 = require('d3');

var m = d3.select('.menu');

var options = [['default', 'Side Names'], ['bar', 'Side Bars'], ['top', 'Horizontal Names'], ['glyph', 'Glyphs'], ['glyphcolor', 'Color Glyphs'], ['dots', 'Top Dots'], ['box', 'Fisheye Dots'] ]

m.selectAll('a').data(options).enter().append('a').attr('href', (d) => '#' + d[0]).text((d) => d[1])
  .on('click', menuClick).classed('btn btn-default', true)

function menuClick(d) {
  window.location.hash = '#' + d[0]
  window.location.reload()

}

// m.append('a').attr('href', '/#default').text('side scroll')
