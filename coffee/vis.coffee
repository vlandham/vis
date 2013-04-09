
root = exports ? this

width = 1280
height = 800

svg = d3.select("#vis").append("svg")
  .attr("width", width)
  .attr("height", height)

start_three = () ->
  panel_three = svg.append("rect")
    .attr("width", 100)
    .attr("height", 100)
    .attr("transform", "translate(#{850},#{130})")

  circle = svg.append("circle")
    .attr("r", 50)
    .attr("transform", "translate(#{900},#{310})")

  
  circle_two = svg.append("circle")
    .attr("r", 50)
    .attr("opacity", 1)
    .attr("transform", "translate(#{900},#{310})")

  circle_two.transition()
    .delay(100)
    .duration(500)
    .attr("transform", "translate(#{1080},#{230})")
    .transition()
    .duration(500)
    .attr("opacity", 1e-6)

  rect_two = svg.append("rect")
    .attr("width", 100)
    .attr("height", 100)
    .attr("transform", "translate(#{850},#{130})")
    .attr("rx", 0)
    .attr("ry", 0)

  rect_two.transition()
    .delay(100)
    .duration(500)
    .attr("transform", "translate(#{1030},#{180})")
    .transition()
    .duration(500)
    .attr("rx", 20)
    .attr("ry", 20)


start_two = () ->

  panel_two = svg.append("rect")
    .attr("width", 100)
    .attr("height", 100)
    .attr("transform", "translate(#{450},#{200})")

  rectangle = svg.append("rect")
    .attr("width", 100)
    .attr("height", 100)
    .attr("transform", "translate(#{450},#{200})")

  rectangle.transition()
    .delay(100)
    .duration(500)
    .attr("transform", "translate(#{630},#{200})")
    .transition()
    .duration(500)
    .attr("height", 200)
    .attr("transform", "translate(#{630},#{150})")
    .each("end", start_three)

start = () ->

  panel_one = svg.append("rect")
    .attr("width", 100)
    .attr("height", 100)
    .attr("transform", "translate(#{50},#{200})")

  copy = svg.append("rect")
    .attr("width", 100)
    .attr("height", 100)
    .attr("transform", "translate(#{50},#{200})")

  copy.transition()
    .delay(100)
    .duration(500)
    .attr("transform", "translate(#{230},#{200})")
    .each("end", start_two)


labels = () ->

  text_y = 450
  svg.append('text')
    .attr('x', 200)
    .attr('y', text_y)
    .attr("text-anchor", "middle")
    .text("COPY")

  svg.append('text')
    .attr('x', 585)
    .attr('y', text_y)
    .attr("text-anchor", "middle")
    .text("TRANSFORM")

  svg.append('text')
    .attr('x', 975)
    .attr('y', text_y)
    .attr("text-anchor", "middle")
    .text("COMBINE")

$ ->

  start()

  labels()

