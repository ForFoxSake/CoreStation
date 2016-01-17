#define COCK_NONE			0
#define COCK_NORMAL			1
#define COCK_HYPER			2
#define COCK_DOUBLE			3
#define COLOUR_LIST_SIZE	4

#define VORE_METHOD_FAIL	0
#define VORE_METHOD_ORAL	1
#define VORE_METHOD_ANAL	2
#define VORE_METHOD_COCK	4
#define VORE_METHOD_UNBIRTH	8
#define VORE_METHOD_BREAST	16
#define VORE_METHOD_TAIL	32
#define VORE_METHOD_INSOLE	64
#define VORE_METHOD_ABSORB	128
#define VORE_METHOD_INSUIT	256

#define VORE_EXTRA_FULLTOUR	1
#define VORE_EXTRA_REMAINS	2

#define VORE_REMAINS_NONE		0
#define VORE_REMAINS_GENERIC	1
#define VORE_REMAINS_NAMED		2

#define VORE_MODE_EAT		1
#define VORE_MODE_FEED		2

#define VORE_DIGESTION_SPEED_NONE		0
#define VORE_DIGESTION_SPEED_SLOW		1
#define VORE_DIGESTION_SPEED_FAST		2
#define VORE_DIGESTION_SPEED_ABNORMAL	4
#define VORE_TRANSFORM_SPEED_NONE		0
#define VORE_TRANSFORM_SPEED_SLOW		2
#define VORE_TRANSFORM_SPEED_FAST		4
#define VORE_TRANSFER_SPEED_NONE		0
#define VORE_TRANSFER_SPEED_SLOW		6
#define VORE_TRANSFER_SPEED_FAST		9

#define VORE_SIZEDIFF_DISABLED		0
#define VORE_SIZEDIFF_TINY			1
#define VORE_SIZEDIFF_SMALLER		2
#define VORE_SIZEDIFF_SAMESIZE		3
#define VORE_SIZEDIFF_DOUBLE		4
#define VORE_SIZEDIFF_ANY			5

#define VORE_FLAVOUR_SILENT		0
#define VORE_FLAVOUR_DIGEST		1
#define VORE_FLAVOUR_RELEASE		2
#define VORE_FLAVOUR_HURL		3
#define VORE_FLAVOUR_ESCAPE		4
#define VORE_FLAVOUR_TRANSFORM	5
#define VORE_FLAVOUR_TRANSFER	6


/mob/proc/get_top_level_mob()
	if(istype(src.loc,/mob)&&src.loc!=src)
		var/mob/M=src.loc
		return M.get_top_level_mob()
	return src

proc/get_top_level_mob(var/mob/S)
	if(istype(S.loc,/mob)&&S.loc!=S)
		var/mob/M=S.loc
		return M.get_top_level_mob()
	return S

/mob/living/
	var/list/vore_contents = list()

/obj/item/weapon/grab/attack(mob/M, mob/user)
	if(!affecting)
		return

	if(M == affecting)
		s_click(hud)
		return

	if(state >= GRAB_AGGRESSIVE)
		if(istype(M,/mob/living))
			var/mob/living/predator=M
			predator.vore_initiate(affecting,assailant)


/datum/preferences
	max_save_slots = 6
	//vore code
	var/mutant_tail = "none"
	var/mutant_wing = "none"
	var/wingcolor = "FFF"
	var/special_color[COLOUR_LIST_SIZE]
	var/vore_banned_methods = 0
	var/vore_extra_bans = 65535
	var/list/vore_ability = list(
	"1"=2,
	"2"=0,
	"4"=0,
	"8"=0,
	"16"=0,
	"32"=0,
	"64"=1,
	"128"=0) //BAAAAD way to do this
	var/character_size="normal"
	var/be_taur=0

	var/list/p_cock=list("has"=0,"type"="human","color"="900","sheath"="FFF")
	var/p_vagina=0

