--[[

	These tiles contain attributes which mirrors their actual OSM tags(key=value pairs).

	The basic principle is:
	- read OSM tags with Find(key)
	- write to vector tile layers with Layer(layer_name)
	- add attributes with Attribute(field, value)

]]--

-- Accepts the route=golf to be imported to be used as the course(s)
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
-- This is just complementary Attributes/tags - another key need to get it into the layer. 
function general_attributes()
	local name = Find("name")
	if name~="" then
		Attribute("name", name)
	end
	local short_name = Find("short_name")
	if short_name~="" then 
		Attribute("short_name", short_name)
	end
	-- TODO fix multi-language naming with the subtag name:<CODE>=<LANGUAGE>
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
		Attribute("website", website)
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

	-- Sports:
	local sport = Find("sport")
	if sport~="" then 
		Attribute("sport", sport)
	end

end

-- Nodes will only be processed if one of these keys is present. This reduces memory drastically as stated by the documentation.
node_keys = { "golf", "natural", "leaf_cycle", "leaf_type", "information", "amenity", "vending",
				"male", "female", "unisex", "toilets", "emergency", "man_made", "shop", "leisure",
				"tourism", "entrance", "name", "short_name", "operator", "opening_hours", "wikidata", "phone", "website",
				"addr:postcode", "addr:city", "addr:street", "access", "sport" } 

-- Assign nodes to a layer, and set attributes, based on OSM tags
function node_function(node)
	-- TODO rewrite this logic, its only one node per function call no need for too many evaluations? Or the interpreter fixes it?

	-- Points to go to the "golf" layer. Features on the course itself.
	local golf = Find("golf")
	if golf~="" then
		Layer("golf") -- This is what actually puts it in the tile. Remember: First layer and then attributes.
		Attribute("golf", golf) -- key=value pairs.
	end
	local natural = Find("natural") -- mainly for natural=tree
	if natural~="" then
		Layer("golf")
		Attribute("natural", natural) 
		-- Adds tree information:
		if natural=="tree" then
			local leaf_cycle = Find("leaf_cycle")
			 if leaf_cycle~="" then
				Attribute("leaf_cycle", leaf_cycle)
			end
			local leaf_type = Find("leaf_type")
			if leaf_type~="" then
				Attribute("leaf_type", leaf_type)
			end
		end
		--TODO could be to add height= and width=
	end
	-- Add signs and signposts:
	local information = Find("information") -- Mainly for information=guideposts and other signs on the course.
	if information~="" then
		Layer("golf")
		Attribute("information", information) 
		 --TODO is add the descriptions and the destinations for these signs.
	end
	-- Add amenity nodes:
	local amenity = Find("amenity") -- Mainly for amenity=bench and trashcans.
	if amenity~="" then  -- All amenity-tags.
		Layer("golf")
		Attribute("amenity", amenity) 
		-- amenity=vending_machine logic, vending=golf_balls
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
				Attribute("unisex", unisex)
			end 
		end 

	end

	-- toilets key for nodes: 
	local toilets = Find("toilets")
	if toilets~="" then
		Layer("golf")
		Attribute("toilets", toilets)
	end 

	-- Add AED´s:
	local emergency = Find("emergency")
	if emergency == "defibrillator" then
		Layer("golf")
		Attribute("emergency", "defibrillator")	
		-- TODO add all Important tags here too on it if they exist.
	end

	-- Points go to a "other" layer:
	-- Features which can be all around the course but is not only found on the course itself.
	-- Ask yourself: "Is this something that is not inherently interesting to people who not play golf? "

	local man_made= Find("man_made") -- Mainly for man_made=water_tap 
	if man_made~="" then
		Layer("other")
		Attribute("man_made", man_made) 
	end

	-- add golf shops, the shop at the Masters etc.
	local shop = Find("shop") 
	if shop~="" then
		Layer("other")
		Attribute("shop", shop)
		Attribute("name", Find("name")) -- assume all shops have name.
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
	general_attributes() -- Move this into the different nodes! 
	-- what happens if no Layer("other") have run - will it just fail here? Or just discard it?
	-- TODO maybe place these general attributes inside all the placements - 


