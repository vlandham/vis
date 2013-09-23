
defaultColor = "#f00"
colors = [{color1:defaultColor, color2:defaultColor}]
domains = {rgb:[0,442], lab:[0,100]}
scales = {}

diffs = []

maxWidth = 200

svg = null

setup = () ->
  svg = d3.select("#vis")
    .append("svg")


  scales['rgb'] = d3.scale.linear().domain(domains['rgb']).range([0,maxWidth])
  scales['lab'] = d3.scale.linear().domain(domains['lab']).range([0,maxWidth])

euclideanDistance = (a, b) ->
  d = Math.sqrt(Math.pow((b[0] - a[0]), 2) + Math.pow((b[1] - a[1]), 2) + Math.pow((b[2] - a[2]), 2))
  d


rgbDiff = (c) ->
  rgb1 = d3.rgb( c.color1)
  rgb2 = d3.rgb( c.color2)
  rgb1Array = [rgb1.r, rgb1.g, rgb1.b]
  rgb2Array = [rgb2.r, rgb2.g, rgb2.b]
  d = euclideanDistance(rgb1Array, rgb2Array)
  d

labDiff = (c) ->
  lab1 = d3.lab( c.color1)
  lab2 = d3.lab( c.color2)
  lab1Array = [lab1.l, lab1.a, lab1.b]
  lab2Array = [lab2.l, lab2.a, lab2.b]
  d = euclideanDistance(lab1Array, lab2Array)
  d

computeDiffs = () ->
  diffs = []
  colors.forEach (c) ->
    d = {}
    d['color1'] = c.color1
    d['color2'] = c.color2
    d['rgb'] = rgbDiff(c)
    d['lab'] = labDiff(c)
    diffs.push(d)
  diffs


displayDiffs = () ->
  diff = svg.selectAll(".diff")
    .data(diffs)

  rectSize = 50

  svg
    .attr("height", ((diffs.length + 1) * (rectSize + 20)))


  g = diff.enter()
    .append("g")
  g.append("rect")
    .attr("width", rectSize)
    .attr("height", rectSize)
    .attr("x", rectSize / 3)
    .attr("y", (d,i) -> 10 + ((rectSize + 10) * i))
    .attr("fill", (d) -> d.color1)
  g.append("rect")
    .attr("width", rectSize)
    .attr("height", rectSize)
    .attr("x", rectSize / 3 + rectSize + 10)
    .attr("y", (d,i) -> 10 + ((rectSize + 10) * i))
    .attr("fill", (d) -> d.color2)

  g.append("rect")
    .attr("width", (d) -> scales['rgb'](d.rgb))
    .attr("height", rectSize / 2)
    .attr("x", rectSize / 3 + (rectSize + 10) * 2)
    .attr("y", (d,i) -> 10 + ((rectSize + 10) * i))
    .attr("fill", (d) -> 'steelblue')

  g.append("rect")
    .attr("width", (d) -> scales['lab'](d.lab))
    .attr("height", rectSize / 2)
    .attr("x", rectSize / 3 + (rectSize + 10) * 2 + ( maxWidth + 20))
    .attr("y", (d,i) -> 10 + ((rectSize + 10) * i))
    .attr("fill", (d) -> 'steelblue')

colorChange = (color) ->
  el = $(this)
  id = el.attr("id")
  colors[id] = color.toHexString()
  c = {color1:$("#color1").spectrum("get").toHexString(), color2:$("#color2").spectrum("get").toHexString()}
  colors.push(c)

  computeDiffs()
  displayDiffs()

$ ->

  $('.color').spectrum({
    color: "#{defaultColor}",
    checkoutFiresChange: true,
    change: colorChange
   })

  setup()

