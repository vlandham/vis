
root = exports ? this

parsePath = (path) ->
  cmdRegEx = /[a-z][^a-z]*/ig
  whitespaceRegEx = /\s/g
  path = path.replace(whitespaceRegEx, "")
  sections = path.match(cmdRegEx)
  parsed = []
  sections.forEach (raw) ->
    command = raw.slice(0,1)
    nums = raw.slice(1).split(",").map (d) ->
      (d)
    # merged = []
    # merged = merged.concat.apply(merged, nums)
    # nums = nums.filter((d) -> !isNaN(d))
    parsedCommand = {'c':command}
    # if nums.length > 1
    parsedCommand['n'] = nums
    parsed.push(parsedCommand)
  parsed

joinPath = (parsed) ->
  path = ""
  parsed.forEach (p) ->
    c = p.c + p.n.join(",")
    path = path.concat(c)
  path

  
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
        t = d3.select(this)
        path = t.attr("d")
        pp = (parse(path))
        t.attr("d", join(pp))
        

        console.log(path)
        console.log(join(pp))
        console.log("---")

      


