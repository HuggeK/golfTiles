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


function get_architect()
	local architect = Find("architect")
	if architect ~="" then
		Attribute("architect", architect)
	end

end 

-- general tags - both applicable on nodes and ways/areas. Shared between node_function() and way_function()
function general_attributes()
	local operator = Find("operator")
	if operator ~="" then
		Attribute("operator", operator)
	end
	local opening_hours = Find("opening_hours")
	if opening_hours ~="" then
		Attribute("opening_hours", opening_hours)
	end

	local wikidata = Find("wikidata")
	if wikidata ~="" then
		Attribute("wikidata", wikidata)
	end

	-- Contact details for the facility, opening hours etc. See "useful combinations" on the wiki page Tag:leisure=golf_course
	local phone = Find("phone")
	if phone~="" then
		Attribute("phone", phone)
	end

	local website = Find("website")
	if website ~="" then
		Attribute("name", name)
	end

	--Adress:
	local addr_postcode = Find("addr:postcode")
	if addr_postcode ~="" then
		Attribute("addr:postcode", addr_postcode)
	end
	local addr_city = Find("addr:city")
	if addr_city ~="" then
		Attribute("addr:city", addr_city)
	end
	local addr_street = Find("addr:street")
	if addr_street ~="" then
		Attribute("addr:street", addr_street)
	end	

	-- Access-restrictions:
	local access = Find("access")
	if access~="" then
		Attribute("access", access)
	end 

end



-- Nodes will only be processed if one of these keys is present. This reduces momory drasticly as stated by the documentation.
node_keys = { "golf", "man_made", "shop", "amenity", "vending", "natural", "tourism", "information", "leaf_cycle", "leaf_type", "leisure" } 
-- Does using this strip all other keys too? Like is leaf_cycle needed and so on? Is the name key needed for example?
-- TODO UPDATE all used keys with the used keys below:

-- Assign nodes to a layer, and set attributes, based on OSM tags
function node_function(node)
	-- TODO rewrite this logic, its only one node per function call no need for too many evalutions.

	-- Points to go to a "golf" layer. Features on the course itself.
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
		Attribute("information", Find("information")) 
	end
	local amenity = Find("amenity") -- Mainly for amenity=bench
	if amenity~="" then  -- All amenity-tags.
		Layer("golf")
		Attribute("amenity", Find("amenity")) 
		-- amenity=vending_machine logic, vending=golf_balls added.
		if amenity=="vending_machine" then
			local vending = Find("vending")
			if vending~="" then
				Attribute("vending", vending)
			end
		end
		if amenity=="toilets" then
			local male = Find("male") 
			if male~="" then
				Attribute("male", male)
			end 
			local female = Find("female")
			if female~="" then
				Attribute("female", female)
			end 
			local unisex = Find("unisex")
			if unisex~="" then 
				Attribute("female", female)
			end 
		end 

	end

	-- toilets key for nodes: 
	local toilets = Find("toilets"):
	if toilets~="" then
		Layer("golf")
		Attribute("toilets", toilets)
	end 

	-- Add AED´s:

	local emergency = Find("emergency"):
	if emergency == "defibrillator":
		Layer("golf")
		Attribute("emergency", "defibrillator")	
		-- TODO add all Important tags here too on it if they exist.
	end

	-- Points go to a "other" layer:
	-- Features which can be all around the course but is not only found on the course itself.
	-- Ask youself: "Is this something that is not inherintely intresting to people who not play golf? "

	local man_made= Find("man_made") -- Mainly for man_made=water_tap 
	if man_made~="" then
		Layer("other")
		Attribute("man_made", Find("man_made")) 
	end

	-- add golf shops, the shop at the Masters etc.
	local shop = Find("shop") 
	if shop~="" then
		Layer("other")
		Attribute("shop", Find("shop"))
		Attribute("name", Find("name"))
	end

	-- Leisure-pois: (For example, leisure=firepit)

	local leisure = Find("leisure")
	if leisure~="" then
		Layer("other")
		Attribute("leisure", leisure)
	end

	-- Tourisms nodes, 
	-- Campsites/huts which some golf clubs have inside of their facilities:
	local tourism = Find("tourism")
	if tourism~="" then
		Layer("other")
		Attribute("tourism", tourism)
	end


	-- General tags for all nodes:

	-- entrance for the buildings:
	local entrance = Find("entrance")
	if entrance~="" then
		Layer("other")
		Attribute("entrance", entrance)
	end
	
	-- shared common attributes between nodes & ways/areas:
	general_attributes()


end

-- list of possible keys or key-value pairs to speed up/use less memory:
way_keys = {"leisure", "name", "golf", "natural", "surface", "highway", "waterway", "building", "landuse" } 

-- Assign ways to a layer, and set attributes, based on OSM tags:

