/datum/species/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	var/list/bodyparts_to_add = mutant_bodyparts.Copy()
	var/list/relevent_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER, BODY_FRONT_LAYER)
	var/list/standing = list()

	H.remove_overlay(BODY_BEHIND_LAYER)
	H.remove_overlay(BODY_ADJ_LAYER)
	H.remove_overlay(BODY_FRONT_LAYER)

	if(mutant_bodyparts)
		if("tail_lizard" in mutant_bodyparts)
			if(H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))
				bodyparts_to_add -= "tail_lizard"
		if("waggingtail_lizard" in mutant_bodyparts)
			if(H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))
				bodyparts_to_add -= "waggingtail_lizard"
			else if ("tail_lizard" in mutant_bodyparts)
				bodyparts_to_add -= "waggingtail_lizard"
		if("tail_human" in mutant_bodyparts)
			if(H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))
				bodyparts_to_add -= "tail_human"
		if("waggingtail_human" in mutant_bodyparts)
			if(H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))
				bodyparts_to_add -= "waggingtail_human"
			else if ("tail_human" in mutant_bodyparts)
				bodyparts_to_add -= "waggingtail_human"
		if("spines" in mutant_bodyparts)
			if(!H.dna.features["spines"] || H.dna.features["spines"] == "None" || H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))
				bodyparts_to_add -= "spines"
		if("waggingspines" in mutant_bodyparts)
			if(!H.dna.features["spines"] || H.dna.features["spines"] == "None" || H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))
				bodyparts_to_add -= "waggingspines"
			else if ("tail" in mutant_bodyparts)
				bodyparts_to_add -= "waggingspines"
		if("snout" in mutant_bodyparts) //Take a closer look at that snout!
			if((H.wear_mask && (H.wear_mask.flags_inv & HIDEFACE)) || (H.head && (H.head.flags_inv & HIDEFACE)))
				bodyparts_to_add -= "snout"
		if("frills" in mutant_bodyparts)
			if(!H.dna.features["frills"] || H.dna.features["frills"] == "None" || H.head && (H.head.flags_inv & HIDEEARS))
				bodyparts_to_add -= "frills"
		if("horns" in mutant_bodyparts)
			if(!H.dna.features["horns"] || H.dna.features["horns"] == "None" || H.head && (H.head.flags & BLOCKHAIR) || (H.wear_mask && (H.wear_mask.flags & BLOCKHAIR)))
				bodyparts_to_add -= "horns"
		if("ears" in mutant_bodyparts)
			if(!H.dna.features["ears"] || H.dna.features["ears"] == "None" || H.head && (H.head.flags & BLOCKHAIR) || (H.wear_mask && (H.wear_mask.flags & BLOCKHAIR)))
				bodyparts_to_add -= "ears"

	if(bodyparts_to_add)
		var/g = (H.gender == FEMALE) ? "f" : "m"
		var/image/I
		for(var/layer in relevent_layers)
			for(var/bodypart in bodyparts_to_add)
				var/datum/sprite_accessory/S
				switch(bodypart)
					if("tail_lizard")
						S = tails_list_lizard[H.dna.features["tail_lizard"]]
					if("waggingtail_lizard")
						S.= animated_tails_list_lizard[H.dna.features["tail_lizard"]]
					if("tail_human")
						S = tails_list_human[H.dna.features["tail_human"]]
					if("waggingtail_human")
						S.= animated_tails_list_human[H.dna.features["tail_human"]]
					if("spines")
						S = spines_list[H.dna.features["spines"]]
					if("waggingspines")
						S.= animated_spines_list[H.dna.features["spines"]]
					if("snout")
						S = snouts_list[H.dna.features["snout"]]
					if("frills")
						S = frills_list[H.dna.features["frills"]]
					if("horns")
						S = horns_list[H.dna.features["horns"]]
					if("ears")
						S = ears_list[H.dna.features["ears"]]
					if("body_markings")
						S = body_markings_list[H.dna.features["body_markings"]]
				if(!S || S.icon_state == "none")
					continue
				//A little rename so we don't have to use tail_lizard or tail_human when naming the sprites.
				if(bodypart == "tail_lizard" || bodypart == "tail_human")
					bodypart = "tail"
				else if(bodypart == "waggingtail_lizard" || bodypart == "waggingtail_human")
					bodypart = "waggingtail"
				var/icon_string
				if(S.gender_specific)
					icon_string = "[g]_[bodypart]_[S.icon_state]_[layer]"
				else
					icon_string = "m_[bodypart]_[S.icon_state]_[layer]"
				I = image("icon" = 'icons/mob/mutant_bodyparts.dmi', "icon_state" = icon_string, "layer" =- layer)
				if(!(H.disabilities & HUSK))
					if(!forced_colour)
						switch(S.color_src)
							if(MUTCOLORS)
								I.color = "#[H.dna.features["mcolor"]]"
							if(HAIR)
								if(hair_color == "mutcolor")
									I.color = "#[H.dna.features["mcolor"]]"
								else
									I.color = "#[H.hair_color]"
							if(FACEHAIR)
								I.color = "#[H.facial_hair_color]"
							if(EYECOLOR)
								I.color = "#[H.eye_color]"
					else
						I.color = forced_colour
				standing += I
				if(S.hasinner)
					if(S.gender_specific)
						icon_string = "[g]_[bodypart]inner_[S.icon_state]_[layer]"
					else
						icon_string = "m_[bodypart]inner_[S.icon_state]_[layer]"
					I = image("icon" = 'icons/mob/mutant_bodyparts.dmi', "icon_state" = icon_string, "layer" =- layer)
					standing += I
			H.overlays_standing[layer] = standing.Copy()
			standing = list()

	//Furry Tail code
	var/layer = BODY_FRONT_LAYER
	var/wing = H.dna ? H.dna.mutantwing : null
	if(wing&&wing!="none"&&!H.dna.taur)
		var/image/wing_s = image("icon" = 'icons/mob/wing.dmi', "icon_state" = "[wing]", "layer" =- layer)
		wing_s.color = "#" + H.dna.wingcolor
		standing += wing_s
	if (!mutant_bodyparts || !("tail_lizard" in mutant_bodyparts))
		var/race = H.dna ? H.dna.mutantrace() : null
		if(race&&kpcode_hastail(race) &&!H.dna.taur)
			standing += generate_colour_icon('icons/mob/tail.dmi',"[kpcode_hastail(race)]",H.dna.special_color,add_layer=-layer,offset_y=kpcode_tail_offset(race))
		else
			if(!race||race=="human")
				var/tail = H.dna ? H.dna.mutanttail : null
				if(tail&&kpcode_hastail(tail) &&!H.dna.taur)
					standing += generate_colour_icon('icons/mob/tail.dmi',"[kpcode_hastail(tail)]",H.dna.special_color,add_layer=-layer,offset_y=kpcode_tail_offset(race),human=hair_color)
		if(H.dna&&H.dna.taur)
			standing += generate_colour_icon('icons/mob/special/taur.dmi',"[kpcode_cantaur(H.dna.mutantrace())]_tail",H.dna.special_color,offset_x=-16,add_layer=-layer)

		H.overlays_standing[layer] = standing.Copy()
		standing = list()

	H.apply_overlay(BODY_BEHIND_LAYER)
	H.apply_overlay(BODY_ADJ_LAYER)
	H.apply_overlay(BODY_FRONT_LAYER)

