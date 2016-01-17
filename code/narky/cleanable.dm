/obj/effect/decal/cleanable/sex
	name = "mysterious stain"
	desc = "A puddle of hot, sticky spooge."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/juice.dmi'
	var/viruses = list()

/obj/effect/decal/cleanable/sex/Destroy()
	for(var/datum/disease/D in viruses)
		D.cure(0)
	viruses = null
	return ..()

/obj/effect/decal/cleanable/sex/semen
	name = "semen"
	desc = "A puddle of hot, sticky spooge."
	icon_state = "semen1"
	random_icon_states = list("semen1", "semen2", "semen3")

/obj/effect/decal/cleanable/sex/femjuice
	name = "femjuice"
	desc = "A puddle of warm fem-cum. Someone got excited."
	icon_state = "fem1"
	random_icon_states = list("fem1", "fem2", "fem3")

/obj/effect/decal/cleanable/sex/milk
	name = "breast milk"
	desc = "A puddle of warm breast-milk."
	icon_state = "milk1"
	random_icon_states = list("milk1", "milk2", "milk3")

/obj/effect/decal/cleanable/lemonjuice
	name = "lemon juice"
	desc = "A puddle of lemon juice."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/juice.dmi'
	icon_state = "lemon1"
	random_icon_states = list("lemon1", "lemon2", "lemon3")

/obj/effect/decal/remains/vore
	desc = "They look like the remains of someone that was digested."
	icon = 'icons/effects/juice.dmi'
	icon_state = "remainsvore"

/proc/sex_splatter(target, var/mob/living/donor, var/juice_type)
	var/decal_type = /obj/effect/decal/cleanable/sex
	if (juice_type == "semen")
		decal_type = /obj/effect/decal/cleanable/sex/semen
	else if (juice_type == "femjuice")
		decal_type = /obj/effect/decal/cleanable/sex/femjuice
	else if (juice_type == "milk")
		decal_type = /obj/effect/decal/cleanable/sex/milk
	else
		return null

	var/obj/effect/decal/cleanable/sex/S = null
	var/turf/T = get_turf(target)

	for(var/obj/effect/decal/cleanable/sex/dirty in donor.loc)
		if (istype(dirty, decal_type))
			S = dirty
			break
	if (!S)
		S = new decal_type(T)
		S.loc = donor.loc

	var/data = list()
	data["adjective"] = kpcode_get_adjective(donor)
	data["type"] = kpcode_get_generic(donor)
	if(istype(donor,/mob/living/carbon))
		var/mob/living/carbon/M = donor
		data["donor_DNA"] = M.dna
		data["viruses"] = spreadViruses(M.viruses)
		S.viruses = spreadViruses(M.viruses)
		S.blood_DNA = M.dna.unique_enzymes
	S.reagents.add_reagent(juice_type, 5, data)

	return S

/proc/spreadViruses(var/list/viruses)
	var/list/spread = list()
	for (var/datum/disease/V in viruses)
		if (!(V.spread_flags & SPECIAL || V.spread_flags & NON_CONTAGIOUS))
			spread += V.Copy()
	return spread