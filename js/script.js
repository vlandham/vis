// Bind the geocoder functionality to any div with the format
//
//     <div data-control='geocode' id="search">
//        <form class="geocode">
//          <input placeholder='Search for an address' type="text">
//          <input type='submit' />
//          <div id='geocode-error'></div>
//        </form>
//      </div>
//
function bindGeocoderOld() {
  $('[data-control="geocode"] form').submit(function(e) {
    var m = $('[data-control="geocode"]').attr('data-map');
    // If this doesn't explicitly name the layer it should affect,
    // use the first layer in MB.maps
    e.preventDefault();
    geocode($('input[type=text]', this).val(), m);
  });
  var geocode = function(query, m) {
    query = encodeURIComponent(query);
    $('form.geocode').addClass('loading');
    reqwest({
      url: 'http://open.mapquestapi.com/nominatim/v1/search?format=json&&limit=1&q=' + query,
      type: 'jsonp',
      jsonpCallback: 'json_callback',
      success: function (r) {
        r = r[0];

        if (MM_map.geocodeLayer) {
          MM_map.geocodeLayer.removeAllMarkers();
        }

        $('form.geocode').removeClass('loading');

        if (r === undefined) {
          $('#geocode-error').text('This address cannot be found.').fadeIn('fast');
        } else {
          $('#geocode-error').hide();
          MM_map.setExtent([
            { lat: r.boundingbox[1], lon: r.boundingbox[2] },
            { lat: r.boundingbox[0], lon: r.boundingbox[3] }
            ]);

          if (MM_map.getZoom() === MM_map.coordLimits[1].zoom) {
            var point = { 'type': 'FeatureCollection',
              'features': [{ 'type': 'Feature',
                'geometry': { 'type': 'Point','coordinates': [r.lon, r.lat] },
                'properties': {}
              }]};

            setCenterOffset(MM_map, { lat: r.lat, lon: r.lon });
          }
        }
      }
    });
  };
}
























