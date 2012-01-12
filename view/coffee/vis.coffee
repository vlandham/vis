
root = exports ? this

$ ->

  w = 800
  h = 600
  r = 3
  [pt, pr, pb, pl] = [10, 10, 10, 10]

  options = {limit: 5, genre: "all", year: "2010", sort:"budget"}

  data = null
  vis = null
  body = null

  x_scale = d3.scale.linear()
  gross_scale = d3.scale.linear()
  budget_scale = d3.scale.linear()
  ratings_scale = d3.scale.linear()
  color = d3.scale.category20()

  pre_filter = (data) ->
    data = data.filter (d) -> d["Budget"] and d["Worldwide Gross"] and d["Rotten Tomatoes"]
    data

  sort_data = (sort_type) =>
    if sort_type == "budget"
      data = data.sort (a,b) ->
        b1 = parseFloat(a["Budget"]) ? 0
        b2 = parseFloat(b["Budget"]) ? 0
        b1 - b2
    else if sort_type == "gross"
      data = data.sort (a,b) ->
        b1 = parseFloat(a["Worldwide Gross"]) ? 0
        b2 = parseFloat(b["Worldwide Gross"]) ? 0
        b1 - b2

  move_movies = () ->
    movies = body.selectAll(".movie")
      .data(data, (d) -> d["id"])

    movies.transition()
      .duration(1000)
      .attr("transform", (d,i) -> "translate(#{x_scale(i)},0)")

  draw_movies = () ->
    movies = body.selectAll(".movie")
      .data(data, (d) -> d["id"])
      .enter().append("circle")
      .attr("cx", (d) -> budget_scale(d["Budget"]))
      .attr("cy", (d) -> ratings_scale(d["Rotten Tomatoes"]))
      .attr("r", r)
      .attr("fill", (d) -> color(d["Genre"]))


    # .enter().append("g")
    #   .attr("class", "movie")
    #   .attr("transform", (d,i) -> "translate(#{x_scale(i)},0)")
    #   .on("mouseover", show_details)
    #   .on("mouseout", hide_details)


    # gross_g = movies.append("g")
      # .attr("transform", "translate(#{0},#{h/2})")

    # gross = gross_g.append("circle")
    #   .attr("cy", (d) -> gross_scale(d["Worldwide Gross"]))
    #   .attr("r", r)
    #   .attr("fill", (d) -> color(d["Genre"]))


    # gross_g.append("line")
    #   .attr("y2", (d) -> gross_scale(d["Worldwide Gross"]))
    #   .attr("stroke", "#444")

    # other_g = movies.append("g")
    #   .attr("transform", "translate(#{0},#{h/2}) scale(1,-1)")

    # other = other_g.append("circle")
    #   .attr("cy", (d) -> budget_scale(d["Budget"]))
    #   .attr("r", r)
    #   .attr("fill", (d) -> color(d["Story"]))

    # other_g.append("line")
    #   .attr("y2", (d) -> budget_scale(d["Budget"]))
    #   .attr("stroke", "#444")

  render_vis = (csv) ->
    data = pre_filter(csv)

    sort_data(options.sort)

    max_gross = d3.max data, (d) -> parseFloat(d["Worldwide Gross"])
    min_gross = 0

    max_budget = d3.max data, (d) -> parseFloat(d["Budget"])
    min_budget = 0

    max_rating = d3.max data, (d) -> parseFloat(d["Rotten Tomatoes"])
    min_rating = d3.min data, (d) -> parseFloat(d["Rotten Tomatoes"])

    x_scale = d3.scale.linear()
      .domain([0, data.length])
      .range([0, w])

    gross_scale = d3.scale.linear()
      .domain([min_gross, max_gross])
      .range([0, h])

    budget_scale = d3.scale.linear()
      .domain([min_budget, max_budget])
      .range([0, w] )


    ratings_scale = d3.scale.linear()
      .domain([min_rating, max_rating])
      .range([0, h])

    vis = d3.select("#vis")
      .append("svg")
      .attr("width", w + 10 )
      .attr("height", h + 10)
      .attr("id", "vis-svg")
    .append("g")
      .attr("transform", "translate(#{0},#{h})scale(1,-1)")
   
    vis.append("rect")
      .attr("width", w + 10)
      .attr("height", h + 10)
      .attr("fill", "#ddd")
      .attr("pointer-events","all")

    body = vis.append("g")
      .attr("transform", "translate(#{5},#{-5})")

    body.append("line")
      .attr("x1", 0)
      .attr("y1", h)
      .attr("x2", w)
      .attr("y2", h)
      .attr("stroke", "#444")

    draw_movies()

  show_details = (movie_data) ->
    movies = body.selectAll(".movie")

    unselected_movies = movies.selectAll("g")
      .filter( (d) -> d.id != movie_data.id)
    .selectAll("circle")
      .transition()
        .duration(100)
        .attr("stroke", "#555")
        .attr("stroke-opacity", 0.2)

  hide_details = (movie_data) ->
    movies = body.selectAll(".movie")

    unselected_movies = movies.selectAll("g")
      .filter( (d) -> d.id != movie_data.id)
    .selectAll("line")
      .transition()
        .duration(100)
        .attr("stroke", "#333")
        .attr("stroke-opacity", 0.8)


  d3.csv "data/movies2010.csv", render_vis

  root.sort_by = (type) =>
    sort_data(type)
    move_movies()



