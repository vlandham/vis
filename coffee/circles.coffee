
dirs = [{'direction':'N', 'color':'#E47445'},
  {'direction':'NE','color': '#E07596'},
  {'direction':'E', 'color': '#D369DC'},
  {'direction':'SE','color': '#9A9BD7'},
  {'direction':'S','color': '#66BDC3'},
  {'direction':'SW','color': '#6EBF7C'},
  {'direction':'W','color': '#78CB40'},
  {'direction':'NW','color':'#C6AD44'}]


$ ->
  svg = d3.select("#vis").append("svg")
  dir = svg.selectAll('.dir')
    .data(dirs).enter()
  dirG = dir
    .append("g")
    .attr("transform", (d,i) -> "translate(200,200)rotate(#{45 + 180 + (45 * i)})")

  dirG.append("circle")
    .attr("r", 25)
    .attr("stroke", "white")
    .attr("stroke-width", 2)
    .attr("fill", (d) -> d.color)
    .attr("cx", 60)
    .attr("cy", 60)

  dirG.append("text")
    .attr('x', 40)
    .attr('y', 40)
    # .text((d) -> d.direction)

