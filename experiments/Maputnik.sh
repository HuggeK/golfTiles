docker run -it --rm -p 8888:8000 -v "$(pwd)/style:/style" ghcr.io/maplibre/maputnik:main --file /style/golfTilesStyle.json --watch


golfTiles_pmtiles_source_local
http://localhost:8080/golfTiles_complete_ways_sweden.pmtiles