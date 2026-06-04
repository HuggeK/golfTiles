Take more care in placing the stuff into new layers of the schema to be able to render them in the right order.

Make a script to import the source and layers from one of OpenFreeMap and set that as a "backgrounds/base" layer on init.

Download some OpenMapTiles pmtiles tiles for the "basemap" - Not tax OpenFreeMaps resources, donate to it. 


Document how to set up maputnik locally to improve the style. 


Insert the positron style pmtiles in a golfTileStyle+

Give credit for the respectice licenses for openfreemaps etc and other tools used. 



add a store for the tilemaker for the big europe-run. 

TODO:
Write all ways which have wrong values in them into some file which I can upload if
someone wants to consume and fix it, to get the data out of this project to fix the data

Increase the maxium zoom?

TODO maybe clip the pbf file again to get rid of these wast areas which strecthes outside of the course boundary? Or use a better strategy.

TODO is to explain all the chosen configurations in a .md file.

Increase zoom-level past 14 - increase resolution now when used with more decimal places for koordinates. 


Write metadata to 

Optionaly include "include_ids": true, to reduce tile size?


sort the id´s from osmium and use the option in tilemaker to reduce memory usage.

Add shrubs etc?

Add Wheelchair access info as generic attributes for all nodes and or ways and polygons.


TODO document the architect tag for a whole course and also individual courses on the wiki.


Write code to read the order of holes in a route=golf and assign values to their golf_hole= tag. 
To be able to dicern what info on the hole is for what course - append the name of the course as Namespace: before a particular tag. 


Or maybe Create a new multi line with all the holes for a particular route=golf and put the golf course tag on that?



    },
    "openFreeMap_openmaptiles_source": {
    "type": "vector",
    "url": "https://tiles.openfreemap.org/planet"
    }

Sign up for cloudflare R2 to be able to use maputnik website in the browser to be able to develop the style with CORS.


                        // Our golfTiles style Adds openFreeMaps MVT OpenMapTiles-schema mbtiles and the style:
                        // https://tiles.openfreemap.org/styles/positron style 
                        // To style features which are outside the golf course - fetching the mbtiles where our pmtiles with golf tags does not exist.
                        // Research if mablibre will do the switch gracefully.

                        // our style begins after the positron baselayers have been drawn. 
                        
                        // MAYBE add the positron style behind all my others styles:

So develop the core golfTiles style and then also a "golfTilesStyle + Positron"-style to be used with some .mbtiles source like OpenFreeMap or host your own OpenMapTiles tiles in the OpenMapTiles schema. 




# Regarding the course information:

-- Add the attributes from the relation into their respective tags. 


-- TODO is to document how to map penalty areas with the old water_hazard and lateral_water_hazard with other surface tags to include the surface tag for like vulcanic rock etc.
