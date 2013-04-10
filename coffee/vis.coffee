
root = exports ? this

rect_width = 100
rect_height = rect_width

salmon = "#FC6E60"
hatch_color = "#6ED3CD"
hatch_color = "#888"
dark_yellow = "#AEA020"
yellow = "#FEE92C"
gray = "#303031"


stroke_color = salmon
stroke1_color = gray

width = 1280
height = 800

padding = 25

mid_points = [(width / 3) / 2, (width / 2), width - ((width / 3) / 2)]

rect_y = (height / 2) - padding * 2

svg = d3.select("#vis").append("svg")
  .attr("width", width)
  .attr("height", height)

defs = svg.append('defs')

hatch1 = defs.append("pattern")
  # .attr("id", "lines-tight-pattern")
  .attr("id", "rect1-pattern")
  .attr("patternUnits", "userSpaceOnUse")
  .attr("patternTransform", "rotate(#{-210})")
  .attr("x", 0)
  .attr("y", 2)
  .attr("width", 5)
  .attr("height", 3)
  .append("g")
hatch1.append("path")
  .attr("d", "M0 0 H 5")
  .style("fill", "none")
  .style("stroke", gray)
  .style("stroke-width", 1.6)

hatch1 = defs.append("pattern")
  # .attr("id", "lines-tight-pattern")
  .attr("id", "rect-pattern")
  .attr("patternUnits", "userSpaceOnUse")
  .attr("patternTransform", "rotate(#{-210})")
  .attr("x", 0)
  .attr("y", 2)
  .attr("width", 5)
  .attr("height", 3)
  .append("g")
hatch1.append("path")
  .attr("d", "M0 0 H 5")
  .style("fill", "none")
  .style("stroke", salmon)
  .style("stroke-width", 1.6)

diag = defs.append("pattern")
  # .attr("id", "rect-pattern")
  .attr("id", "unrect-pattern")
  .attr("patternUnits", "userSpaceOnUse")
  .attr("x", 0)
  .attr("y", 3)
  .attr("width", 5)
  .attr("height", 5)
diag.append("path")
  .attr("d", "M0 0 l5 5")
  .style("fill", "none")
  .style("stroke", stroke1_color)
  .style("stroke-width", 1)
diag.append("path")
  .attr("d", "M5 0 l-5 5")
  .style("fill", "none")
  .style("stroke", stroke1_color)
  .style("stroke-width", 1)

start_three = () ->

  rect1_x = mid_points[2] - padding - rect_width
  rect2_x = mid_points[2] + padding

  circle_radius = 50
  new_circle_radius = 65

  panel_three = svg.append("rect")
    .attr("width", rect_width)
    .attr("height", rect_height)
    .attr("fill", "url(#rect1-pattern)")
    .attr("stroke", stroke1_color)
    # .attr("transform", "translate(#{rect1_x},#{130})")
    .attr("transform", "translate(#{rect1_x},#{rect_y - (rect_height / 2) - padding})")

  circle = svg.append("circle")
    .attr("r", circle_radius)
    .attr("fill", "url(#rect1-pattern)")
    .attr("stroke", stroke1_color)
    # .attr("transform", "translate(#{rect1_x + (circle_radius)},#{310})")
    .attr("transform", "translate(#{rect1_x + (circle_radius)},#{rect_y + rect_height + padding})")

  
  circle_two = svg.append("circle")
    .attr("r", 50)
    .attr("opacity", 1)
    .attr("fill", "url(#rect-pattern)")
    .attr("stroke", stroke_color)
    # .attr("transform", "translate(#{rect1_x + (circle_radius)},#{310})")
    .attr("transform", "translate(#{rect1_x + (circle_radius)},#{rect_y + rect_height + padding})")

  circle_two.transition()
    .delay(100)
    .duration(500)
    # .attr("transform", "translate(#{rect2_x + (padding * 2)},#{230})")
    .attr("transform", "translate(#{rect2_x + circle_radius},#{rect_y + circle_radius / 2 + padding})")
    .attr("r", new_circle_radius)
    .transition()
    .duration(500)
    .attr("opacity", 1e-6)

  rect_two = svg.append("rect")
    .attr("width", rect_width)
    .attr("height", rect_height)
    .attr("fill", "url(#rect-pattern)")
    .attr("stroke", stroke_color)
    # .attr("transform", "translate(#{rect1_x},#{130})")
    .attr("transform", "translate(#{rect1_x},#{rect_y - (rect_height / 2) - padding})")
    .attr("rx", 0)
    .attr("ry", 0)

  rect_two.transition()
    .delay(100)
    .duration(500)
    # .attr("transform", "translate(#{rect2_x},#{180})")
    .attr("transform", "translate(#{rect2_x},#{rect_y})")
    .transition()
    .duration(500)
    .attr("rx", 20)
    .attr("ry", 20)


