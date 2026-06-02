#!/bin/bash
set -euo pipefail # If any command returns non-zero, the script immediately exits 
shopt -s nullglob
# Clear everything inside of the data/processed directory to rerun it: 
rm -f data/processed/*.pbf data/processed/*.osm.pbf

# echo "Step X started"
# objects in all files must be sorted by type, ID, and version to be able to use osmium merge.
for file in data/*.pbf; do
  echo "Processing: $file"
  osmium sort --output="data/processed/sorted.${file##*/}" --strategy=multipass -v "$file" # uses the multipass strategy, slower but uses less memory.
done

osmium merge data/processed/sorted.*.pbf -o data/processed/merged.osm.pbf


osmium tags-filter -v --output=data/processed/golfcourses.mask.osm.pbf data/processed/merged.osm.pbf wr/leisure=golf_course

osmium extract -v -O --polygon=data/processed/golfcourses.mask.osm.pbf --strategy=smart -S types=any --set-bounds --output=data/processed/extract.osm.pbf data/processed/merged.osm.pbf # -O is allowing overwrites.


# Maybe run osmium renumber here to be able to run tilemaker with --compact. 

# Execute tilemaker. 
# --shard-stores:  Group temporary storage by area. Reduces RAM usage on large files (e.g. whole planet) but runs slower.
# maybe use --compact?

tilemaker --input data/processed/extract.osm.pbf --output golfTiles.pmtiles --config custom-tilemaker/config.json --process custom-tilemaker/process.lua --store store/ --verbose --shard-stores