#define SAVEFILE_VERSION_MIN	8
#define SAVEFILE_VERSION_MAX	12

/datum/preferences/load_character(slot)
	if(!path)				return 0
	if(!fexists(path))		return 0
	var/savefile/S = new /savefile(path)
	if(!S)					return 0
	S.cd = "/"
	if(!slot)	slot = default_slot
	slot = sanitize_integer(slot, 1, max_save_slots, initial(default_slot))
	if(slot != default_slot)
		default_slot = slot
		S["default_slot"] << slot

	S.cd = "/character[slot]"
	var/needs_update = savefile_needs_update(S)
	if(needs_update == -2)		//fatal, can't load any data
		return 0

	//Species
	var/species_id
	S["species"]			>> species_id
	if(config.mutant_races && species_id && (species_id in roundstart_species))
		var/newtype = roundstart_species[species_id]
		pref_species = new newtype()
	else
		pref_species = new /datum/species/human()

	if(!S["features["mcolor"]"] || S["features["mcolor"]"] == "#000")
		S["features["mcolor"]"]	<< "#FFF"

	//Character
	S["OOC_Notes"]			>> metadata
	S["real_name"]			>> real_name
	S["name_is_always_random"] >> be_random_name
	S["body_is_always_random"] >> be_random_body
	S["gender"]				>> gender
	S["age"]				>> age
	S["hair_color"]			>> hair_color
	S["facial_hair_color"]	>> facial_hair_color
	S["eye_color"]			>> eye_color
	S["skin_tone"]			>> skin_tone
	S["hair_style_name"]	>> hair_style
	S["facial_style_name"]	>> facial_hair_style
	S["underwear"]			>> underwear
	S["undershirt"]			>> undershirt
	S["socks"]				>> socks
	S["backbag"]			>> backbag
	S["feature_mcolor"]					>> features["mcolor"]
	S["feature_lizard_tail"]			>> features["tail_lizard"]
	S["feature_lizard_snout"]			>> features["snout"]
	S["feature_lizard_horns"]			>> features["horns"]
	S["feature_lizard_frills"]			>> features["frills"]
	S["feature_lizard_spines"]			>> features["spines"]
	S["feature_lizard_body_markings"]	>> features["body_markings"]
	if(!config.mutant_humans)
		features["tail_human"] = "none"
		features["ears"] = "none"
	else
		S["feature_human_tail"]				>> features["tail_human"]
		S["feature_human_ears"]				>> features["ears"]
	S["clown_name"]			>> custom_names["clown"]
	S["mime_name"]			>> custom_names["mime"]
	S["ai_name"]			>> custom_names["ai"]
	S["cyborg_name"]		>> custom_names["cyborg"]
	S["religion_name"]		>> custom_names["religion"]
	S["deity_name"]			>> custom_names["deity"]

	//Jobs
	S["userandomjob"]		>> userandomjob
	S["job_civilian_high"]	>> job_civilian_high
	S["job_civilian_med"]	>> job_civilian_med
	S["job_civilian_low"]	>> job_civilian_low
	S["job_medsci_high"]	>> job_medsci_high
	S["job_medsci_med"]		>> job_medsci_med
	S["job_medsci_low"]		>> job_medsci_low
	S["job_engsec_high"]	>> job_engsec_high
	S["job_engsec_med"]		>> job_engsec_med
	S["job_engsec_low"]		>> job_engsec_low

	//try to fix any outdated data if necessary
	if(needs_update >= 0)
		update_character(needs_update)		//needs_update == savefile_version if we need an update (positive integer)

	//Sanitize
	metadata		= sanitize_text(metadata, initial(metadata))
	real_name		= reject_bad_name(real_name)
	if(!features["mcolor"] || features["mcolor"] == "#000")
		features["mcolor"] = pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F")
	if(!real_name)	real_name = random_unique_name(gender)
	be_random_name	= sanitize_integer(be_random_name, 0, 1, initial(be_random_name))
	be_random_body	= sanitize_integer(be_random_body, 0, 1, initial(be_random_body))
	gender			= sanitize_gender(gender)
	if(gender == MALE)
		hair_style			= sanitize_inlist(hair_style, hair_styles_male_list)
		facial_hair_style			= sanitize_inlist(facial_hair_style, facial_hair_styles_male_list)
		underwear		= sanitize_inlist(underwear, underwear_m)
		undershirt 		= sanitize_inlist(undershirt, undershirt_m)
	else
		hair_style			= sanitize_inlist(hair_style, hair_styles_female_list)
		facial_hair_style			= sanitize_inlist(facial_hair_style, facial_hair_styles_female_list)
		underwear		= sanitize_inlist(underwear, underwear_f)
		undershirt		= sanitize_inlist(undershirt, undershirt_f)
	socks			= sanitize_inlist(socks, socks_list)
	age				= sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))
	hair_color			= sanitize_hexcolor(hair_color, 3, 0)
	facial_hair_color			= sanitize_hexcolor(facial_hair_color, 3, 0)
	eye_color		= sanitize_hexcolor(eye_color, 3, 0)
	skin_tone		= sanitize_inlist(skin_tone, skin_tones)
	backbag			= sanitize_integer(backbag, 1, backbaglist.len, initial(backbag))
	features["mcolor"]	= sanitize_hexcolor(features["mcolor"], 3, 0)
	features["tail_lizard"]	= sanitize_inlist(features["tail_lizard"], tails_list_lizard)
	features["tail_human"] 	= sanitize_inlist(features["tail_human"], tails_list_human, "None")
	features["snout"]	= sanitize_inlist(features["snout"], snouts_list)
	features["horns"] 	= sanitize_inlist(features["horns"], horns_list)
	features["ears"]	= sanitize_inlist(features["ears"], ears_list, "None")
	features["frills"] 	= sanitize_inlist(features["frills"], frills_list)
	features["spines"] 	= sanitize_inlist(features["spines"], spines_list)
	features["body_markings"] 	= sanitize_inlist(features["body_markings"], body_markings_list)

	userandomjob	= sanitize_integer(userandomjob, 0, 1, initial(userandomjob))
	job_civilian_high = sanitize_integer(job_civilian_high, 0, 65535, initial(job_civilian_high))
	job_civilian_med = sanitize_integer(job_civilian_med, 0, 65535, initial(job_civilian_med))
	job_civilian_low = sanitize_integer(job_civilian_low, 0, 65535, initial(job_civilian_low))
	job_medsci_high = sanitize_integer(job_medsci_high, 0, 65535, initial(job_medsci_high))
	job_medsci_med = sanitize_integer(job_medsci_med, 0, 65535, initial(job_medsci_med))
	job_medsci_low = sanitize_integer(job_medsci_low, 0, 65535, initial(job_medsci_low))
	job_engsec_high = sanitize_integer(job_engsec_high, 0, 65535, initial(job_engsec_high))
	job_engsec_med = sanitize_integer(job_engsec_med, 0, 65535, initial(job_engsec_med))
	job_engsec_low = sanitize_integer(job_engsec_low, 0, 65535, initial(job_engsec_low))

	S["mutant_tail"]		>> mutant_tail
	S["mutant_wing"]		>> mutant_wing
	S["wingcolor"]			>> wingcolor
	S["special_color"]		>> special_color
	S["be_taur"]			>> be_taur
	S["character_size"]		>> character_size
	S["vore_ability"]		>> vore_ability
	S["vore_banned_methods"]>> vore_banned_methods
	S["vore_extra_bans"]	>> vore_extra_bans
	S["p_cock"]				>> p_cock
	S["p_vagina"]			>> p_vagina
	mutant_tail 	= sanitize_text(mutant_tail, initial(mutant_tail))
	mutant_wing 	= sanitize_text(mutant_wing, initial(mutant_wing))
	wingcolor		= sanitize_hexcolor(wingcolor, 3, 0)
	special_color	= sanitize_colour_list(special_color)
	be_taur			= sanitize_integer(be_taur, 0, 1, initial(be_taur))
	character_size 	= sanitize_text(character_size, initial(character_size))
	vore_ability=sanitize_vore_list(vore_ability)
	if(isnull(vore_banned_methods))
		vore_banned_methods=0
	if(isnull(vore_extra_bans))
		vore_extra_bans=65535
	if(isnull(p_vagina))
		p_vagina=gender==FEMALE
	if(isnull(p_cock))
		p_cock=list("has"=gender==MALE,"type"="human","color"="900")

	return 1

