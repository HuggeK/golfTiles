--[[

	These tiles contain attributes which mirrors their actual OSM tags(key=value pairs).

	The basic principle is:
	- read OSM tags with Find(key)
	- write to vector tile layers with Layer(layer_name)
	- add attributes with Attribute(field, value)

]]--

function relation_scan_function()
  if Find("type")=="route" and Find("route")=="golf" then
		Accept() 
  end
end


-- FROM TEMPLATE Nodes will only be processed if one of these keys is present
-- This reduces momory drasticly.
node_keys = { "golf", "man_made", "shop", "amenity", "vending", "natural", "tourism", "information", "leaf_cycle", "leaf_type" } 
-- Does using this strip all other keys too? Like is leaf_cycle needed and so on? Is the name key needed for example? 

-- Assign nodes to a layer, and set attributes, based on OSM tags
function node_function(node)
	-- TODO rewrite this logic, its only one node per function call. 
	-- so if a particular node have been checked - do not check anything else - or does it auto-return?

	-- Points to go to a "golf" layer
	-- Features on the course itself.
	local golf = Find("golf")
	if golf~="" then
		Layer("golf") -- This is what actually puts it in the tile. Remember: First layer and then attributes.
		Attribute("golf", find("golf")) -- key=value pairs.
	end
	local natural = Find("natural") -- mainly for natural=tree
	if natural~="" then
		Layer("golf")
		Attribute("golf", find("natural")) 
		-- Adds tree information:
		if  find("natural")=="tree" then
			if Find(key) == "leaf_cycle" then
				Attribute("leaf_cycle", Find("leaf_cycle"))
			end
			if Find(key) == "leaf_type" then
				Attribute("leaf_type", Find("leaf_type"))
			end
	end
	local information = Find("information") -- Mainly for information=guideposts and other signs on the course.
	if information~="" then --TODO is add the descriptions and the destinations for these signs.
		Layer("golf")
		Attribute("information", find("information")) 
	end
	local amenity = Find("amenity") -- Mainly for amenity=bench
	if amenity~="" then  -- All amenity-tags.
		Layer("golf")
		Attribute("amenity", find("amenity")) 
	-- amenity=vending_machine logic, vending=golf_balls added.
	if amenity=="vending_machine" then
		if find("vending")~="" then
			Attribute("vending", find("vending"))
		end
	end

	-- Points go to a "other" layer
	-- Features which can be all around the course but is not only found on the course itself.

	local man_made= Find("man_made") -- Mainly for man_made=water_tap 
	if man_made~="" then
		Layer("other")
		Attribute("man_made", find("man_made")) 
	end

	-- add golf shops, the shop at the Masters etc.
	-- TODO add more info here if it exist, opening hours contact details etc.
	-- could AllTags() be used to apply them all?
	local shop = Find("shop") 
	if shop~="" then
		Layer("other")
		Attribute("shop", Find("shop"))
		Attribute("name", Find("name"))
	end
end

-- list of possible keys or key-value pairs to speed up/use less memory:
way_keys = {"leisure", "name", "golf", "natural", "surface", "highway", "waterway", "building", "landuse" } 

-- Assign ways to a layer, and set attributes, based on OSM tags:

function way_function()

	-- Ways and areas to go to a "golf" layer:

	-- The main facility:
	local leisure = Find("leisure")
	if leisure == "golf_course" then
		Layer("golf", true) -- Second parameter denotes true - it is an area, not a way.
		Attribute("leisure", Find("golf_course"))
	end 



	-- Filter out ways to false and areas as true based upon tags?
	-- OsmType() or IsClosed()?
	local golf = Find("golf")
	if golf~="" then

		Attribute("golf", Find("golf"))

		-- TODO 
		Layer("golf", true)
	
	end


	--Landuse:

	local landuse = Find("landuse")

	if landuse~="" then
		Layer("golf", true)
		Attribute("leisure", Find("golf_course"))


	-- Trees/forrests with leaf_type´s:








	-- Buildings
	local building = Find("building")
	if building~="" then
		Layer("building", true)
	end

 
	-- Roads
	-- TODO fix the new 2019 cart path schema to cover it all: https://wiki.openstreetmap.org/wiki/Key:golf_cart
	local highway  = Find("highway")
	if highway~="" then
		Layer("golf", false)
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
	local waterway = Find("waterway")
	if waterway=="stream" or waterway=="river" or waterway=="canal" then
		Layer("golf", false)
		Attribute("class", waterway)
		AttributeInteger("intermittent", 0)
	end

	-- Natural-tags: 
	local natural = Find("natural")
	if natural=="water" then -- Lakes and other water polygons
		Layer("golf", true)
		if Find("water")=="river" then
			Attribute("kind", "river")
		else
			Attribute("kind", "lake")
		end
	elseif natural=="tree_row" then
		Layer("golf", false)
		Attribute("kind", "tree_row")
		if Find(key) == "leaf_cycle" then
			Attribute("leaf_cycle", Find("leaf_cycle"))
		end
		if Find(key) == "leaf_type" then
			Attribute("leaf_type", Find("leaf_type"))
		end

	end

--[[ 	-- cover natural:sand and surface=sand also for waste areas and trees etc.
	local natural = Find("natural")
	if natural~="" then
		Layer("golf")
		Attribute("kind", find("natural"))
	
	end  ]]

-- Ways and areas to go to a "other" layer:



end