function way_function()

	-- Ways and areas to go to a "golf" layer:

	-- The main (multi)polygon facility, 0:
	local leisure = Find("leisure")
	if leisure == "golf_course" then
		Layer("golf", true) -- Second parameter denotes true - it is an area, not a way.
		Attribute("leisure", "golf_course")
		local name = Find("name")
		if name~="" then
			Attribute("name", name)
		end
		-- TODO fix multi-language naming with the subtag name:<CODE>=<LANGUAGE>
		local short_name = Find("short_name") -- If the club is named Exempelklubben Golfklubb would the short name be Exempelklubben GK or other name 
		if short_name~="" then 
			Attribute("short_name", short_name)
		end 
		--NOTE that this schema is working with the route=golf way of representing multiple courses inside of one course,
		-- see the osm wiki for more discussion of the matter. one could argue that it is imposible for data consumers
		-- to know what holes goes into what course, with the golf:course key on the leisure=golf_course facility. 
		
		general_attributes()

	end

	-- Golf ways and (multi)polygons:
	local golf = Find("golf")
 
	if golf~="" then

		-- Hole logic:
		elseif golf == "hole" then 
			Layer("golf", false)
			Attribute("golf", "hole")
			local par = Find("par")-- TODO How to do this properly in lua? Will it be returned as a string or a number?
			if par~="" then
			-- TODo Datatype integer checking for misstaggning on the following? Or does Lua fix it? Hard crash?
				AttributeInteger("par", par)
			end
			local handicap = Find("handicap")
			if handicap~="" then
				AttributeInteger("par", par)
			end
			local dist = Find("dist")
			if dist~="" then
				AttributeInteger("dist", dist)
			end


			local name = Find("name")
			if name~="" then 
				AttributeInteger("name", name) -- Name of the hole.
			end 

			-- TODO connect with the relations here to get the name of the course both also through it.
			-- Prefer the name from the route=golf instead of the per hole data which have been tagged. 

			local ref = Find("ref")
			if ref~="" then
				AttributeInteger("hole_number", ref) -- this is one of the few times a rename of the key in the tiles occur. More suitable with hole_number than generic ref.
			end

		end
		elseif golf == "cartpath" then 
			Layer("golf", false)
			Attribute("golf", "cartpath")
		end
		--elseif golf == "path"
			-- NOTE! That As discussed by people in the talk page of this tag this could be superfluous, as the wiki states:  "It is likely that standard tags highway=path and highway=footway should be used instead."
		--end
		elseif golf == "out_of_bounds" then 
			Layer("golf", false)
			Attribute("golf", "out_of_bounds")
		end
		else
			Layer("golf", true) -- For all other golf features which are ways which are not specified in this schema above, asume they are areas.
			Attribute("golf", golf)
			-- How will golf=clubhouse be handled? duplicate data as this is written now that it is both a building and a golf=clubhouse?
		end
		-- generic attributes which all golf features could have:
		-- TODO maybe move this so all ways could have this on the last pass?
		local name = Find("name")
		if name~="" then 
			Attribute("name", name) -- Generic name for the golf feature.
		end
		local operator = Find("operator")
		if operator ~="" then
			Attribute("operator", operator)
		end
		local sport = Find("sport")
		if sport~="" then 
			Attribute("sport", sport) -- The polygon could be sport=golf or other sport.
		end
	
		get_architect()
	end

	--Landuse:

	local landuse = Find("landuse")
	if landuse~="" then
		Layer("golf", true)
		Attribute("landuse", landuse)

		-- Optional leaf information.
		leaf_cycle = Find("leaf_cycle")
		if leaf_cycle~="" then 
			Attribute("leaf_cycle", leaf_cycle)
		end
		leaf_type = Find("leaf_type")
		if leaf_type~="" then 
			Attribute("leaf_type", leaf_type)
		end
	end

	-- Barrier, mostly for retainig_wall and fence but could be others too:

	local barrier = Find("barrier")
	if barrier~="" then
		Layer("golf", false)
		Attribute("barrier", barrier)

		-- Optional fence/barrier information.
		fence_type = Find("fence_type")
		if fence_type~="" then 
			Attribute("fence_type", fence_type)
		end
		material = Find("material")
		if material~="" then 
			Attribute("material", material)
		end
	end 


	-- Buildings
	local building = Find("building")
	if building~="" then
		Layer("building", true)
		-- Architect:
		get_architect()
	end

 
	-- Roads
	-- TODO fix the new 2019 cart path schema to cover it all: https://wiki.openstreetmap.org/wiki/Key:golf_cart
	local highway = Find("highway")
	if highway~="" then
		Layer("golf", false)
		if highway=="unclassified" or highway=="residential" then 
			highway="minor"
		end
		Attribute("highway", highway)
		-- ...and road names
		local name = Find("name")
		if name~="" then
			Layer("golf", false)
			Attribute("highway", highway)
			Attribute("name", name)
		end
	end

	--Paved stones or other surfaces, for areas between club houses which people move around on without it being a road.

	local area_highway = Find("area:highway")
		if area_highway~="" then
			Layer("golf", true)
			Attribute("area_highway", area_highway)
			local surface = Find("area:highway")
			if surface~="" then
				Attribute("surface", surface)
			end

		end 

	-- Bridges: (yEaH?)

	-- importing this twice becuase of the man_made import too? TODO research.
	local bridge = Find("bridge")
	if bridge~="" then 
		if OsmType() == "way" then
			Layer("golf", false)
			Attribute("bridge", bridge)
		else 
			Layer("golf", true)
			Attribute("bridge", bridge)
		end
		get_architect()
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
	elseif natural~="" then --import all natur=* tags to cover other, bushes waste areas etc?
		if OsmType() == "way" then
			Layer("golf", false)
			Attribute("natural", natural)
		else
			Layer("golf", true)
			Attribute("natural", natural)
		end 

	end


-- Ways and areas to go to a "other" layer:


-- Tourisms nodes, 
-- Campsites/huts which some golf clubs have inside of their facilities:
local tourism = Find("tourism")
if tourism~="" then
	Layer("other", true) -- I assume all tourist is areas. Artwork could be a way. TODO resolve. 
	Attribute("tourism", tourism)
end




end