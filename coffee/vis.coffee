
root = exports ? this

TreeMap = () ->
  width = 800
  height = 500
  margin = {top: 5, right: 20, bottom: 5, left: 20}
  store_id = -1
  vis = null
  svg = null
  allData = []
  allAverages = []
  data = []

  tooltip = CustomTooltip("my_tooltip", 240)

  size = (d) -> d.all
  color = d3.scale.linear()
    .range(["red", "white", "blue"])
    .range(["#ca0020", "#f7f7f7", "#0571b0"])

  treemap = d3.layout.treemap()
    .size([width, height])
    .mode('squarify')
    .value((d) -> size(d))
    .children((d) -> d.values)
    .sort((a,b) -> a.value - b.value)

  setupData = (rawData) ->
    nested = d3.nest()
      .key((d) -> d.node)
      .key((d) -> d.dim)
      .key((d) -> d.sub)
      .entries(rawData)
    nested

  calculateAverages = (rawData) ->
    nested = d3.nest()
      .key((d) -> d.dim)
      .key((d) -> d.sub)
      .rollup (l) ->
        {
          "count": l.length,
          "all": d3.sum(l, (d) -> parseFloat(d.all)),
          "fill":d3.sum(l, (d) -> parseFloat(d.fill)),
          "fill_rate":d3.sum(l, (d) -> parseFloat(d.fill)) / d3.sum(l, (d) -> parseFloat(d.all))

        }
      .entries(rawData)
    subaverages = {}
    nested.forEach (dim) ->
      dim.values.forEach (sub) ->
        subaverages[dim.key + "_" + sub.key] = sub.values
    subaverages

  filterData = (rawData, subaverages) ->
    if store_id < 0
      store_id = rawData[0].key
    data = rawData.filter (d) -> d.key == store_id
    data = data[0]
    console.log(data)
    data.values.forEach (node) ->
      node.values.forEach (dim) ->
        dim.values.forEach (sub) ->
          sub.fill_rate = parseFloat(sub.fill) / parseFloat(sub.all)
          sub.avg = subaverages[sub.dim + "_" + sub.sub]
          color.domain([sub.avg.fill_rate - 0.1, sub.avg.fill_rate, sub.avg.fill_rate + 0.1])
          sub.color = color(sub.fill_rate)
    data

    
  # arrangeData = (data) ->
  #   fakeHierarchy = {'name':'all', 'children':[]}
  #   data.forEach (d,i) ->
  #     fakeHierarchy.children.push({'name': d.name, 'color': d.rgb_string, 'value': d.count})
  #   fakeHierarchy

  chart = (selection) ->
    selection.each (rawData) ->
      allAverages = calculateAverages(rawData)
      console.log(allAverages)

      allData = setupData(rawData)


      # svg = d3.select(this).selectAll("svg").data([data])
      # gEnter = svg.enter().append("svg").append("g")
      
      # svg.attr("width", width + margin.left + margin.right )
      # svg.attr("height", height + margin.top + margin.bottom )

      # g = svg.select("g")
        # .attr("transform", "translate(#{margin.left},#{margin.top})")

      vis = d3.select(this)
        .style("position", "relative")
        .style("width", (width + margin.left + margin.right) + "px")
        .style("height", (height + margin.top + margin.bottom) + "px")
        .style("left", margin.left + "px")
        .style("top", margin.top + "px")
      # g.append("rect")
      #   .attr("width", width)
      #   .attr("height", height)
      #   .attr("stroke-fill", "none")
      #   .attr("fill", "none")

      # vis = g.append("g").attr("class", "vis_treemap")
      update()

  position = (d) ->
    this.style("left", (d) -> d.x + "px")
      .style("top", (d) -> d.y + "px")
      .style("width", (d) -> Math.max(0, d.dx - 1) + "px")
      .style("height", (d) -> Math.max(0, d.dy - 1) + "px")

  show_details = (data, i, element) =>
    # d3.select(element).attr("stroke", "black")
    content = ""
    # content += "<span class=\"name\">Store:</span><span class=\"value\"> #{data.node}</span><br/>"
    content +="<span class=\"name\">Fill Rate:</span><span class=\"value\"> #{(data.fill_rate)}</span><br/>"
    content +="<span class=\"name\">Total Orders:</span><span class=\"value\"> #{(data.all)}</span><br/>"
    content +="<span class=\"name\">Filled Orders:</span><span class=\"value\"> #{(data.fill)}</span><br/>"
    tooltip.showTooltip(content,d3.event)


  hide_details = (data, i, element) =>
    # d3.select(element).attr("stroke", (d) => d3.rgb(@fill_color(d.group)).darker())
    tooltip.hideTooltip()

  update = () ->
    data = filterData(allData, allAverages)
    console.log(data)

    v = vis.selectAll('.node')
      .data(treemap(data))
    v.enter()
      .append("div")
      .attr("class", "node")
      .on("mouseover", show_details)
      .on("mouseout", hide_details)
    v.exit().remove()
    v.call(position)
      .style("position", 'absolute')
      .style("background", (d) -> d.color)

  chart.updateDisplay = (_) ->
    store_id = _
    update()
    chart

  chart.id = (_) ->
    if !arguments.length
      return store_id
    store_id = _
    chart

  chart.weight = (_) ->
    if !arguments.length
      return weight
    weight = _
    chart

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

  return chart


root.TreeMap = TreeMap

root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)


$ ->

  plot = TreeMap()
  display = (error, data) ->
    plotData("#vis", data, plot)

  queue()
    .defer(d3.csv, "data/test.csv")
    .await(display)

