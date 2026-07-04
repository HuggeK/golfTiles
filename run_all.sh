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

# Geographic extract limited to the golf_course polygons.
# --strategy=smart makes relations reference-complete, but on its own it reference-completes EVERY
# multipolygon/route relation that merely touches the course boundary (bus/bike/hiking routes, large
# landuse/water multipolygons), dragging all their far-away members into the result. That is the
# "features stretching outside the facility" overshoot reported in issue #32.
# -S tags=... restricts reference-completion to golf-relevant relations only: the smart option semantics
# are "(types OR complete-partial-relations) AND tags", so only relations that are (multipolygon|route)
# AND tagged leisure=golf_course / route=golf / golf=* stay complete. Everything else keeps just the
# members that actually fall inside the polygon. This keeps route=golf (the multi-course schema) intact
# while removing the off-course overshoot.
# See https://docs.osmcode.org/osmium/latest/osmium-extract.html (STRATEGIES -> smart -> -S tags).
osmium extract -O --polygon=data/processed/golfcourses.mask.osm.pbf --strategy=smart -S types=multipolygon,route -S tags=leisure=golf_course,route=golf,golf --set-bounds --output=data/processed/extract.osm.pbf data/processed/merged.osm.pbf # -O is allowing overwrites.

# Make the extract reference-complete.
# osmium's smart strategy can output a relation-member way (e.g. a big landuse=forest multipolygon
# clipped by the course) without copying every node that way references, so the extract ends up NOT
# reference-complete. tilemaker then aborts on the first such way with:
#   "SortedNodeStore: node <id> missing, no node".
# Fix: re-add ONLY the missing nodes (referenced by ways but absent) from the merged source. We fetch
# the bare nodes with `osmium getid` WITHOUT -r/--add-referenced, so no extra ways or relations - and
# therefore no off-course overshoot - are reintroduced; we only complete the geometry of ways that are
# already in the extract. `osmium check-refs -i` (no -r) lists exactly the missing nodes-in-ways.
# check-refs exits non-zero when refs are missing, and grep exits non-zero when there are none, so the
# pipeline is guarded with `|| true` under `set -o pipefail`.
osmium check-refs -i data/processed/extract.osm.pbf 2>/dev/null | grep -oE '^n[0-9]+' | sort -u > data/processed/missing_node_ids.txt || true
if [ -s data/processed/missing_node_ids.txt ]; then
  echo "Completing $(wc -l < data/processed/missing_node_ids.txt | tr -d ' ') missing node reference(s) in the extract."
  osmium getid -O --id-file=data/processed/missing_node_ids.txt --output=data/processed/missing_nodes.osm.pbf data/processed/merged.osm.pbf
  osmium merge -O data/processed/extract.osm.pbf data/processed/missing_nodes.osm.pbf -o data/processed/extract.complete.osm.pbf
else
  echo "Extract is already reference-complete."
  cp data/processed/extract.osm.pbf data/processed/extract.complete.osm.pbf
fi

# Maybe run osmium renumber here to be able to run tilemaker with --compact.

# Execute tilemaker. 
# --shard-stores:  Group temporary storage by area. Reduces RAM usage on large files (e.g. whole planet) but runs slower.
# maybe use --compact?

#tilemaker --input data/processed/extract.complete.osm.pbf --output golfTiles.pmtiles --config custom-tilemaker/config.json --process custom-tilemaker/process.lua --store store/ --verbose --shard-stores # TODO is to fix stores.
tilemaker --input data/processed/extract.complete.osm.pbf --output golfTiles.pmtiles --config custom-tilemaker/config.json --process custom-tilemaker/process.lua --shard-stores # add --verbose to debug proccesss.lua.
# You can feed tilemaker with multiple .pbf files - maybe split it up for whole world? 