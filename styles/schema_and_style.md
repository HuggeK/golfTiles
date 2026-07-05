Due to the nature of Maplibre GL styles are in .json files which one cannot annotate with comments some explanations of the behavior of the style and schema follows down below: (Note that this will be reworked as a proper documentation on github pages in the future like Shortbread does it.)




Note that ref= from OSM gets renamed to hole_number in the golfTiles schema.
set_AttributeInteger_and_log("hole_number", ref) -- this is one of the few times a rename of the key in the tiles occur. More suitable with hole_number than generic ref.




Only tees which are actual areas is rendered.
The style also have a way to style the borders of tee´s if the key tee= is set to a valid html color. If it is a not valid html color, the border will fallback on the same color as the tee itself. Could also be a #HEX color. If a number is used it will be displayed as text atop the border. This is using the expression syntax in Maplibre GL style spec ["typeof"](https://maplibre.org/maplibre-style-spec/expressions/#typeof).




Font glyphs are self-hosted on GitHub Pages: the style's top-level glyphs property points at
https://huggek.github.io/golfTiles/fonts/{fontstack}/{range}.pbf and every symbol layer uses the
"Open Sans Regular" fontstack. The .pbf glyph ranges live in docs/fonts/ in this repository
(prebuilt ranges from the openmaptiles/fonts project). GitHub Pages serves them with
Access-Control-Allow-Origin: *, so the same glyphs URL also works when the style itself is served
from golftiles.org. Longer term the plan is: golftiles.org is the bucket endpoint for tiles and
style, and the GitHub Pages site is the demo page.




Geometry/attribute placement decisions the style relies on (all from custom-tilemaker/process.lua):
- waterway=* ways are written to the golf_lines layer (not golf_areas). The "Streams and Rivers"
  style layer therefore reads source-layer golf_lines.
- natural=water polygons are written to golf_areas with the attribute water=lake or water=river.
  The "Lakes and rivers" style layer renders both values.
- area:highway=* polygons are written with the attribute key area_highway (colon replaced with an
  underscore, since expressions like ["get", "area:highway"] would read awkwardly and the colon has
  no meaning in the tiles). The "Area:highway" style layer filters on area_highway.
- Hole labels read hole_number (the renamed ref, see above), not ref.
