
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

randomIntFromInterval = (min,max) ->
  Math.floor(Math.random()*(max-min+1)+min)

jackPath = (parsed, mult) ->
  jacked = []
  parsed.forEach (section) ->
    jackedSection = []
    section.forEach (s, i) ->
      if i > 0
        jackedSection.push(s + (randomIntFromInterval(0,1) * mult))
      else
        jackedSection.push(s)
    jacked.push(jackedSection)
  jacked

  
$ ->
  d3.xml 'data/bike.svg', 'image/svg+xml', (error, data) ->
    console.log(error)
    nodes = [1..200]

    svg = data.documentElement

    d3.select("#vis")
      .selectAll(".node")
      .data(nodes).enter()
      .append("div")
      .attr("class", "node")
      .each((d) -> this.appendChild(svg.cloneNode(true)))
      .selectAll("path")
      .attr("fill", "steelblue")
      .each (d,i) ->
        t = d3.select(this)
        path = t.attr("d")
        mod = if (i % 10) < 5 then -2 else 2
        console.log(i)
        pp = jackPath(parse(path), mod)
        t.attr("d", join(pp))
        


