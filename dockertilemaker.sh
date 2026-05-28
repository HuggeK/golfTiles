docker run -it --rm --pull always -v $(pwd):/data \
  ghcr.io/systemed/tilemaker:master \
  /data/leisuregolfcoursesobjects.sweden.osm.pbf \
  --output data/golfsweden.pmtiles