--[[

	TODO write more about it here:

	The attribute "kind" refers to the "main" attribute as of golfTiles standard.

	A simple example tilemaker configuration, intended to illustrate how it
	works and to act as a starting point for your own configurations.

	The basic principle is:
	- read OSM tags with Find(key)
	- write to vector tile layers with Layer(layer_name)
	- add attributes with Attribute(field, value)

]]--


-- Add the route=golf type=route relations for the golf courses, as documented in: https://wiki.openstreetmap.org/wiki/Tag:route%3Dgolf

-- TODO write this that it could both be mapped as per hole with name and also as a route=golf and still output the same type as navigatable vector tiles?
-- This navigation logic is maybe better handled by these app as a separate overpass instance to query the relationships? 
-- But the good things about having it in the tiles is that we can style and animate on it?

-- TODO plan: Embedd the course route=golf relation id on the applicable golf=holes. and the relations
-- OR add it ass attributes (= vector tile metadata/tags)

function relation_scan_function()
  if Find("type")=="route" and Find("route")=="golf" then
		Accept() 
  end
end



-- MAYBE verify ref= order here in this code as sanity check? Or maybe not.


-- FROM TEMPLATE Nodes will only be processed if one of these keys is present
-- This reduces momory drasticly.
node_keys = { "golf", "man_made", "shop", "amenity", "natural", "tourism", "information"} 


-- Assign nodes to a layer, and set attributes, based on OSM tags
function node_function(node)
	-- TODO rewrite this logic, its only one node per function call. 
	-- so if a particular node have been checked - do not check anything else - or does it auto-return?


	-- Points to go to a "golf" layer
	-- Features on the course itself.
	local golf = Find("golf")
	if golf~="" then
		Layer("golf")
		Attribute("kind", find("golf")) -- the attribute kind refers to the "main" attribute.
	end
	local natural = Find("natural") -- mainly for natural=tree
	if natural~="" then
		Layer("golf")
		Attribute("kind", find("natural")) 
	end
	local information = Find("information") -- Mainly for information=guideposts and other signs on the course.
	if information~="" then --TODO is add the descriptions and the destinations for these signs.
		Layer("golf")
		Attribute("kind", find("information")) 
	end
	local amenity = Find("amenity") -- Mainly for amenity=bench
	if amenity~="" then 
		Layer("golf")
		Attribute("kind", find("information")) 
	end
	local amenity = Find("amenity") -- Mainly for amenity=bench
	if amenity~="" then 
		Layer("golf")
		Attribute("kind", find("information")) 
	end


	-- Points go to a "other" layer
	-- Features which can be all around the course but is not only found on the course itself.

	local man_made= Find("man_made") -- Mainly for man_made=water_tap 
	if man_made~="" then
		Layer("other")
		if amenity~="" then Attribute("kind",amenity)
		else Attribute("class",shop) end
		Attribute("name:latin", Find("name"))
		AttributeInteger("rank", 3)
	end

	-- add golf shops, the shop at the Masters etc.

end


-- Assign ways to a layer, and set attributes, based on OSM tags

function way_function()
	local highway  = Find("highway")
	local waterway = Find("waterway")
	local building = Find("building")

--[[ 	-- cover natural:sand and surface=sand also for waste areas and trees etc.
	local natural = Find("natural")
	if natural~="" then
		Layer("golf")
		Attribute("kind", find("natural"))
	
	end  ]]



	-- Roads
	if highway~="" then
		Layer("transportation", false)
		if highway=="unclassified" or highway=="residential" then highway="minor" end
		Attribute("class", highway)
		-- ...and road names
		local name = Find("name")
		if name~="" then
			Layer("transportation_name", false)
			Attribute("class", highway)
			Attribute("name:latin", name)
		end
	end

	-- Rivers
	if waterway=="stream" or waterway=="river" or waterway=="canal" then
		Layer("waterway", false)
		Attribute("class", waterway)
		AttributeInteger("intermittent", 0)
	end

	-- Lakes and other water polygons
	if Find("natural")=="water" then
		Layer("water", true)
		if Find("water")=="river" then
			Attribute("class", "river")
		else
			Attribute("class", "lake")
		end
	end
	-- Buildings
	if building~="" then
		Layer("building", true)
	end
end