start_two = () ->

  rect1_x = mid_points[1] - padding - rect_width
  rect2_x = mid_points[1] + padding

  panel_two = svg.append("rect")
    .attr("width", rect_width)
    .attr("height", rect_height)
    .attr("fill", "url(#rect1-pattern)")
    .attr("stroke", stroke1_color)
    .attr("transform", "translate(#{rect1_x},#{rect_y})")

  rectangle = svg.append("rect")
    .attr("width", rect_width)
    .attr("height", rect_height)
    .attr("fill", "url(#rect-pattern)")
    .attr("stroke", stroke_color)
    .attr("transform", "translate(#{rect1_x},#{rect_y})")

  rectangle.transition()
    .delay(100)
    .duration(500)
    .attr("transform", "translate(#{rect2_x},#{rect_y})")
    .transition()
    .duration(500)
    .attr("height", rect_height * 2)
    .attr("transform", "translate(#{rect2_x},#{rect_y - (rect_height / 2)})")
    .each("end", start_three)

start = () ->

  rect1_x = mid_points[0] - padding - rect_width
  rect2_x = mid_points[0] + padding

  panel_one = svg.append("rect")
    .attr("width", rect_width)
    .attr("height", rect_height)
    .attr("fill", "url(#rect1-pattern)")
    .attr("stroke", stroke1_color)
    .attr("transform", "translate(#{rect1_x},#{rect_y})")

  copy = svg.append("rect")
    .attr("width", rect_width)
    .attr("height", rect_height)
    .attr("fill", "url(#rect-pattern)")
    .attr("stroke", stroke_color)
    .attr("transform", "translate(#{rect1_x},#{rect_y})")

  copy.transition()
    .delay(100)
    .duration(500)
    .attr("transform", "translate(#{rect2_x},#{rect_y})")
    .each("end", start_two)


labels = () ->

  texts = ['COPY', 'TRANSFORM', 'COMBINE']

  text_y = rect_y +  rect_height * 2 + padding * 2
  svg.selectAll('.sub').data(mid_points)
    .enter()
    .append('text')
    .attr('class', 'sub')
    .attr('x', (d) -> d)
    .attr('y', text_y)
    .attr("text-anchor", "middle")
    .text((d,i) -> texts[i])

bars = () ->

  svg.selectAll('.bar').data(mid_points)
    .enter()
    .append("line")
    .attr("class", "bar")
    .attr("x1", (d) -> d)
    .attr("x2", (d) -> d)
    .attr("y1", (rect_y + rect_height / 2) - ((rect_height ) + (rect_height / 2)))
    .attr("y2", (rect_y + rect_height / 2 ) +  ((rect_height ) + (rect_height / 2)))
    .attr('stroke', 'black')


title = () ->

  title_y = (rect_y / 2) - padding
  svg.selectAll('.title').data([mid_points[1]])
    .enter()
    .append('text')
    .attr('class', 'title')
    .attr('text-anchor', 'middle')
    .attr('y', title_y)
    .attr('x', (d) -> d)
    .text("EVERYTHING IS A REMIX")


author = () ->

  title_y = rect_y + rect_height * 3 + padding * 2

  svg.append("text")
    .attr('class', 'author')
    .attr('text-anchor', 'middle')
    .attr('y', title_y)
    .attr('x', mid_points[1])
    .text("KIRBY FERGUSON")

$ ->

  title()
  bars()
  labels()
  start()
  author()



