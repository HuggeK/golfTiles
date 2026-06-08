Due to the nature of Maplibre GL styles are in .json files which one cannot annotate with comments some explanations of the behavior of the style and schema follows down below: (Note that this will be reworked as a proper documentation on github pages in the future like Shortbread does it.)




Note that ref= from OSM gets renamed to hole_number in the golfTiles schema.
set_AttributeInteger_and_log("hole_number", ref) -- this is one of the few times a rename of the key in the tiles occur. More suitable with hole_number than generic ref.




Only tees which are actual areas is rendered.
The style also have a way to style the borders of tee´s if the key tee= is set to a valid html color. If it is a not valid html color, the border will fallback on the same color as the tee itself. Could also be a #HEX color. If a number is used it will be displayed as text atop the border. This is using the expression syntax in Maplibre GL style spec ["typeof"](https://maplibre.org/maplibre-style-spec/expressions/#typeof).
