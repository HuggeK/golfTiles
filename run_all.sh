#!/bin/bash
set -euo pipefail # If any command returns non-zero, the script immediately exits 
shopt -s nullglob
# Clear everything inside of the data/processed directory to rerun it: 
rm -f data/processed/*.pbf data/processed/*.osm.pbf

# echo "Step X started"
# objects in all files must be sorted by type, ID, and version to be able to use osmium merge.
# TODO add error code and message that files are missing in the data/ folder.
for file in data/*.pbf; do
  echo "Processing: $file"
  osmium sort --output="data/processed/sorted.${file##*/}" --strategy=multipass -v "$file" # uses the multipass strategy, slower but uses less memory.
done

osmium merge data/processed/sorted.*.pbf -o data/processed/merged.osm.pbf

osmium tags-filter -v --output=data/processed/golfcourses.mask.osm.pbf data/processed/merged.osm.pbf wr/leisure=golf_course

osmium extract -O --polygon=data/processed/golfcourses.mask.osm.pbf --strategy=smart -S types=multipolygon,route --set-bounds --output=data/processed/extract.osm.pbf data/processed/merged.osm.pbf # -O is allowing overwrites.
# --Strategy=complete_ways or --Strategy=smart -S types=any

# Renumber the extract so object IDs are dense and sequential (nodes/ways/relations each start at 1).
# This is a prerequisite for tilemaker's --compact node store, and it shrinks the file.
# The index is kept in RAM (no -i): the golf-course extract is a small subset even of a planet dump.
# If you ever renumber IDs consistently across several files, add -i <dir> pointing at an empty directory.
osmium renumber -O --output=data/processed/renumbered.osm.pbf data/processed/extract.osm.pbf

# Execute tilemaker.
# --shard-stores:  Group temporary storage by area. Reduces RAM usage on large files (e.g. whole planet) but runs slower.
# --compact: Use the smaller/faster node store. Only valid because the input above was renumbered with osmium renumber.

#tilemaker --input data/processed/renumbered.osm.pbf --output golfTiles.pmtiles --config custom-tilemaker/config.json --process custom-tilemaker/process.lua --store store/ --verbose --shard-stores --compact # TODO is to fix stores.
tilemaker --input data/processed/renumbered.osm.pbf --output golfTiles.pmtiles --config custom-tilemaker/config.json --process custom-tilemaker/process.lua --shard-stores --compact # add --verbose to debug proccesss.lua.
# You can feed tilemaker with multiple .pbf files - maybe split it up for whole world? 