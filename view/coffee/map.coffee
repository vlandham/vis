
root = exports ? this

$ ->

  w = 600  ##I Playied with this values and the size doesn't change
  h = 460
  [pt, pr, pb, pl] = [10, 10, 10, 10]

  data = null
  municipios = null
  color = d3.scale.category10()


  cloudmadeUrl = 'http://{s}.tile.cloudmade.com/e0fe56d5444d435489935ee6747e0909/6083/256/{z}/{x}/{y}.png'
  cloudmadeAttrib = 'Map data &copy; 2011 OpenStreetMap contributors, Imagery &copy; 2011 CloudMade'
  cloudmade = new L.TileLayer(cloudmadeUrl, {maxZoom: 18, attribution: cloudmadeAttrib})

  map = new L.Map('map')

  start = new L.LatLng(6.6646075, -66.26953)
  map.setView(start, 6).addLayer(cloudmade)


  # TODO: use actual candidates data. Right now this just generates fake data with 
  # little differences for each municipio
  candidates_for = (municipio) ->
    candidate_data = {estado: "EstadoName", municipio: municipio.properties["MUNICIPIO"], candidates: [{ name: "First Candidate", parties: ["party1", "party2"] },
                      { name: "Second Candidate #{municipio.properties["CODIGO"]}", parties: ["party1", "party3", "party4"]}]}
    candidate_data


  feature_options_for = (feature) ->
    muni_data = data[feature.properties["MUNICIPIO"]]
    {"stroke":true, "color":"#fff", "weight":2, "fill":true, "fillColor":color(muni_data.nro_candidatos)}

  make_municipios = (json) ->
    municipios_layer = new L.GeoJSON()

    municipios_layer.on 'featureparse', (e) ->
      if e.layer.setStyle
        e.layer.setStyle(feature_options_for(e))
      e.layer.featureProperties = e.properties
      e.layer.municipio = e.properties["MUNICIPIO"]
      # e.layer.addEventListener("click", show_details)

    municipios_layer.addGeoJSON(json)
    map.addLayer(municipios_layer)


  make_estados = (json) ->
    # estados.selectAll("path")
    #   .data(json.features)
    # .enter().append("path")
    #   .attr("d", path)

  datos_correctos = (csv) ->
    corr_datos = {}
    electores_range = d3.extent(csv, (d) -> d.nro_candidatos)

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

  show_details = (data) ->
    console.log(data)
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
