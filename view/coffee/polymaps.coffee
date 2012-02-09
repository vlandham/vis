# http://stackoverflow.com/questions/4964014/polygons-with-geojson-polymaps
root = exports ? this

$ ->

  w = 600  ##I Playied with this values and the size doesn't change
  h = 460
  [pt, pr, pb, pl] = [10, 10, 10, 10]

  color_range = d3.scale.linear().range([3, 7])

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

  make_municipios = (e) ->
    municipios = d3.select("#municipios")
    municipios.attr("class", "Blues")
    console.log(municipios)
    console.log(e)

  municipios_load = (e) ->
    if !municipios
      make_municipios(e)

  map.add(po.compass()
    .pan("none"))


  quantize = (municipio) ->
    muni_datos = data[municipio.properties["MUNICIPIO"]]
    if(muni_datos)
       css_class = "q" + Math.round(color_range(muni_datos.nro_candidatos)) + "-9"
    else
      css_class = "missing_data"
    css_class

  datos_correctos = (csv) ->
    corr_datos = {}
   # electores_range = d3.extent(csv, (d) -> parseInt(d.nro_candidatos))
    electores_range = d3.extent(csv, (d) -> d.nro_candidatos)
    color_range.domain(electores_range)

    csv.forEach (d) ->
      d.municipio = d.municipio.replace(/MP\.\s/,"")
      d.municipio = d.municipio.replace(/MP\./,"")
      d.municipio = d.municipio.replace(/MC\.\s/,"")
      d.municipio = d.municipio.replace(/CE\.\s/,"")
      d.municipio = d.municipio.toUpperCase()
      corr_datos[d.municipio] = d
    corr_datos

  make_vis = (csv) ->
    data = datos_correctos(csv)
    map.add(po.geoJson().url("data/municipios.json").id("municipios").on("load", municipios_load).on("load", po.stylist().attr("class", (d) -> quantize(d))))


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

  d3.csv "data/electores.csv", make_vis
