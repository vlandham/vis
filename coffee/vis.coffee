
root = exports ? this

parsePath = (path) ->
  cmdRegEx = /[a-z][^a-z]*/ig
  sections = path.match(cmdRegEx)
  parsed = []
  sections.forEach (raw) ->
    command = raw.slice(0,1)
    nums = raw.slice(1).split(",").map((d) -> parseFloat(d)).filter((d) -> !isNaN(d))
    parsedCommand = {'c':command}
    # if nums.length > 1
    parsedCommand['n'] = nums
    parsed.push(parsedCommand)
  parsed



$ ->
  d3.xml 'data/bike.svg', 'image/svg+xml', (error, data) ->
    console.log(error)
    nodes = [1..2]

    svg = data.documentElement

    d3.select("#vis")
      .selectAll(".node")
      .data(nodes).enter()
      .append("div")
      .attr("class", "node")
      .each((d) -> this.appendChild(svg.cloneNode(true)))
      .selectAll("path")
      .attr("fill", "steelblue")
      .each (d) ->
        path = d3.select(this).attr("d")
        console.log(parsePath(path))
      


