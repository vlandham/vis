
StackedArea = () ->
  width = 200
  height = 500
  margin = {top: 5, right: 20, bottom: 5, left: 160}
  user_id = -1
  vis = null
  svg = null
  allData = []
  data = []

  h = d3.scale.linear()

  weight = (d) -> d.count
  maxColors = 20
  maxWeight = 0.85

  filterData = (rawData) ->
    if user_id < 0
      user_id = rawData[0].id
    data = rawData.filter (d) -> d.id == user_id
    data = data[0]
    data

  restrictData = (filteredData) ->
    sortedData = filteredData.sort((a,b) -> weight(b) - weight(a))
    restricted = sortedData
    restricted = []
    totalWeight = sortedData.map((d) -> weight(d)).reduce((p,c) -> p + c)
    curWeight = 0

    for d in sortedData
      curWeight += weight(d)
      restricted.push(d)
      if (curWeight / totalWeight) >= maxWeight
        break

    h.domain([0, curWeight])

    if restricted.length > maxColors
      console.log('still too big ' + restricted.length)
      console.log("removed  #{sortedData.length - restricted.length}")
    restricted

  chart = (selection) ->
    selection.each (rawData) ->

      allData = rawData

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
        .attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      g.append("rect")
        .attr("width", width)
        .attr("height", height)
        .attr("stroke-fill", "none")
        .attr("fill", "none")

      vis = g.append("g").attr("class", "vis_stacked")
      g.append("a")
        .attr("xlink:href", "http://localhost:3000/##{user_id}")
        .attr("target", "_blank")
        .append("rect")
        .attr("width", width)
        .attr("height", height)
        .attr("fill-opacity", 0)
        # .on('click', () -> console.log(user_id))
      
      update()


  update = () ->
    h.range([0, height])
    data = filterData(allData)
    data = restrictData(data.colors)
    # vis.selectAll(".stack").data([]).exit().remove()
    
    v = vis.selectAll(".stack")
      .data(data)

    v.enter().append("rect")
      .attr("width", width)
      .attr("x", 0)
      .attr("class", "stack")

    totalHeight = 0.0
    v.attr "y", (d,i) ->
        height = h(weight(d))
        myY = totalHeight
        totalHeight += height
        myY
      .attr "height", (d,i) ->
        height = h(weight(d))
        height
      .attr("fill", (d) -> d.rgb_string)

    v.exit().remove()
      

  chart.updateDisplay = (_) ->
    user_id = _
    update()
    chart

  chart.id = (_) ->
    if !arguments.length
      return user_id
    user_id = _
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



$ ->
  # stacked_weight = StackedArea()
  # stacked_weight.id(user_id)
  # stacked_weight.weight((d) -> d.weighted_count)

  display = (error, data) ->
   shuffle(data)
   data = data[0..1000]
   data.forEach (d,i) ->
     stacked_weight = StackedArea()
     stacked_weight.id(d.id)
     stacked_weight.weight((e) -> e.weighted_count)
     stacked_weight.width(20)
     stacked_weight.height(60)
     stacked_weight.margin({top: 0, right: 0, bottom: 0, left: 0})

     selector = "vis_#{i}"
     d3.select("#vis").append("div")
      .attr("id", selector)

     d3.select("#" + selector)
       .datum(data)
       .call(stacked_weight)


  queue()
    .defer(d3.json, "data/user_colors.json")
    .await(display)
