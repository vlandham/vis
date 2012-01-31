
root = exports ? this

$ ->

  w = 940
  h = 600
  [pt, pr, pb, pl] = [10, 10, 10, 10]

  data = null
  vis = null

  color_range = d3.scale.linear().range([3, 8])

  projection = d3.geo.albers().scale(2000).origin([-65,6])
  path = d3.geo.path().projection(projection)

  # quantize is a function. In coffeescript, this is how functions
  # are defined. See: http://coffeescript.org/#literals
  quantize = (municipo) ->
    muni_datos = data[municipo.properties["MUNICIPIO"]]
    if(muni_datos)
      css_class = "q" + Math.round(color_range(muni_datos.total_electores)) + "-9"
    else
      #TODO: NOT getting data for some municipios. need to correct
      #names in csv or add a unique id to geojson
      console.log(municipo.properties["MUNICIPIO"])
      css_class = "q" + 1 + "-9"
    css_class

  vis = d3.select("#vis")
    .append("svg")
    .attr("id", "vis-svg")
    .attr("width", w + (pl + pr))
    .attr("height", h + (pt + pb))

  estados = vis.append('g')
    .attr("id", "estados")

  municipios = vis.append('g')
    .attr("id", "municipios")
    .attr("class", "Blues")

  make_estados = (json) ->
    estados.selectAll("path")
      .data(json.features)
    .enter().append("path")
      .attr("d", path)

  make_municipios = (json) ->
    municipios.selectAll("path")
      .data(json.features)
    .enter().append("path")
      .attr("class", if data then quantize else null)
      .attr("d", path)

  datos_correctos = (csv) ->
    corr_datos = {}
    electores_range = d3.extent(csv, (d) -> parseInt(d.total_electores))
    color_range.domain(electores_range)

    csv.forEach (d) ->
      d.municipio = d.municipio.replace(/MP\.\s/,"")
      d.municipio = d.municipio.replace(/MP\./,"")
      d.municipio = d.municipio.replace(/MC\.\s/,"")
      d.municipio = d.municipio.toUpperCase()
      corr_datos[d.municipio] = d
    corr_datos

  make_vis = (csv) ->
    data = datos_correctos(csv)
    municipios.selectAll("path")
      .attr("class", quantize)

  d3.json "data/estados.json", make_estados
  d3.json "data/municipios.json", make_municipios
  d3.csv "data/electores.csv", make_vis
