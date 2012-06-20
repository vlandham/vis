
root = exports ? this

Network = () ->
  width = 960
  height = 900
  margin = {top: 10, right: 10, bottom: 10, left: 10}
  radius = 6
  tickCount = 0
  damper = 0.1

  strokeOpacity = 0.6
  strokeWidth = 0.8

  edgeColors = d3.scale.ordinal().range(["#444", "#444", "#d62728", "#d62728", "#2ca02c"]).domain(["-->","<--","--|","|--","---"])
  nodeColors = d3.scale.ordinal().range(["#d62728", "#1f77b4", "#2ca02c"]).domain(["receptor","ligand","adhesion"])

  data = null
  baseG = null
  nodes = []
  edges = []
  force = d3.layout.force().charge(-20)
    .size([width, height])
    .linkDistance(50)
    .linkStrength(0.1)

  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)

  centers = {}

  indexFor = (node,i) ->
    "#{node["Sample#{i}"]}_#{node["Symbol#{i}"]}"

  interactions =
    "-->":
      1: "ligand"
      2: "receptor"
    "<--":
      1: "receptor"
      2: "ligand"
    "--|":
      1: "ligand"
      2: "receptor"
    "|--":
      1: "receptor"
      2: "ligand"
    "---":
      1: "adhesion"
      2: "adhesion"

  getInteraction = (interaction, currentSide) ->
    interactions[interaction][currentSide]

  nodeType = (node) ->
    type = ""
    if node.interactions.indexOf("ligand") != -1
      type = "ligand"
    else if node.interactions.indexOf("receptor") != -1
      type = "receptor"
    else
      type = "adhesion"
    type

  centerFor = (d) ->
    centers[d.group][d.sample]

  radialPoint = (v, rad) ->
    x = ((width / 2) + rad * Math.cos( v * Math.PI / 180))
    y = ((height / 2) + rad * Math.sin( v * Math.PI / 180))
    {x:x,y:y}

  buildCenters = (groups) ->
    pos = 0
    groupCount = d3.keys(groups).length
    d3.entries(groups).forEach (g, i) ->
      sampleCount = d3.keys(g.value).length
      centers[g.key] = {}
      d3.entries(g.value).forEach (s, j) ->
        console.log(sampleCount)
        x = (width / sampleCount) * (j + 1) + 20
        y = (height / groupCount) * (i + 1) + 20
        centers[g.key][s.key] = {x:x,y:y}
        pos += 35

  extractNodes = (data) ->
    nodes = {}
    group_samples = {}
    index = 0
    data.forEach (d) ->
      [1,2].forEach (i) ->
        if !nodes[indexFor(d,i)]
          newNode= {side: i, name:d["Symbol#{i}"], sample:d["Sample#{i}"], group:d["Group#{i}"], lfpkm:d["LFPKM#{i}"], stdres:d["Stdres#{i}"], index:index, interactions:[getInteraction(d["Interaction"], i)]}
          nodes[indexFor(d,i)] = newNode
          index += 1
          group_samples[newNode.group] ?= {}
          group_samples[newNode.group][newNode.sample] ?= 0
          group_samples[newNode.group][newNode.sample] += 1
        else
          nodes[indexFor(d,i)].interactions.push(getInteraction(d["Interaction"],i))
    buildCenters(group_samples)
    nodes

  extractEdges = (data, nodes) ->
    edges = []
    data.forEach (d) ->
      d.source = nodes[indexFor(d,1)]
      d.target = nodes[indexFor(d,2)]
      edges.push d
    edges

  chart = (selection) ->
    selection.each (rawData) ->
      data = rawData

      nodes = extractNodes(data)
      edges = extractEdges(data,nodes)

      force.size([width,height])
      force
        .nodes(d3.values(nodes), (d) -> d.name)
        # .links(edges)
        .start()

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      svg.append("rect")
        .attr("width", width + margin.left + margin.right )
        .attr("height", height + margin.top + margin.bottom )
        .attr("fill", "none")

      baseG = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      link = baseG.selectAll("line.link")
        .data(edges)
        .enter().append("line")
        .attr("class", "link")
        .attr("stroke", (d) -> edgeColors(d["Interaction"]))
        .attr("stroke-opacity", 0)

      node = baseG.append("g").attr("id", "nodesG").selectAll("circle.node")
        .data(d3.values(nodes), (d) -> d.name)
        .enter().append("circle")
        .attr("class", "node")
        # .attr("r", (d) -> d.interactions.length)
        .attr("r", (d) -> radius)
        .style("fill", (d) -> nodeColors(nodeType(d)))
        .call(force.drag)
        .on("click", showDetails)

      key = d3.select("#key")
      key.selectAll("p")
        .data(edgeColors.domain())
        .enter().append("p")
         .style("color", (d,i) -> edgeColors.range()[i])
         .style("font-size", "15px")
        .text((d) -> d)

      force.on "tick", (e) ->
        node.each(moveTorwardsCenters(e.alpha))
          .attr("cx", (d) -> d.x)
          .attr("cy", (d) -> d.y)
        
        tickCount += 1

        if (tickCount > 100)
          force.stop()
          addEdges()


  showDetails = (d,i) ->
    console.log(d)

  addEdges = () ->
    baseG.selectAll("line.link")
      .attr("class", "link")
      .attr("stroke", (d) -> edgeColors(d["Interaction"]))
      .attr("stroke-opacity", 0.8)
      .attr("x1", (d) -> d.source.x)
      .attr("y1", (d) -> d.source.y)
      .attr("x2", (d) -> d.target.x)
      .attr("y2", (d) -> d.target.y)
    

  moveTorwardsCenters = (alpha) ->
    (d) ->
      center = centerFor(d)
      d.x = d.x + (center.x - d.x) * ((damper + 0.02) * alpha)
      d.y = d.y + (center.y - d.y) * ((damper + 0.02) * alpha)

  chart.height = (_) ->
    if !arguments.length
      return height
    height = _
    chart

  chart.width = (_) ->
    if !arguments.length
      return width
    width = _
    chart

  chart.margin = (_) ->
    if !arguments.length
      return margin
    margin = _
    chart

  chart.x = (_) ->
    if !arguments.length
      return xValue
    xValue = _
    chart

  chart.y = (_) ->
    if !arguments.length
      return yValue
    yValue = _
    chart

  return chart

root.Network = Network

root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)


$ ->
  render_vis = (data) ->
    plot = Network()
    root.plotData("#vis", data, plot)

  d3.tsv "data/graph.master.stem-strom.txt", render_vis