/datum/preferences/save_character()
	if(!path)				return 0
	var/savefile/S = new /savefile(path)
	if(!S)					return 0
	S.cd = "/character[default_slot]"

	S["version"]			<< SAVEFILE_VERSION_MAX	//load_character will sanitize any bad data, so assume up-to-date.

	//Character
	S["OOC_Notes"]			<< metadata
	S["real_name"]			<< real_name
	S["name_is_always_random"] << be_random_name
	S["body_is_always_random"] << be_random_body
	S["gender"]				<< gender
	S["age"]				<< age
	S["hair_color"]			<< hair_color
	S["facial_hair_color"]	<< facial_hair_color
	S["eye_color"]			<< eye_color
	S["skin_tone"]			<< skin_tone
	S["hair_style_name"]	<< hair_style
	S["facial_style_name"]	<< facial_hair_style
	S["underwear"]			<< underwear
	S["undershirt"]			<< undershirt
	S["socks"]				<< socks
	S["backbag"]			<< backbag
	S["species"]			<< pref_species.id
	S["feature_mcolor"]					<< features["mcolor"]
	S["feature_lizard_tail"]			<< features["tail_lizard"]
	S["feature_human_tail"]				<< features["tail_human"]
	S["feature_lizard_snout"]			<< features["snout"]
	S["feature_lizard_horns"]			<< features["horns"]
	S["feature_human_ears"]				<< features["ears"]
	S["feature_lizard_frills"]			<< features["frills"]
	S["feature_lizard_spines"]			<< features["spines"]
	S["feature_lizard_body_markings"]	<< features["body_markings"]
	S["clown_name"]			<< custom_names["clown"]
	S["mime_name"]			<< custom_names["mime"]
	S["ai_name"]			<< custom_names["ai"]
	S["cyborg_name"]		<< custom_names["cyborg"]
	S["religion_name"]		<< custom_names["religion"]
	S["deity_name"]			<< custom_names["deity"]

	//Jobs
	S["userandomjob"]		<< userandomjob
	S["job_civilian_high"]	<< job_civilian_high
	S["job_civilian_med"]	<< job_civilian_med
	S["job_civilian_low"]	<< job_civilian_low
	S["job_medsci_high"]	<< job_medsci_high
	S["job_medsci_med"]		<< job_medsci_med
	S["job_medsci_low"]		<< job_medsci_low
	S["job_engsec_high"]	<< job_engsec_high
	S["job_engsec_med"]		<< job_engsec_med
	S["job_engsec_low"]		<< job_engsec_low

	S["mutant_tail"]		<< mutant_tail
	S["mutant_wing"]		<< mutant_wing
	S["wingcolor"]			<< wingcolor
	S["special_color"]		<< special_color
	S["be_taur"]			<< be_taur
	S["vore_ability"]		<< vore_ability
	S["vore_banned_methods"]<< vore_banned_methods
	S["vore_extra_bans"]	<< vore_extra_bans
	S["character_size"]		<< character_size
	S["p_cock"]				<< p_cock
	S["p_vagina"]			<< p_vagina

	return 1

#undef SAVEFILE_VERSION_MAX
#undef SAVEFILE_VERSION_MIN