/obj/item/weapon/dildo
	name = "dildo"
	desc = "Floppy!"
	icon = 'icons/obj/sex.dmi'
	icon_state = "dildo"
	force = 0
	throwforce = 0
	attack_verb = list("penetrated", "probed", "slapped", "poked")

/obj/item/weapon/dildo/New()
	if(item_color == null)
		item_color = pick("r", "bl", "gr", "pr", "p", "yw", "or", "b")
	icon_state = "[icon_state][item_color]"

/obj/item/weapon/dildo/psych
	name = "psychedelic dildo"
	desc = "Now with 20% more seizures!"
	item_color = "psych"

/obj/item/weapon/dildo/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is shoving the [src.name] up \his ass! It looks like \he's trying to commit suicide!</span>")
	return(BRUTELOSS)

/obj/item/weapon/surgicaldrill/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/weapon/dildo))
		var/obj/item/weapon/drilldo/S = new /obj/item/weapon/drilldo

		if(!remove_item_from_storage(user))
			user.unEquip(src)
		user.unEquip(I)

		user.put_in_hands(S)
		user << "<span class='notice'>You impale the dildo onto the surgical drill.</span>"
		qdel(I)
		qdel(src)

/obj/item/weapon/drilldo
	name = "drilldo"
	desc = "Because a dildo just isn't enough."
	icon = 'icons/obj/sex.dmi'
	icon_state = "drilldo_0"
	force = 0
	throwforce = 0
	w_class = 3
	attack_verb = list("penetrated", "probed", "poked", "drilled")
	var/on = 0

/obj/item/weapon/drilldo/attack_self(mob/user)
	on = !on
	if(on)
		force = 0
		throwforce = 0
		icon_state = "drilldo_1"
		user << "<span class='notice'>You turn on the drilldo.</span>"
	else
		force = 0
		throwforce = 0
		icon_state = "drilldo_0"
		user << "<span class='notice'>You turn off the drilldo.</span>"

/obj/item/weapon/drilldo/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is shoving the [src.name] up \his ass! It looks like \he's trying to commit suicide!</span>")
	return(BRUTELOSS)