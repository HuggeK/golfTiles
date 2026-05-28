docker run -it --rm --pull always -v $(pwd):/data \
  ghcr.io/systemed/tilemaker:master \
  /data/leisuregolfcoursesmart.sweden.osm.pbf \
  --output data/golfsweden.pmtiles