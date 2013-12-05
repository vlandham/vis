
root = exports ? this

keepers = [
  "stchintrst"
  "stcheasy"
  "schallenge"
  "senjoying"
  # "sboring"
  "sskills"
  # 'langfriend'
  'menjoying'
  # 'stests'
  # 'sex'
  'waste'
]

types = {'sex':'string', 'waste':'string'}

Plot = () ->
  width = 900
  height = 600
  data = []
  allData = []
  points = null
  colors = {}
  margin = {top: 20, right: 20, bottom: 20, left: 20}
  xScale = d3.scale.linear().domain([0,10]).range([0,width])
  yScale = d3.scale.linear().domain([0,10]).range([0,height])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)
  # color = d3.scale.linear()
  #   .domain([9,50])
  #   .range(['steelblue', 'brown'])
  #   .interpolate(d3.interpolateLab)
  #
  colorGen = d3.scale.category10()
  color = (d) -> colors[d.waste]

  filterData = (data) ->
    stable = data.filter (d) -> d['waste'] == "Stable"
    risk = data.filter (d) -> d['waste'] == "At-risk"
    stable = stable.slice(0,risk.length)
    all = stable.concat(risk)
    console.log(all.length)
    d3.shuffle(all)

  prepareData = (data, waste) ->
    data = data.filter (d) -> if !waste then true else d['waste'] == waste
    # data = d3.shuffle(data)
    # data = data.slice(0,2000)
    newData = []
    data.forEach (d) ->
      newD = {}
      keepers.forEach (k) ->
        newD[k] = if types[k] != "string" then parseFloat(d[k]) else d[k]
      colors[d['waste']] = colorGen(d["waste"])
      newData.push(newD)

      # d3.keys(d).forEach (k) ->
        # d[k] = parseInt(d[k])
    newData

  chart = (selection) ->
    selection.each (rawData) ->
      allData = filterData(rawData)
      bothData = prepareData(allData, null)
      pcs = d3.parcoords()("#both")
        .data(bothData)
        .alpha(0.1)
        # .color("#000")
        .color((d) -> colorGen(d.waste))
        .margin({ top: 24, left: 10, bottom: 12, right: 10 })
        .mode("queue")
        # .dimensions(keepers)
        .render()
        .brushable()
        .reorderable()

      stableData = prepareData(rawData, "Stable")
      console.log(stableData.length)
      pcs = d3.parcoords()("#vis")
        .data(stableData)
        .alpha(0.1)
        # .color("#000")
        .color((d) -> colorGen(d.waste))
        .margin({ top: 24, left: 10, bottom: 12, right: 10 })
        .mode("queue")
        # .dimensions(keepers)
        .render()
        .brushable()
        .reorderable()

      atRiskData = prepareData(rawData, "At-risk")
      console.log(atRiskData.length)
      pcs = d3.parcoords()("#at_risk")
        .data(atRiskData)
        .alpha(0.1)
        # .color("#000")
        .color((d) -> colorGen(d.waste))
        .margin({ top: 24, left: 10, bottom: 12, right: 10 })
        .mode("queue")
        # .dimensions(keepers)
        .render()
        .brushable()
        .reorderable()
        # .interactive()

      # svg = d3.select(this).selectAll("svg").data([data])
      # gEnter = svg.enter().append("svg").append("g")
      
      # svg.attr("width", width + margin.left + margin.right )
      # svg.attr("height", height + margin.top + margin.bottom )

      # g = svg.select("g")
        # .attr("transform", "translate(#{margin.left},#{margin.top})")

      # points = g.append("g").attr("id", "vis_points")
      # update()

  update = () ->
    points.selectAll(".point")
      .data(data).enter()
      .append("circle")
      .attr("cx", (d) -> xScale(xValue(d)))
      .attr("cy", (d) -> yScale(yValue(d)))
      .attr("r", 4)
      .attr("fill", "steelblue")

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

root.Plot = Plot

root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)


$ ->

  plot = Plot()
  display = (error, data) ->
    plotData("#vis", data, plot)

  queue()
    .defer(d3.tsv, "data/rf_imputed_student.txt")
    .await(display)

