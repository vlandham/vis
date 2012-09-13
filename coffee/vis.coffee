

$ ->

  svg = d3.select("#vis").append("svg")
    .attr("width", 800)
    .attr("height", 600)


  defs = svg.append("defs")

  hatch1 = defs.append("pattern")
    .attr("id", "lines-tight-pattern")
    .attr("patternUnits", "userSpaceOnUse")
    .attr("x", 0)
    .attr("y", 3)
    .attr("width", 5)
    .attr("height", 3)
  hatch1.append("path")
    .attr("d", "M0 0 H 5")
    .style("fill", "none")
    .style("stroke", "#444")
    .style("stroke-width", 1.3)

  diag = defs.append("pattern")
    .attr("id", "diag-pattern")
    .attr("patternUnits", "userSpaceOnUse")
    .attr("x", 0)
    .attr("y", 3)
    .attr("width", 5)
    .attr("height", 5)
  diag.append("path")
    .attr("d", "M0 0 l5 5")
    .style("fill", "none")
    .style("stroke", "red")
    .style("stroke-width", 1)
  diag.append("path")
    .attr("d", "M5 0 l-5 5")
    .style("fill", "none")
    .style("stroke", "red")
    .style("stroke-width", 1)
    

  dots = defs.append("pattern")
    .attr("id", "circles-pattern")
    .attr("patternUnits", "userSpaceOnUse")
    .attr("x", 10)
    .attr("y",10)
    .attr("width", 10)
    .attr("height", 10)
    .append("circle")
    .attr("cx", 4)
    .attr("cy", 4)
    .attr("r", 3)
    .attr("fill", "skyblue")

  patterns = ["lines-tight-pattern", "circles-pattern", "diag-pattern"]

  rects = svg.selectAll("rect").data(patterns)

  rects.enter().append("path")
    .attr("d", "M0 0 l50 10 l40 -20 l80 50 l40 80 l-120 -80 l-80 60z")
    .attr("fill", (d) -> "url(##{d})")
    .attr("transform", (d,i) -> "translate(#{5 + (230 * i)},#{50})")
    .style("stroke", "black")
    .style("stroke-width", 2)
    .each((d) -> console.log(d))



