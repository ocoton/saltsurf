import mapboxgl from 'mapbox-gl';

const fitMapToMarkers = (map, markers) => {
  const bounds = new mapboxgl.LngLatBounds();
  markers.forEach(marker => bounds.extend([ marker.lng, marker.lat ]));
  map.fitBounds(bounds, { padding: 70, maxZoom: 13, duration: 0 });
};

const addMarkersToMap = (map, markers) => {
  markers.forEach((marker) => {
    const popup = new mapboxgl.Popup().setHTML(marker.infoWindow); // add this

    // create a HTML element for each feature
    let el = document.createElement('div');
    el.className = 'marker';
    el.id = `${marker.spotId}`;

    // make a marker for each feature and add to the map

    new mapboxgl.Marker(el)
      .setLngLat([ marker.lng, marker.lat ])
      .setPopup(popup) // add this
      .addTo(map);
  });
};

const initMapbox = () => {
  const mapElement = document.getElementById('map');

  if (mapElement) { // only build a map if there's a div#map to inject into
  mapboxgl.accessToken = mapElement.dataset.mapboxApiKey;
  const map = new mapboxgl.Map({
    container: 'map',
    style: 'mapbox://styles/ocoton/cki8mau8e0shv19s70poya4uo'
  });
  map.on('load', function () {
      map.resize();
  });
  const markers = JSON.parse(mapElement.dataset.markers);
    addMarkersToMap(map, markers);
    fitMapToMarkers(map, markers);
  }

  const cards = document.querySelectorAll('.custom[data-spot-id]');
  cards.forEach((card) => {
    const idSpot = card.dataset.spotId;

    card.addEventListener('mouseover', () => {
      const marker = document.getElementById(`${idSpot}`);
      marker.classList.add("orange-marker");
    });

    card.addEventListener('mouseout', () => {
      const marker = document.getElementById(`${idSpot}`);
      marker.classList.remove("orange-marker");
    });
  });
};

export { initMapbox };
