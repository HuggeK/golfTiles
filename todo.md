add a store for the tilemaker for the big europe-run. 

After development is done, maybe remove the "include_ids": true, to reduce tile size?

Document the tile schema just like shortbread does it, via some github pages to publish it.

sort the id´s from osmium and use the option in tilmaker to reduce memory usage.


Add shrubs etc?


# Regarding the course information:
-- Add the route=golf type=route relations for the golf courses, as documented in: https://wiki.openstreetmap.org/wiki/Tag:route%3Dgolf

-- TODO write this that it could both be mapped as per hole with name and also as a route=golf and still output the same type as navigatable vector tiles?
-- This navigation logic is maybe better handled by these app as a separate overpass instance to query the relationships? 
-- But the good things about having it in the tiles is that we can style and animate on it?

-- TODO plan: Embedd the course route=golf relation id on the applicable golf=holes. and the relations
-- OR add it ass attributes (= vector tile metadata/tags)

-- MAYBE verify ref= order here in this code as sanity check? Or maybe not


-- TODO is to document how to map penalty areas with the old water_hazard and lateral_water_hazard with other surface tags to include the surface tag for like vulcanic rock etc.



