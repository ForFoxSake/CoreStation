#define DNA_COLOR_ONE_BLOCK			11
#define DNA_COLOR_TWO_BLOCK			12
#define DNA_COLOR_THR_BLOCK			13
#define DNA_COLOR_SWITCH_BLOCK		14
#define DNA_COLOR_SWITCH_MAX		7 //must be (2^(n+1))-1
#define DNA_COCK_BLOCK				15
#define DNA_MUTANTRACE_BLOCK		16
#define DNA_MUTANTTAIL_BLOCK		17
#define DNA_MUTANTWING_BLOCK		18
#define DNA_WINGCOLOR_BLOCK			19
#define DNA_TAUR_BLOCK				20

proc/sanitize_colour_list(var/list/lst=null)
	if(!lst||!lst.len)
		lst=new/list(COLOUR_LIST_SIZE)
	if(lst.len!=COLOUR_LIST_SIZE)
		var/new_lst[COLOUR_LIST_SIZE]
		for(var/x=1,x<=COLOUR_LIST_SIZE,x++)
			new_lst[x]=lst[x]
		lst=new_lst
	return lst

proc/generate_colour_icon(var/fil_chk=null,var/state=null,var/list/lst=null,var/add_layer=0,var/offset_x=0,var/offset_y=0,var/overlay_only=0,var/human=0)
	if(!fil_chk||!state)return null
	lst=sanitize_colour_list(lst)
	var/icon/chk=new/icon(fil_chk)
	var/list/available_states=chk.IconStates()
	var/list/rtn_lst = list()
	if(!overlay_only&&available_states.Find("[state]"))
		rtn_lst += image("icon"=fil_chk, "icon_state"="[state]", "pixel_y"=offset_y, "pixel_x"=offset_x, "layer"=add_layer)
	var/chk_len=human ? 1 : lst.len
	for(var/x=1,x<=chk_len,x++)
		if(!lst[x]&&!human)continue
		var/state_check="[state]_[x]"
		if(x==1)
			if(human)
				state_check="[state]_h"
			else
				if(!available_states.Find("[state_check]"))
					state_check="[state]_h"
		if(available_states.Find("[state_check]"))
			var/image/colourized = image("icon"=fil_chk, "icon_state"="[state_check]", "pixel_y"=offset_y, "pixel_x"=offset_x, "layer"=add_layer)
			var/new_color = "#" + "[human ? human : lst[x]]"
			colourized.color = new_color
			rtn_lst += colourized
	return rtn_lst

/mob/living/carbon/human/var/heterochromia=0

/datum/dna
	var/mutanttail	//Narky code~
	var/mutantwing
	var/wingcolor="FFF"
	var/special_color[COLOUR_LIST_SIZE]
	var/list/cock=list("has"=COCK_NONE,"type"="human","color"="900")
	var/vagina=0
	var/datum/special_mutant/special
	var/taur=0 //TEMP!
	var/mob/living/simple_animal/naga_segment/naga=null //ALSO TEMP!
/*	proc/generateExtraData()
		var/list/EDL=list(
		"race"=mutantrace,
		"tail"=mutanttail,
		"sc"=special_color,
		"cock"=cock,
		"vagina"=vagina)
		return EDL
	proc/addExtraData(var/list/EDL, var/setit=0)
		if(EDL["race"]||setit)
			mutantrace=EDL["race"]
		if(EDL["tail"]||setit)
			mutanttail=EDL["tail"]
		if(EDL["sc"]||setit)
			special_color=EDL["sc"]
		if(EDL["cock"]||setit)
			cock=EDL["cock"]
		if(!isnull(EDL["vagina"])||setit)
			vagina=EDL["vagina"]*

	proc/setExtraData(var/list/EDL)*/







/datum/special_mutant
	proc/generate_overlay()
		return 0
	proc/generate_underlay()
		return 0


/datum/dna/proc/mutantrace() //Easy legacy support!
	if(species)
		return species.id
	else
		return "human"

/datum/dna/proc/generate_race_block()
	var/block_gen="fff"
	if(species_list[mutantrace()])
		//block_gen = construct_block(species_list.Find(mutantrace), species_list.len+1)
		block_gen = construct_block(species_list.Find(species.id), species_list.len+1)
	else
		block_gen = construct_block(species_list.len+1, species_list.len+1)
	return block_gen

