
root = exports ? this

$ ->

  w = 600
  h = 480
  [pt, pr, pb, pl] = [10, 10, 10, 10]

  electores = null
  vis = null
  municipio_candidatos = {}

  start_color = d3.rgb(189,222,255)
  end_color = d3.rgb(8, 48, 107)

  color_range = d3.scale.linear().range([start_color, end_color])

  ##Is clear that this define the projection, scale and origen of the map
  ##Albers is the official projection for USA
  ##But for Venezuela is UTM Datum WGS-84
  ##Looking at d3.geo.js I can see that there is a mercator function
  ##But when I change albers for mercator the map disappears
  #
  # jim - Well, I don't think there is an 'official' projection for USA
  #     - though d3 does have an albersUSA project that has defaults
  #     - setup to work well for the USA.
  #     - Here is a link that helps explain projections a bit:
  #     - http://macwright.org/2012/01/27/projections-understanding.html
  #     -
  #     - Though I am no expert. I found this scale and origin through
  #     - trial and error.
  #     - First I scaled very far out. Then I moved origin and scale back in.
  #     - Checking each time that I didn't move the map off screen.
  #     - I don't  have a better way to find the right scale / origin for
  #     - another projection (like mercator).
  projection = d3.geo.albers().scale(2000).origin([-61,6.7])
  scale = projection.scale()
  t = projection.translate()
  path = d3.geo.path().projection(projection)

  key_for_geojson = (municipio) ->
    "#{municipio.properties["ESTADO"].toUpperCase()}#{municipio.properties["CODIGO"]}"

  key_for_csv = (municipio) ->
    "#{municipio["estado"].toUpperCase()}#{municipio["codigo_municipio"]}"

  candidates_for = (municipio) ->
    key = key_for_geojson(municipio)
    m_data = municipio_candidatos[key]

    if !m_data
      m_data = {estado: municipio.properties["ESTADO"], municipio: municipio.properties["MUNICIPIO"], candidatos: [{name:"No se realizarán primarias", parties:[]}]}
    m_data
  
  parse_candidatos = (csv) ->
    csv.forEach (d) ->
      candidato = {name: d["candidato"], parties: [d["partido"]]}
      municipio_key = "#{d["estado"]}#{d["codigo_municipio"]}"
      municipio_key = key_for_csv(d)
      municipio = municipio_candidatos[municipio_key]
      if municipio
        municipio.candidatos.push candidato
      else
        municipio = {estado: d["estado"], municipio: d["municipio"], candidatos:[candidato]}
      municipio_candidatos[municipio_key] = municipio
        

  municipio_fill = (municipio) ->
    muni_datos = electores[key_for_geojson(municipio)]
    color = "#ddd"
    if(muni_datos)
      num_candidatos = parseInt(muni_datos.nro_candidatos)
      if num_candidatos > 0
        color = color_range(num_candidatos)
    else
      color = red
    color

  vis = d3.select("#vis")
    .append("svg")
    .attr("id", "vis-svg")
    .attr("width", w + (pl + pr))
    .attr("height", h + (pt + pb))

  ## I changed the order of the appends so that I can see the states
  ## I now know that the appen makes a stak of objects
  municipios = vis.append('g')
    .attr("id", "municipios")
    .attr("class", "Blues")

  estados = vis.append('g')
    .attr("id", "estados")

  make_municipios = (json) ->
    municipios.selectAll("path")
      .data(json.features)
    .enter().append("path")
      .attr("fill", if electores then municipio_fill else "#ddd")
      .attr("d", path)
      .on("mouseover", show_details)
      .on("mouseout", hide_details)
      .call(d3.behavior.zoom().on("zoom", redraw))

  make_estados = (json) ->
    estados.selectAll("path")
      .data(json.features)
    .enter().append("path")
      .attr("d", path)

  datos_correctos = (csv) ->
    corr_datos = {}

    ## As I changed the data to be represented (the nro._candidatos for electores)
    ## I think is not necesary to use parseInt because nro candidates are already integers
    #
    #  jim - sounds good. I was just doing that to make sure it worked
   # electores_range = d3.extent(csv, (d) -> parseInt(d.nro_candidatos))
    candidatos_max = d3.max(csv, (d) -> parseInt(d.nro_candidatos))
    color_range.domain([2,candidatos_max])

    ##FANTASTIC WORKAROUND for the annoying Municipio prefix.
    ##But I remove them form the csv file. I think it is better that way
    #
    # jim - I agree- this was just a quick hack to get something to display
    #     - A better solution, as you say, is to clean up the csv and municipios json
    #     - file so the names match. Or you can create a unique integer ID for each municipio
    #     - and use that in the csv.
    csv.forEach (d) ->
      d.municipio = d.municipio.replace(/MP\.\s/,"")
      d.municipio = d.municipio.replace(/MP\./,"")
      d.municipio = d.municipio.replace(/MC\.\s/,"")
      ##I added this before change the original csv file
      ##added to wipe the CE. prefix
      d.municipio = d.municipio.replace(/CE\.\s/,"")

      d.municipio = d.municipio.toUpperCase()
      corr_datos[key_for_csv(d)] = d
    corr_datos

  make_vis = (csv) ->
    # jim - First we set the data global variable - so
    #     - the quantize function will have it to work with
    #     - Then we select all the paths inside municipios and
    #     - give them a class value based on the quantize function
    #     - defined above. This is what makes the colors work. Again
    #     - class is just a CSS class. So when it is set here, it will
    #     - match a value in css/colorbrewer.css - and use that color
    #     - defined for the css class.
    #
    #     - As a side note, because the data loading happens asyncryously, it
    #     - is possible that the .csv data to be loaded before the .json data.
    #     - this is why we also call quantize in make_municipios IF the electores is set
    electores = datos_correctos(csv)
    municipios.selectAll("path")
      .attr("fill", municipio_fill)

  show_details = (municipio, index) ->
    candidate_data = candidates_for(municipio)
    return unless candidate_data

    detail = d3.select("#details")
    detail.classed("deactive", false)

    detail.html "<h2 id=\"detail-estado\"></h2><h2 id=\"detail-municipio\"></h2>"
    detail.select("#detail-estado")
      .text(candidate_data.estado)
    detail.select("#detail-municipio")
      .text(candidate_data.municipio)

    cands = detail.selectAll(".candidato")
      .data(candidate_data.candidatos)

    cand_div = cands.enter().append("div")
      .attr("class", "candidato")

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

  redraw = () ->
    tx = t[0] * d3.event.scale + d3.event.translate[0]
    ty = t[1] * d3.event.scale + d3.event.translate[1]
    projection.translate([tx, ty])

    projection.scale(scale * d3.event.scale)

    municipios.selectAll("path").attr("d", path)
    estados.selectAll("path").attr("d", path)

  ##If I get it right, once all the functions are in place
  ##then they are passed to the d3 library to make everything happen
  #
  # jim - I think that is the right idea. Here is another way to say it:
  #     - The d3.json function loads the json data into an Array. This process
  #     - happens in the background. When it is finished, it calls make_estados
  #     - passing in the Array as its data.
  #     - Same for municipios.json and electores.csv.  So their callback functions
  #     - Are not executed until the data is loaded and ready.
  d3.csv "data/candidatos.csv", parse_candidatos
  d3.json "data/estados.json", make_estados
  d3.json "data/municipios.json", make_municipios
  d3.csv "data/electores.csv", make_vis
