
root = exports ? this

$ ->

  w = 920
  h = 600
  r = 5
  [pt, pr, pb, pl] = [10, 10, 10, 10]

  root.options = {limit: 10, order: "descending", genre: "all", year: "all", sort:"budget"}

  root.genres = [
    "all"
  ]

  data = null
  all_data = null
  vis = null
  body = null

  x_scale = d3.scale.linear().range([0, w])
  y_scale = d3.scale.linear().range([0, h])
  color = d3.scale.category20()

 
  pre_filter = (data) ->
    data = data.filter (d) -> d["Budget"] and d["Worldwide Gross"] and d["Rotten Tomatoes"]
    data

  sort_data = (sort_type, sort_order) =>
    if sort_type == "budget"
      data = data.sort (a,b) ->
        b1 = parseFloat(a["Budget"]) ? 0
        b2 = parseFloat(b["Budget"]) ? 0
        if sort_order == "descending" then b1 - b2 else b2 - b1
    else if sort_type == "gross"
      data = data.sort (a,b) ->
        b1 = parseFloat(a["Worldwide Gross"]) ? 0
        b2 = parseFloat(b["Worldwide Gross"]) ? 0
        if sort_order == "descending" then b1 - b2 else b2 - b1

  filter_year = (year) ->
    data = data.filter (d) -> if year == "all" then true else d.year == year

  filter_limit = (limit) ->
    data = data[0..limit]

  update_data = () =>
    data = all_data
    filter_year(root.options.year)
    sort_data(root.options.sort, root.options.order)
    filter_limit(root.options.limit)

  draw_movies = () ->
    movies = body.selectAll(".movie")
      .data(data, (d) -> d.id)

    movies.enter().append("g")
      .attr("class", "movie")
      .transition()
      .duration(1000)
      .attr("transform", (d) -> "translate(#{x_scale(d["Budget"])},#{y_scale(d["Rotten Tomatoes"])})")

      movies.append("circle")
      .attr("r", r)
      .attr("fill", (d) -> color(d["Genre"]))

    movies.transition()
      .duration(1000)
      .attr("transform", (d) -> "translate(#{x_scale(d["Budget"])},#{y_scale(d["Rotten Tomatoes"])})")

    #movies.exit().selectAll('circle').each( (d) -> console.log(this))

    movies.exit().transition()
      .duration(1000)
      .attr("transform", (d) -> "translate(#{0},#{0})")
    .remove()

    # movies.exit().selectAll("circle").transition()
      # .duration(1000)
      # .attr("opacity", 0.2)


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
    all_data = pre_filter(csv)
    update_data()

    max_gross = d3.max data, (d) -> parseFloat(d["Worldwide Gross"])
    min_gross = 0

    max_budget = d3.max data, (d) -> parseFloat(d["Budget"])
    min_budget = 0

    max_rating = d3.max data, (d) -> parseFloat(d["Rotten Tomatoes"])
    min_rating = d3.min data, (d) -> parseFloat(d["Rotten Tomatoes"])

    x_scale.domain([min_budget, max_budget])

    y_scale.domain([min_rating, max_rating])

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
      .attr("fill", "#ddd")
      .attr("pointer-events","all")

    body = vis.append("g")
      .attr("transform", "translate(#{pr},#{pt})")


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


  d3.csv "data/movies_all.csv", render_vis

  update = () =>
    update_data()
    draw_movies()

  root.sort_by = (type) =>
    root.options.sort = type
    update()

  root.set_year = (year) =>
    root.options.year = year
    update()

  root.set_order_limit = (order, limit) =>
    root.options.order = order
    root.options.limit = parseInt(limit)
    console.log(root.options)
    update()






