
root = exports ? this

$ ->

  data_key = {
    budget: "Budget",
    gross: "Worldwide Gross",
    rating: "Rotten Tomatoes"
  }

  w = 920
  h = 500
  r = 5
  [pt, pr, pb, pl] = [20, 20, 40, 40]

  root.options = {top: 15, bottom: 0, genres: null, year: "all", stories: null, sort:"rating"}

  data = null
  all_data = null
  vis = null
  body = null

  x_scale = d3.scale.linear().range([0, w])
  y_scale = d3.scale.linear().range([0, h])
# set domain manually for r scale
  r_scale = d3.scale.linear().range([4, 12]).domain([0,310])
  color = d3.scale.category20()


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
      bottom_data = data[bottom_start_index + 1..-1]
      data = d3.merge([top_data, bottom_data])

  update_scales = () =>
    max_budget = d3.max data, (d) -> parseFloat(d["Budget"])
    min_budget = 0

    #max_y = d3.max data, (d) -> parseFloat(d[data_key[y_key]])
    # min_rating = d3.min data, (d) -> parseFloat(d["Rotten Tomatoes"])
    max_y = 100
    min_y = 0
    
    x_scale.domain([min_budget, max_budget])
    y_scale.domain([min_y, max_y])


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
      .transition()
      .duration(1000)
      .attr("transform", (d) -> "translate(#{x_scale(d["Budget"])},#{y_scale(d["Rotten Tomatoes"])})")

      movies.append("circle")
      .attr("r", (d) -> r_scale(parseFloat(d["Budget"])))
      .attr("fill-opacity", 0.8)
      .attr("fill", (d) -> color(d["Genre"]))

    movies.transition()
      .duration(1000)
      .attr("transform", (d) -> "translate(#{x_scale(d["Budget"])},#{y_scale(d["Rotten Tomatoes"])})")

    movies.exit().transition()
      .duration(1000)
      .attr("transform", (d) -> "translate(#{0},#{0})")
    .remove()
  
  render_vis = (csv) ->
    all_data = pre_filter(csv)
    update_data()

    vis = d3.select("#vis")
      .append("svg")
      .attr("width", w + (pl + pr) )
      .attr("height", h + (pt + pb) )
      .attr("id", "vis-svg")
    .append("g")
      .attr("transform", "translate(#{0},#{h + (pt + pb)})scale(1,-1)")
   
    vis.append("rect")
      .attr("width", w + (pl + pr) )
      .attr("height", h + (pt + pb) )
      .attr("fill", "#ffffff")
      .attr("pointer-events","all")

    body = vis.append("g")
      .attr("transform", "translate(#{pl},#{pb})")

    body.append("line")
      .attr("x1", 0)
      .attr("y1", h)
      .attr("x2", w)
      .attr("y2", h)
      .attr("stroke", "#444")

    body.append("line")
      .attr("x1", 0)
      .attr("y1", 0)
      .attr("x2", w)
      .attr("y2", 0)
      .attr("stroke", "#444")
 
    body.append("line")
      .attr("x1", 0)
      .attr("y1", 0)
      .attr("x2", 0)
      .attr("y2", h)
      .attr("stroke", "#444")

    draw_movies()

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

    # unselected_movies = movies.selectAll("g")
    #   .filter( (d) -> d.id != movie_data.id)
    # .selectAll("line")
    #   .transition()
    #     .duration(100)
    #     .attr("stroke", "#333")
    #     .attr("stroke-opacity", 0.8)


  d3.csv "data/movies_all.csv", render_vis

  update = () =>
    update_data()
    draw_movies()

  root.update_options = (new_options) =>
    root.options = $.extend({}, root.options, new_options)
    console.log(root.options)
    update()






