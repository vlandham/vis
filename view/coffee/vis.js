(function() {
  var root;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  $(function() {
    var candidates_for, color_range, datos_correctos, electores, end_color, estados, h, hide_details, key_for_csv, key_for_geojson, make_estados, make_municipios, make_vis, municipio_candidatos, municipio_fill, municipios, parse_candidatos, path, pb, pl, pr, projection, pt, redraw, scale, show_details, start_color, t, vis, w, _ref;
    w = 600;
    h = 480;
    _ref = [10, 10, 10, 10], pt = _ref[0], pr = _ref[1], pb = _ref[2], pl = _ref[3];
    electores = null;
    vis = null;
    municipio_candidatos = {};
    start_color = d3.rgb(189, 222, 255);
    end_color = d3.rgb(8, 48, 107);
    color_range = d3.scale.linear().range([start_color, end_color]);
    projection = d3.geo.albers().scale(2000).origin([-61, 6.7]);
    scale = projection.scale();
    t = projection.translate();
    path = d3.geo.path().projection(projection);
    key_for_geojson = function(municipio) {
      return "" + (municipio.properties["ESTADO"].toUpperCase()) + municipio.properties["CODIGO"];
    };
    key_for_csv = function(municipio) {
      return "" + (municipio["estado"].toUpperCase()) + municipio["codigo_municipio"];
    };
    candidates_for = function(municipio) {
      var key, m_data;
      key = key_for_geojson(municipio);
      m_data = municipio_candidatos[key];
      if (!m_data) {
        m_data = {
          estado: municipio.properties["ESTADO"],
          municipio: municipio.properties["MUNICIPIO"],
          candidatos: [
            {
              name: "No se realizarán primarias",
              parties: []
            }
          ]
        };
      }
      return m_data;
    };
    parse_candidatos = function(csv) {
      return csv.forEach(function(d) {
        var candidato, municipio, municipio_key;
        candidato = {
          name: d["candidato"],
          parties: [d["partido"]]
        };
        municipio_key = "" + d["estado"] + d["codigo_municipio"];
        municipio_key = key_for_csv(d);
        municipio = municipio_candidatos[municipio_key];
        if (municipio) {
          municipio.candidatos.push(candidato);
        } else {
          municipio = {
            estado: d["estado"],
            municipio: d["municipio"],
            candidatos: [candidato]
          };
        }
        return municipio_candidatos[municipio_key] = municipio;
      });
    };
    municipio_fill = function(municipio) {
      var color, muni_datos, num_candidatos;
      muni_datos = electores[key_for_geojson(municipio)];
      color = "#ddd";
      if (muni_datos) {
        num_candidatos = parseInt(muni_datos.nro_candidatos);
        if (num_candidatos > 0) color = color_range(num_candidatos);
      } else {
        color = red;
      }
      return color;
    };
    vis = d3.select("#vis").append("svg").attr("id", "vis-svg").attr("width", w + (pl + pr)).attr("height", h + (pt + pb));
    municipios = vis.append('g').attr("id", "municipios").attr("class", "Blues");
    estados = vis.append('g').attr("id", "estados");
    make_municipios = function(json) {
      return municipios.selectAll("path").data(json.features).enter().append("path").attr("fill", electores ? municipio_fill : "#ddd").attr("d", path).on("mouseover", show_details).on("mouseout", hide_details).call(d3.behavior.zoom().on("zoom", redraw));
    };
    make_estados = function(json) {
      return estados.selectAll("path").data(json.features).enter().append("path").attr("d", path);
    };
    datos_correctos = function(csv) {
      var candidatos_max, corr_datos;
      corr_datos = {};
      candidatos_max = d3.max(csv, function(d) {
        return parseInt(d.nro_candidatos);
      });
      color_range.domain([2, candidatos_max]);
      csv.forEach(function(d) {
        d.municipio = d.municipio.replace(/MP\.\s/, "");
        d.municipio = d.municipio.replace(/MP\./, "");
        d.municipio = d.municipio.replace(/MC\.\s/, "");
        d.municipio = d.municipio.replace(/CE\.\s/, "");
        d.municipio = d.municipio.toUpperCase();
        return corr_datos[key_for_csv(d)] = d;
      });
      return corr_datos;
    };
    make_vis = function(csv) {
      electores = datos_correctos(csv);
      return municipios.selectAll("path").attr("fill", municipio_fill);
    };
    show_details = function(municipio, index) {
      var cand_div, candidate_data, cands, detail;
      d3.select(this).attr("fill", "rgb(244,246,137)");
      candidate_data = candidates_for(municipio);
      if (!candidate_data) return;
      detail = d3.select("#details");
      detail.classed("deactive", false);
      detail.html("<h2 id=\"detail-estado\"></h2><h2 id=\"detail-municipio\"></h2>");
      detail.select("#detail-estado").text(candidate_data.estado);
      detail.select("#detail-municipio").text(candidate_data.municipio);
      cands = detail.selectAll(".candidato").data(candidate_data.candidatos);
      cand_div = cands.enter().append("div").attr("class", "candidato");
      cand_div.append("h3").text(function(d) {
        return d.name;
      });
      cand_div.append("p").attr("class", "detail-parties").text(function(d) {
        return d.parties.join(", ");
      });
      return cands.exit().remove();
    };
    hide_details = function(municipio, index) {
      var ddd, detail;
      d3.select(this).attr("fill", function(d) {
        return municipio_fill(d);
      });
      detail = d3.select("#details");
      detail.classed("deactive", true);
      return ddd = 3;
    };
    redraw = function() {
      var tx, ty;
      tx = t[0] * d3.event.scale + d3.event.translate[0];
      ty = t[1] * d3.event.scale + d3.event.translate[1];
      projection.translate([tx, ty]);
      projection.scale(scale * d3.event.scale);
      municipios.selectAll("path").attr("d", path);
      return estados.selectAll("path").attr("d", path);
    };
    d3.csv("data/candidatos.csv", parse_candidatos);
    d3.json("data/estados.json", make_estados);
    d3.json("data/municipios.json", make_municipios);
    return d3.csv("data/electores.csv", make_vis);
  });

}).call(this);
