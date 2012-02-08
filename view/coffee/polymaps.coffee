# http://stackoverflow.com/questions/4964014/polygons-with-geojson-polymaps
root = exports ? this

$ ->

  w = 600  ##I Playied with this values and the size doesn't change
  h = 460
  [pt, pr, pb, pl] = [10, 10, 10, 10]

  data = null
  vis = null
  municipios = null

  po = org.polymaps

  map = po.map()
    .container(d3.select("#map").append("svg").node())
    .center({lat: 6.6646075, lon: -66.26953})
    .zoom(6)
    .add(po.interact())
  
  map.add(po.image()
    .url(po.url("http://{S}tile.cloudmade.com/e0fe56d5444d435489935ee6747e0909/6083/256/{Z}/{X}/{Y}.png")
      .hosts(["a.", "b.", "c.", ""])))

  color_range = d3.scale.linear().range([3, 7])

  projection = d3.geo.albers().scale(2000).origin([-61,6.7])
  path = d3.geo.path().projection(projection)

  candidates_for = (municipio) ->
    m_data = municipio_candidatos[municipio.properties["MUNICIPIO"].toUpperCase()]

    if !m_data
      console.log(municipio.properties["MUNICIPIO"])
    m_data
  
  parse_candidatos = (csv) ->
    csv.forEach (d) ->
      candidato = {name: d["Candidato"], parties: [d["Partido"]]}
      municipio = municipio_candidatos[d["Municipio"]]
      if municipio
        municipio.candidatos.push candidato
      else
        municipio = {estado: d["Estado"], municipio: d["Municipio"], candidatos:[candidato]}
      municipio_candidatos[d["Municipio"]] = municipio

  quantize = (municipio) ->
    muni_datos = data[municipio.properties["MUNICIPIO"]]
    if(muni_datos)
     # css_class = "q" + Math.round(color_range(muni_datos.nro_candidatos)) + "-9"
       css_class = "q" + Math.round(color_range(muni_datos.nro_candidatos)) + "-9"
    else
      # console.log(municipio.properties["MUNICIPIO"])
      css_class = "missing_data"
    css_class

  feature_options_for = (feature) ->
    {"stroke":true, "color":"#fff", "weight":2, "fill":true, "fillColor":"#444"}

  make_municipios = (json) ->
    console.log("municipio")
    municipios_layer = map.add(po.geoJson().features(json))

  make_estados = (json) ->
    d = 3

  datos_correctos = (csv) ->
    corr_datos = {}
   # electores_range = d3.extent(csv, (d) -> parseInt(d.nro_candidatos))
    electores_range = d3.extent(csv, (d) -> d.nro_candidatos)
    color_range.domain(electores_range)

    csv.forEach (d) ->
      d.municipio = d.municipio.replace(/MP\.\s/,"")
      d.municipio = d.municipio.replace(/MP\./,"")
      d.municipio = d.municipio.replace(/MC\.\s/,"")
      ##I added this before change the original csv file
      ##added to wipe the CE. prefix
      d.municipio = d.municipio.replace(/CE\.\s/,"")

      d.municipio = d.municipio.toUpperCase()
      corr_datos[d.municipio] = d
    corr_datos

  make_vis = (csv) ->
    data = datos_correctos(csv)
    d3.json "data/municipios.json", make_municipios

  show_details = () ->
    console.log(this)

    candidate_data = candidates_for(municipio)
    detail = d3.select("#details")
    detail.classed("deactive", false)

    detail.html "<h3 id=\"detail-municipio\"></h3>"
    detail.select("#detail-municipio")
      .text(candidate_data.municipio)

    cands = detail.selectAll(".candidate")
      .data(candidate_data.candidates)

    cand_div = cands.enter().append("div")
      .attr("class", "candidate")

    cand_div.append("h3")
      .text((d) -> d.name)
    cand_div.append("p")
      .attr("class", "detail-parties")
      .text((d) -> d.parties.join(", "))

    cands.exit().remove()

  hide_details = (municipio, index) ->
    detail = d3.select("#details")
    detail.classed("deactive", true)
    ddd = 3

  ##If I get it right, once all the functions are in place
  ##then they are passed to the d3 library to make everything happen
  #
  # jim - I think that is the right idea. Here is another way to say it:
  #     - The d3.json function loads the json data into an Array. This process
  #     - happens in the background. When it is finished, it calls make_estados
  #     - passing in the Array as its data.
  #     - Same for municipios.json and electores.csv.  So their callback functions
  #     - Are not executed until the data is loaded and ready.
  # d3.json "data/estados.json", make_estados
  d3.csv "data/electores.csv", make_vis