end

-- list of possible keys or key-value pairs to speed up/use less memory:
way_keys = {"leisure", "golf", "par", "handicap", "dist", "golf:course:name", "ref", "landuse", "leaf_cycle", "leaf_type", "barrier", "fence_type", "material", "building", "highway", "area:highway", "man_made", "waterway", "natural", "surface", "tourism", "name", "short_name", "operator", "opening_hours", "wikidata", "phone", "website", "addr:postcode", "addr:city", "addr:street", "access", "sport"} 

-- Assign ways to a layer, and set attributes, based on OSM tags:

function way_function()

	-- Ways and areas to go to a "golf" layer:

	-- The main (multi)polygon facility, 0:
	local leisure = Find("leisure")
	if leisure == "golf_course" then
		Layer("golf", true) -- Second parameter denotes true - it is an area, not a way.
		Attribute("leisure", "golf_course")

		-- Due to old tagging schemas - course data which are tagged on the leisure=golf_course
		-- polygon is hard to access because that would require to query the data to be able to
		-- determine which holes are inside of a specific facility and then apply these tags if they exist
		-- on the leisure=golf_course to the golf=hole to produce same tiles regardless how it was tagged.
		-- To not encourage this mapping behavior, this data on leisure=golf_course is omitted.

		--NOTE: Although it is possible to tag course tags on the leisure=golf_course and many have done so
		-- because the lack of better tagging practices documented. It is NOT recommended. 
		-- For better data, do it with a route=golf or map it into the golf=holes themselves where route=golf is preferred to 
		-- reduce the amount of duplicate data in the database.
		-- See the wiki under https://wiki.openstreetmap.org/wiki/Tag:leisure%3Dgolf_course#Courses_in_a_facility

	end

	-- Golf ways and (multi)polygons:
	local golf = Find("golf")
 
	if golf~="" then

		-- Hole logic:
		if golf == "hole" then 
			Layer("golf", false)
			Attribute("golf", "hole")
			local par = Find("par")-- TODO How to do this properly in lua? Will it be returned as a string or a number?
			if par~="" then
			-- TODo Datatype integer checking for misstaggning on the following? Or does Lua fix it? Hard crash?
				AttributeInteger("par", par)
			end
			local handicap = Find("handicap")
			if handicap~="" then
				AttributeInteger("handicap", handicap)
			end
			local dist = Find("dist")
			if dist~="" then
				AttributeInteger("dist", dist)
			end
	
			-- Get the course information if it exists on the object itself:
			local golf_course_name = Find("golf:course:name") -- Will it be the same object down in the relation-info to get these values?

			local golf_course = Find("golf:course")

			local golf_par = Find("golf:par") -- The par for the entire course.

			-- Get potential route=golf relation with information about the course:
			-- If both exist, prioritizes info in route=golf:

			local set_golf_course_name = false
			local set_golf_course = false
			local set_golf_par = false

			while true do -- TODO Put this into a function and pass parameters to be able to use it on tee´s and out_of_bounds?
				local relation_id = NextRelation()
				if not relation_id then -- The object could have more than on relation, add all courses then.
					break -- rework this lua logic to better handle all cases. 
				end
				local golf_course_name_rel = FindInRelation("golf:course:name")
				if golf_course_name_rel~="" then 
					golf_course_name = golf_course_name_rel -- I hope I assign to the previous declared variable to both get info from per hole and route=golf.
					set_golf_course_name = true
				end
				local golf_course_rel = FindInRelation("golf:course")
				if golf_course_rel~="" then 
					golf_course = golf_course_rel
					set_golf_course = true
				end 				
				local golf_par_rel = FindInRelation("golf:par")
				if golf_par_rel~="" then 
					golf_par = golf_par_rel
					set_golf_par = true
				end
				-- Sets the attributes:
				if golf_course_name~="" then 
					Attribute("golf:course:name", golf_course_name) -- Name of the course this hole belongs to.
				end 
				if golf_course~="" then 
					Attribute("golf_course", golf_course) -- Maybe rename this to nr_of_holes_course
				end
				if golf_par~="" then 
					AttributeInteger("golf_par", golf_par)
				end

				-- print ("Part of route "..FindInRelation("ref"))
			end

			-- Still sets the course info from the golf=holes even if no route=golf tags is present.
			if golf_course_name~="" and not set_golf_course_name then 
				Attribute("golf:course:name", golf_course_name) -- Name of the course this hole belongs to.
			end 
			if golf_course~="" and not set_golf_course then 
				Attribute("golf_course", golf_course)
			end
			if golf_par~="" and not set_golf_par then 
				Attribute("golf_par", golf_par)
			end


			local ref = Find("ref")  -- I tonumber(ref) needed for a lua number?
			if ref~="" then
				AttributeInteger("hole_number", ref) -- this is one of the few times a rename of the key in the tiles occur. More suitable with hole_number than generic ref.
			end
		elseif golf == "cartpath" then 
			Layer("golf", false)
			Attribute("golf", "cartpath")
		--elseif golf == "path"
			-- NOTE! That As discussed by people in the talk page of this tag this could be superfluous, 
			-- as the wiki states:  "It is likely that standard tags highway=path and highway=footway should be used instead."
		elseif golf == "out_of_bounds" then 
			Layer("golf", false)
			Attribute("golf", "out_of_bounds")
		else -- For all other golf features which are ways which are not specified in this schema above, assume they are areas.
			Layer("golf", true)
			Attribute("golf", golf)
			-- How will golf=clubhouse be handled? duplicate data as this is written now that it is both a building and a golf=clubhouse?
			-- TODO research how we best represent different tee colors/numbers and update the wiki!
		end
		-- generic attributes which all golf features could have:
	
		get_architect()

		general_attributes()
	end

	--Landuse:

	local landuse = Find("landuse")
	if landuse~="" then
		Layer("golf", true) -- Always an area.
		Attribute("landuse", landuse)

		-- Optional leaf information.
		local leaf_cycle = Find("leaf_cycle")
		if leaf_cycle~="" then 
			Attribute("leaf_cycle", leaf_cycle)
		end
		local leaf_type = Find("leaf_type")
		if leaf_type~="" then 
			Attribute("leaf_type", leaf_type)
		end
	end

	-- Barrier, mostly for retaining_wall and fence but could be others too:

	local barrier = Find("barrier")
	if barrier~="" then

		if IsClosed() then
			Layer("golf", true)
		else 
			Layer("golf", false)
		end
		Attribute("barrier", barrier)

		-- Optional fence/barrier information.
		local fence_type = Find("fence_type")
		if fence_type~="" then 
			Attribute("fence_type", fence_type)
		end
		local material = Find("material")
		if material~="" then 
			Attribute("material", material)
		end
	end 


	-- Buildings
	local building = Find("building")
	if building~="" then
		Layer("golf", true)
		Attribute("building", building)
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
			local surface = Find("surface")
			if surface~="" then
				Attribute("surface", surface)
			end

		end 

	-- mainly for man_made=bridge which can occur on the golf course.
	local man_made = Find("man_made")
	if man_made~="" then 
		if IsClosed() then
			Layer("golf", true)
		else 
			Layer("golf", false)
		end
		Attribute("man_made", man_made)
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
		
		-- Optional leaf information:
		local leaf_cycle = Find("leaf_cycle")
		if leaf_cycle~="" then 
			Attribute("leaf_cycle", leaf_cycle)
		end
		local leaf_type = Find("leaf_type")
		if leaf_type~="" then 
			Attribute("leaf_type", leaf_type)
		end
	elseif natural~="" then --import all natur=* tags to cover other, bushes waste areas etc?
		if IsClosed() then -- tODO will multiPolygons be covered by this?
			Layer("golf", true)
			Attribute("natural", natural)
		else
			Layer("golf", false)
			Attribute("natural", natural)
		end 

	end


	-- Ways and areas to go to a "other" layer:

	-- Tourisms nodes, 
	-- Mainly for Campsites/huts which some golf clubs have inside of their facilities:
	local tourism = Find("tourism")
	if tourism~="" then
		if IsClosed() then
			Layer("other", true)
		else 
			Layer("other", false)
		end
		Attribute("tourism", tourism)
	end


end