/datum/species/handle_body(mob/living/carbon/human/H)
	H.remove_overlay(BODY_LAYER)

	var/list/standing	= list()

	if(snowflake)
		standing += generate_colour_icon('icons/mob/human.dmi',"[H.base_icon_state]_s",H.dna.special_color,add_layer=-BODY_LAYER,overlay_only=1)

	handle_mutant_bodyparts(H)

	// lipstick
	if(H.lip_style && LIPS in specflags)
		var/image/lips = image("icon"='icons/mob/human_face.dmi', "icon_state"="lips_[H.lip_style]_s", "layer" = -BODY_LAYER)
		lips.color = H.lip_color
		standing	+= lips

	// eyes
	if(EYECOLOR in specflags)
		var/image/img_eyes_s = image("icon" = 'icons/mob/human_face.dmi', "icon_state" = "[eyes]_s", "layer" = -BODY_LAYER)
		img_eyes_s.color = "#" + H.eye_color
		standing	+= img_eyes_s

	if (H.underwear_active)
	//Underwear, Undershirts & Socks
		if(H.underwear)
			var/datum/sprite_accessory/underwear/U = underwear_list[H.underwear]
			if(U)
				standing	+= image("icon"=U.icon, "icon_state"="[U.icon_state]_s", "layer"=-BODY_LAYER)

		if(H.undershirt)
			var/datum/sprite_accessory/undershirt/U2 = undershirt_list[H.undershirt]
			if(U2)
				if(H.dna.species.sexes && H.gender == FEMALE)
					standing	+=	wear_female_version("[U2.icon_state]_s", U2.icon, BODY_LAYER)
				else
					standing	+= image("icon"=U2.icon, "icon_state"="[U2.icon_state]_s", "layer"=-BODY_LAYER)

		if(H.socks)
			var/datum/sprite_accessory/socks/U3 = socks_list[H.socks]
			if(U3)
				standing	+= image("icon"=U3.icon, "icon_state"="[U3.icon_state]_s", "layer"=-BODY_LAYER)

	if(H.dna&&H.dna.taur&&!kpcode_cantaur(id))
		H.dna.taur=0

	if((!(H.underwear&&H.underwear!="Nude") || !H.underwear_active) && (H.dna && H.dna.cock && !H.dna.taur) && (!H.wear_suit || !(H.wear_suit.flags_inv&HIDEJUMPSUIT)) && (!H.w_uniform||!(H.w_uniform.body_parts_covered&GROIN)))
		//cock codes here
		var/list/cock=H.dna.cock
		var/cock_mod=0
		var/cock_type=cock["type"]
		if(cock["has"]==COCK_NORMAL)cock_mod="n"
		else if(cock["has"]==COCK_HYPER)cock_mod="h"
		else if(cock["has"]==COCK_DOUBLE)cock_mod="d"
		if(cock_mod)
			var/icon/chk=new/icon('icons/mob/cock.dmi')
			var/list/available_states=chk.IconStates()
			if(available_states.Find("[cock_type]_c_[cock_mod]"))
				var/image/cockimtmp	= image("icon"='icons/mob/cock.dmi', "icon_state"="[cock_type]_c_[cock_mod]", "layer"=-BODY_LAYER)
				var/new_color = "#" + cock["color"]
				cockimtmp.color = new_color
				standing += cockimtmp
			if(available_states.Find("[cock_type]_s_[cock_mod]"))
				var/image/cockimtmp	= image("icon"='icons/mob/cock.dmi', "icon_state"="[cock_type]_s_[cock_mod]", "layer"=-BODY_LAYER)
				if(H.dna.special_color[2])
					cockimtmp.color = "#[H.dna.special_color[2]]"
				else if((MUTCOLORS in specflags))
					cockimtmp.color = "#[H.dna.features["mcolor"]]"
				standing += cockimtmp

	if(H.dna&&H.dna.taur)
		var/taur_state="[kpcode_cantaur(H.dna.mutantrace())]_overlay"
		if(H.vore_womb_datum.has_people()||H.vore_stomach_datum.has_people())
			taur_state+="_f"
		standing += generate_colour_icon('icons/mob/special/taur.dmi',"[taur_state]",H.dna.special_color,offset_x=-16,add_layer=-BODY_LAYER)

	if(standing.len)
		H.overlays_standing[BODY_LAYER] = standing

	H.apply_overlay(BODY_LAYER)

	return