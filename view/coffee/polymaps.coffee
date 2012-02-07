# http://stackoverflow.com/questions/4964014/polygons-with-geojson-polymaps
root = exports ? this

$ ->

  w = 600  ##I Playied with this values and the size doesn't change
  h = 460
  [pt, pr, pb, pl] = [10, 10, 10, 10]

  data = null
  vis = null
  municipios = null

  map = new L.Map('map')

  cloudmadeUrl = 'http://{s}.tile.cloudmade.com/e0fe56d5444d435489935ee6747e0909/997/256/{z}/{x}/{y}.png'
  cloudmadeAttrib = 'Map data &copy; 2011 OpenStreetMap contributors, Imagery &copy; 2011 CloudMade'
  cloudmade = new L.TileLayer(cloudmadeUrl, {maxZoom: 18, attribution: cloudmadeAttrib})

  start = new L.LatLng(6.6646075, -66.26953)
  map.setView(start, 6).addLayer(cloudmade)

  color_range = d3.scale.linear().range([3, 7])

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
  path = d3.geo.path().projection(projection)


  # TODO: use actual candidates data. Right now this just generates fake data with 
  # little differences for each municipio
  candidates_for = (municipio) ->
    candidate_data = {estado: "EstadoName", municipio: municipio.properties["MUNICIPIO"], candidates: [{ name: "First Candidate", parties: ["party1", "party2"] },
                      { name: "Second Candidate #{municipio.properties["CODIGO"]}", parties: ["party1", "party3", "party4"]}]}
    candidate_data

  # quantize is a function. In coffeescript, this is how functions
  # are defined. See: http://coffeescript.org/#literals
  #
  # jim - This is the function that makes the coloration of the municipios work
  #     - It attempts to get the electores.csv data for a particular municipio.
  #     - If the data is found, it uses the nro_candidatos value to specify a
  #     - color value. The color_range function scales the possible nro_candidatos
  #     - to a value between the 'range' of color_range (currently set to be between
  #     - 3 and 8). This is rounded to an integer and then turned into a string
  #     - like "q6-9".
  #     - This string is really just the name of a css class defined in css/colorbrewer.css
  #     - That is where the actual colors are defined. This function just returns a class
  #     - name which will be applied to the municipio polygon
  #
  #     - It gets called when we load up the csv data. in make_vis
  quantize = (municipio) ->
    muni_datos = data[municipio.properties["MUNICIPIO"]]
    if(muni_datos)
     # css_class = "q" + Math.round(color_range(muni_datos.nro_candidatos)) + "-9"
       css_class = "q" + Math.round(color_range(muni_datos.nro_candidatos)) + "-9"
    else
      #TODO: NOT getting data for some municipios. need to correct
      #names in csv or add a unique id to geojson

      ##Yes I will do that. In fact the id of the municipios/estados
      ##Does not match at all. I think I will spend the next few days correcting that

      console.log(municipio.properties["MUNICIPIO"])
      css_class = "missing_data"
    css_class

  # vis = d3.select("#vis")
  #   .append("svg")
  #   .attr("id", "vis-svg")
  #   .attr("width", w + (pl + pr))  #
  #   .attr("height", h + (pt + pb))

   
  ## I changed the order of the appends so that I can see the states
  ## I now know that the appen makes a stak of objects
  # municipios = d3.select("#vis-svg").insert('g', '.compass')
  #   .attr("id", "municipios")
  #   .attr("class", "Blues")

  # estados = d3.select("#vis-svg").insert('g', '.compass')
  #   .attr("id", "estados")
  #
  feature_options_for = (feature) ->
    {"stroke":true, "color":"#fff", "weight":2, "fill":true, "fillColor":"#444"}

  make_municipios = (json) ->
    municipios_layer = new L.GeoJSON()

    municipios_layer.on 'featureparse', (e) ->
      if e.layer.setStyle
        e.layer.setStyle(feature_options_for(e))
      e.layer.addEventListener("click", show_details)

    municipios_layer.addGeoJSON(json)
    map.addLayer(municipios_layer)

    # municipios.selectAll("path")
    #   .data(json.features)
    # .enter().append("path")
    #   .attr("class", if data then quantize else null)
    #   .attr("d", path)
    #   .attr("transform", transform)
    #   .on("mouseover", show_details)
    #   .on("mouseout", hide_details)

  make_estados = (json) ->
    # estados.selectAll("path")
    #   .data(json.features)
    # .enter().append("path")
    #   .attr("d", path)

  datos_correctos = (csv) ->
    corr_datos = {}

    ## As I changed the data to be represented (the nro._candidatos for electores)
    ## I think is not necesary to use parseInt because nro candidates are already integers
    #
    #  jim - sounds good. I was just doing that to make sure it worked
   # electores_range = d3.extent(csv, (d) -> parseInt(d.nro_candidatos))
    electores_range = d3.extent(csv, (d) -> d.nro_candidatos)
    color_range.domain(electores_range)

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
      corr_datos[d.municipio] = d
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
    #     - this is why we also call quantize in make_municipios IF the
    #     - variable 'data' is set.
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