/mob/living/proc/set_mutantrace(var/new_mutantrace=null)
	new_mutantrace=kpcode_race_san(new_mutantrace)
	var/datum/dna/dna=has_dna(src)
	if(!dna)return
	if(new_mutantrace)
		//dna.mutantrace=new_mutantrace
		if(species_list.Find(new_mutantrace))
			//var/typ=species_list[species_list.Find(dna.species.id)]
			//dna.species=new typ()
			dna.species=kpcode_race_get(new_mutantrace)
	dna.uni_identity = setblock(dna.uni_identity, DNA_MUTANTRACE_BLOCK, dna.generate_race_block())
	regenerate_icons()


/datum/dna/proc/generate_cock_block()
	var/cock_block=0
	if(cock["has"])
		cock_block+=1
	if(vagina)
		cock_block+=2
	return construct_block(cock_block+1, 4)

/mob/living/proc/set_cock_block()
	var/datum/dna/dna=has_dna(src)
	if(!dna)return
	dna.uni_identity = setblock(dna.uni_identity, DNA_COCK_BLOCK, dna.generate_cock_block())


/mob/living/proc/is_taur()
	if(istype(src,/mob/living/carbon/human)&&src:dna&&src:dna:taur)
		if(src:dna:species&&kpcode_cantaur(src:dna:species))
			return 1
	return 0

mob/living/carbon/human/updateappearance(icon_update=1, mutcolor_update=0, mutations_overlay_update=0)
	..()
	var/structure = dna.uni_identity
	hair_color = sanitize_hexcolor(getblock(structure, DNA_HAIR_COLOR_BLOCK))
	facial_hair_color = sanitize_hexcolor(getblock(structure, DNA_FACIAL_HAIR_COLOR_BLOCK))
	skin_tone = skin_tones[deconstruct_block(getblock(structure, DNA_SKIN_TONE_BLOCK), skin_tones.len)]
	eye_color = sanitize_hexcolor(getblock(structure, DNA_EYE_COLOR_BLOCK))
	facial_hair_style = facial_hair_styles_list[deconstruct_block(getblock(structure, DNA_FACIAL_HAIR_STYLE_BLOCK), facial_hair_styles_list.len)]
	hair_style = hair_styles_list[deconstruct_block(getblock(structure, DNA_HAIR_STYLE_BLOCK), hair_styles_list.len)]

	var/mutantrace_c = deconstruct_block(getblock(structure, DNA_MUTANTRACE_BLOCK), species_list.len+1)
	if(mutantrace_c<=species_list.len && kpcode_race_restricted(species_list[mutantrace_c])!=2)
		dna.species=kpcode_race_get(species_list[mutantrace_c])
	var/mutanttail_c = deconstruct_block(getblock(structure, DNA_MUTANTTAIL_BLOCK), mutant_tails.len+1)
	if(mutanttail_c<=mutant_tails.len)
		dna.mutanttail=mutant_tails[mutanttail_c]
	else
		dna.mutanttail=null
	var/mutantwing_c = deconstruct_block(getblock(structure, DNA_MUTANTWING_BLOCK), mutant_wings.len+1)
	if(mutantwing_c<=mutant_wings.len)
		dna.mutantwing=mutant_wings[mutantwing_c]
	else
		dna.mutantwing=null

	dna.wingcolor = sanitize_hexcolor(getblock(structure, DNA_WINGCOLOR_BLOCK))
	var/colour_switch=deconstruct_block(getblock(structure, DNA_COLOR_SWITCH_BLOCK), DNA_COLOR_SWITCH_MAX+1)
	colour_switch-=1
	if(colour_switch&1)
		dna.special_color[1]=sanitize_hexcolor(getblock(structure, DNA_COLOR_ONE_BLOCK))
	else
		dna.special_color[1]=null
	if(colour_switch&2)
		dna.special_color[2]=sanitize_hexcolor(getblock(structure, DNA_COLOR_TWO_BLOCK))
	else
		dna.special_color[2]=null
	if(colour_switch&4)
		dna.special_color[3]=sanitize_hexcolor(getblock(structure, DNA_COLOR_THR_BLOCK))
	else
		dna.special_color[3]=null

	var/cock_block=deconstruct_block(getblock(structure, DNA_COCK_BLOCK), 4)
	cock_block-=1
	if(!(cock_block&1))
		dna.cock["has"]=0
	else if(!dna.cock["has"]&&(cock_block&1))
		dna.cock["has"]=1

	if(cock_block&2)
		dna.vagina=1
	else
		dna.vagina=0

	dna.taur=deconstruct_block(getblock(structure, DNA_TAUR_BLOCK), 2)-1

	if(icon_update)
		update_body()
		update_hair()
		if(mutcolor_update)
			update_mutcolor()
		if(mutations_overlay_update)
			update_mutations_overlay()