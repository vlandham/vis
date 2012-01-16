
root = exports ? this

$ ->

  data_key = {
    budget: "Budget",
    gross: "Worldwide Gross",
    rating: "Rotten Tomatoes"
  }

  w = 860
  h = 450
  [pt, pr, pb, pl] = [20, 20, 50, 60]

  root.options = {top: 25, bottom: 0, genres: null, year: "all", stories: null, sort:"rating"}

  data = null
  all_data = null
  base_vis = null
  vis = null
  body = null

  x_scale = d3.scale.linear().range([0, w])
  y_scale = d3.scale.linear().range([0, h])
  y_scale_reverse = d3.scale.linear().range([0, h])
  # set domain manually for r scale
  r_scale = d3.scale.linear().range([4, 27]).domain([0,310])

  xAxis = d3.svg.axis().scale(x_scale).tickSize(5).tickSubdivide(true)
  yAxis = d3.svg.axis().scale(y_scale_reverse).ticks(5).orient("left")


  color = d3.scale.category10()
  color = d3.scale.ordinal().range(["#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", "#8c564b", "#e377c2", "#7f7f7f", "#bcbd22", "#17becf", "#078B78", "#5C1509", "#CECECE", "#FFEA0A"])

  # TODO: remove and filter data manually
  pre_filter = (data) ->
    data = data.filter (d) -> d["Budget"] and d["Worldwide Gross"] and d["Rotten Tomatoes"] and d["Profit"]
    data

  sort_data = (sort_type) =>
    data = data.sort (a,b) ->
      b1 = parseFloat(a[data_key[sort_type]]) ? 0
      b2 = parseFloat(b[data_key[sort_type]]) ? 0
      b2 - b1

  filter_year = (year) ->
    data = data.filter (d) -> if year == "all" then true else d.year == year

  filter_genres = (genres) =>
    if genres
      data = data.filter (d) -> $.inArray(d["Genre"], genres) != -1

  filter_stories = (stories) =>
    if stories
      data = data.filter (d) -> $.inArray(d["Story"], stories) != -1

  filter_number = (top, bottom) ->
    bottom_start_index = data.length - bottom
    bottom_start_index = 0 if bottom_start_index < 0

    if top >= bottom_start_index
      data = data
    else
      top_data = data[0...top]
      bottom_data = data[bottom_start_index..-1]
      data = d3.merge([top_data, bottom_data])

  update_scales = () =>
    min_y_padding = 3
    min_x_padding = 5

    [min_x, max_x] = d3.extent data, (d) -> parseFloat(d["Profit"])
    min_x = if min_x > 0 then 0 else min_x

    [min_y, max_y] = d3.extent data, (d) -> parseFloat(d[data_key["rating"]])
    y_padding = parseInt(Math.abs(max_y - min_y) / 5)
    y_padding = if y_padding > min_y_padding then y_padding else min_y_padding

    min_y = min_y - y_padding
    min_y = if min_y < 0 then 0 else min_y
    max_y = max_y + y_padding
    max_y = if max_y > 100 then 100 else max_y
    
    x_padding = parseInt(Math.abs(max_x - min_x) / 12)
    x_padding = if x_padding > min_x_padding then x_padding else min_x_padding
    console.log(x_padding)

    min_x = min_x - x_padding
    max_x = max_x + x_padding

    x_scale.domain([min_x, max_x])
    console.log(x_scale.domain())
    y_scale.domain([min_y, max_y])
    y_scale_reverse.domain([max_y, min_y])


  update_data = () =>
    data = all_data
    filter_year(root.options.year)
    filter_genres(root.options.genres)
    filter_stories(root.options.stories)
    sort_data(root.options.sort)
    filter_number(root.options.top, root.options.bottom)
    update_scales()

  draw_movies = () ->
    movies = body.selectAll(".movie")
      .data(data, (d) -> d.id)

    movies.enter().append("g")
      .attr("class", "movie")
      .on("mouseover", show_details)
      .on("mouseout", hide_details)
    .append("circle")
      .attr("r", (d) -> r_scale(parseFloat(d["Budget"])))
      .attr("fill-opacity", 0.85)
      .attr("fill", (d) -> color(d["Genre"]))

    movies.transition()
      .duration(1000)
      .attr("transform", (d) -> "translate(#{x_scale(d["Profit"])},#{y_scale(d["Rotten Tomatoes"])})")

    base_vis.transition()
      .duration(1000)
      .select(".x_axis").call(xAxis)

    base_vis.transition()
      .duration(1000)
      .select(".y_axis").call(yAxis)

    movies.exit().transition()
      .duration(1000)
      .attr("transform", (d) -> "translate(#{0},#{0})")
    .remove()

  draw_movie_details = (detail_div) ->
    detail_div.enter().append("div")
      .attr("class", "movie-detail")
      .attr("id", (d) -> "movie-detail-#{d.id}")
    .append("h3")
      .text((d) -> d["Film"])

    detail_div.exit().remove()
 
  draw_details = () ->
    if root.options.top == 0
      $("#detail-love").hide()
    else
      $("#detail-love").show()

    if root.options.bottom == 0
      $("#detail-hate").hide()
    else
      $("#detail-hate").show()

    top_data = data[0...root.options.top]

    detail_top = d3.select("#detail-love").selectAll(".movie-detail")
      .data(top_data, (d) -> d.id)

    draw_movie_details(detail_top)

    bottom_data = data[root.options.top..-1].reverse()

    detail_bottom = d3.select("#detail-hate").selectAll(".movie-detail")
      .data(bottom_data, (d) -> d.id)

    draw_movie_details(detail_bottom)

  render_vis = (csv) ->
    all_data = pre_filter(csv)
    update_data()

    base_vis = d3.select("#vis")
      .append("svg")
      .attr("width", w + (pl + pr) )
      .attr("height", h + (pt + pb) )
      .attr("id", "vis-svg")

    base_vis.append("rect")
      .attr("width", w + (pl + pr) )
      .attr("height", h + (pt + pb) )
      .attr("fill", "#ffffff")
      .attr("opacity", 0.0)
      .attr("pointer-events","all")

    base_vis.append("g")
      .attr("class", "x_axis")
      .attr("transform", "translate(#{pl},#{h + pt})")
      .call(xAxis)

    base_vis.append("text")
      .attr("x", w/2)
      .attr("y", h + (pt + pb) - 10)
      .attr("text-anchor", "middle")
      .attr("class", "axisTitle")
      .attr("transform", "translate(#{pl},0)")
      .text("Profit ($ mil)")

    base_vis.append("g")
      .attr("class", "y_axis")
      .attr("transform", "translate(#{pl},#{pt})")
      .call(yAxis)


    vis = base_vis.append("g")
      .attr("transform", "translate(#{0},#{h + (pt + pb)})scale(1,-1)")

    vis.append("text")
      .attr("x", h/2)
      .attr("y", 20)
      .attr("text-anchor", "middle")
      .attr("class", "axisTitle")
      .attr("transform", "rotate(270)scale(-1,1)translate(#{pb},#{0})")
      .text("Rating (Rotten Tomatoes %)")
   

    body = vis.append("g")
      .attr("transform", "translate(#{pl},#{pb})")

    draw_movies()

    draw_details()

  show_details = (movie_data) ->
    movies = body.selectAll(".movie")

    unselected_movies = movies.filter( (d) -> d.id != movie_data.id)
    .selectAll("circle")
      .attr("opacity",  0.3)

  hide_details = (movie_data) ->
    movies = body.selectAll(".movie")

    unselected_movies = movies.filter( (d) -> d.id != movie_data.id)
    .selectAll("circle")
      .attr("opacity", 0.8)

  d3.csv "data/movies_all.csv", render_vis

  update = () =>
    update_data()
    draw_movies()
    draw_details()


  root.update_options = (new_options) =>
    root.options = $.extend({}, root.options, new_options)
    update()

