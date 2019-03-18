/*
Chilling extracts:
	Have a unique, primarily defensive effect when
	filled with 10u plasma and activated in-hand.
*/
/obj/item/slimecross/chilling
	name = "chilling extract"
	desc = "It's cold to the touch, as if frozen solid."
	effect = "chilling"
	container_type = INJECTABLE | DRAWABLE
	icon_state = "chilling"

/obj/item/slimecross/chilling/Initialize()
	. = ..()
	create_reagents(10)

/obj/item/slimecross/chilling/attack_self(mob/user)
	if(!reagents.has_reagent("plasma",10))
		to_chat(user, "<span class='warning'>This extract needs to be full of plasma to activate!</span>")
		return
	reagents.remove_reagent("plasma",10)
	to_chat(user, "<span class='notice'>You squeeze the extract, and it absorbs the plasma!</span>")
	playsound(src, 'sound/effects/bubbles.ogg', 50, 1)
	playsound(src, 'sound/effects/glassbr1.ogg', 50, 1)
	do_effect(user)

/obj/item/slimecross/chilling/proc/do_effect(mob/user) //If, for whatever reason, you don't want to delete the extract, don't do ..()
	qdel(src)
	return

/obj/item/slimecross/chilling/grey
	colour = "grey"

/obj/item/slimecross/chilling/grey/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] produces a few small, grey cubes</span>")
	for(var/i in 1 to 3)
		new /obj/item/barriercube(get_turf(user))
	..()

/obj/item/slimecross/chilling/orange
	colour = "orange"

/obj/item/slimecross/chilling/orange/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] shatters, and lets out a jet of heat!</span>")
	for(var/turf/T in orange(get_turf(user),2))
		if(get_dist(get_turf(user), T) > 1)
			new /obj/effect/hotspot(T)
	..()

/obj/item/slimecross/chilling/purple
	colour = "purple"

/obj/item/slimecross/chilling/purple/do_effect(mob/user)
	var/area/A = get_area(get_turf(user))
	if(A.outdoors)
		to_chat(user, "<span class='warning'>[src] can't affect such a large area.</span>")
		return
	user.visible_message("<span class='notice'>[src] shatters, and a healing aura fills the room briefly.</span>")
	for(var/mob/living/carbon/C in A)
		C.reagents.add_reagent("regen_jelly",10)
	..()

/obj/item/slimecross/chilling/blue
	colour = "blue"

/obj/item/slimecross/chilling/blue/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] cracks, and spills out a liquid goo, which reforms into a mask!</span>")
	new /obj/item/clothing/mask/nobreath(get_turf(user))
	..()

/obj/item/slimecross/chilling/metal
	colour = "metal"

/obj/item/slimecross/chilling/metal/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] melts like quicksilver, and surrounds [user] in a wall!</span>")
	for(var/turf/T in orange(get_turf(user),1))
		if(get_dist(get_turf(user), T) > 0)
			new /obj/effect/forcefield/slimewall(T)
	..()

/obj/item/slimecross/chilling/yellow
	colour = "yellow"

/obj/item/slimecross/chilling/yellow/do_effect(mob/user)
	var/area/A = get_area(get_turf(user))
	user.visible_message("<span class='notice'>[src] shatters, and a the air suddenly feels charged for a moment.</span>")
	for(var/obj/machinery/power/apc/C in A)
		if(C.cell)
			C.cell.charge = min(C.cell.charge + C.cell.maxcharge/2, C.cell.maxcharge)
	..()

/obj/item/slimecross/chilling/darkpurple
	colour = "dark purple"

/obj/item/slimecross/chilling/darkpurple/do_effect(mob/user)
	var/area/A = get_area(get_turf(user))
	if(A.outdoors)
		to_chat(user, "<span class='warning'>[src] can't affect such a large area.</span>")
		return
	var/filtered = FALSE
	for(var/turf/open/T in A)
		var/datum/gas_mixture/G = T.air
		if(istype(G))
			G.assert_gas(/datum/gas/plasma)
			G.gases[/datum/gas/plasma][MOLES] = 0
			filtered = TRUE
			G.garbage_collect()
			T.air_update_turf()
	if(filtered)
		user.visible_message("<span class='notice'>Cracks spread throughout [src], and some air is sucked in!</span>")
	else
		user.visible_message("<span class='notice'>[src] cracks, but nothing happens.</span>")
	..()

/obj/item/slimecross/chilling/darkblue
	colour = "dark blue"

/obj/item/slimecross/chilling/darkblue/do_effect(mob/user)
	if(isliving(user))
		user.visible_message("<span class='notice'>[src] freezes over [user]'s entire body!</span>")
		var/mob/living/M = user
		M.apply_status_effect(/datum/status_effect/frozenstasis)
	..()

/obj/item/slimecross/chilling/silver
	colour = "silver"

/obj/item/slimecross/chilling/silver/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] crumbles into icy powder, leaving behind several emergency food supplies!</span>")
	var/amount = rand(5, 10)
	for(var/i in 1 to amount)
		new /obj/item/reagent_containers/food/snacks/rationpack(get_turf(user))
	..()

/obj/item/slimecross/chilling/bluespace
	colour = "bluespace"
	var/list/allies = list()
	var/active = FALSE

/obj/item/slimecross/chilling/bluespace/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !isliving(target) || active)
		return
	if(target in allies)
		allies -= target
		to_chat(user, "<span class='notice'>You unlink [src] with [target].</span>")
	else
		allies |= target
		to_chat(user, "<span class='notice'>You link [src] with [target].</span>")
	return

/obj/item/slimecross/chilling/bluespace/do_effect(mob/user)
	if(allies.len <= 0)
		to_chat(user, "<span class='warning'>[src] is not linked to anyone!</span>")
		return
	to_chat(user, "<span class='notice'>You feel [src] pulse as it begins charging bluespace energies...</span>")
	active = TRUE
	for(var/mob/living/M in allies)
		var/datum/status_effect/slimerecall/S = M.apply_status_effect(/datum/status_effect/slimerecall)
		S.target = user
	if(do_after(user, 100, target=src))
		to_chat(user, "<span class='notice'>[src] shatters as it tears a hole in reality, snatching the linked individuals from the void!</span>")
		for(var/mob/living/M in allies)
			var/datum/status_effect/slimerecall/S = M.has_status_effect(/datum/status_effect/slimerecall)
			M.remove_status_effect(S)
	else
		to_chat(user, "<span class='warning'>[src] falls dark, dissolving into nothing as the energies fade away.</span>")
		for(var/mob/living/M in allies)
			var/datum/status_effect/slimerecall/S = M.has_status_effect(/datum/status_effect/slimerecall)
			if(istype(S))
				S.interrupted = TRUE
				M.remove_status_effect(S)
	..()

/obj/item/slimecross/chilling/sepia
	colour = "sepia"
	var/list/allies = list()

/obj/item/slimecross/chilling/sepia/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !isliving(target))
		return
	if(target in allies)
		allies -= target
		to_chat(user, "<span class='notice'>You unlink [src] with [target].</span>")
	else
		allies |= target
		to_chat(user, "<span class='notice'>You link [src] with [target].</span>")
	return

/obj/item/slimecross/chilling/sepia/do_effect(mob/user)
	user.visible_message("<span class='warning'>[src] shatters, freezing time itself!</span>")
	new /obj/effect/timestop(get_turf(user), 2, 300, allies)
	..()

/obj/item/slimecross/chilling/cerulean
	colour = "cerulean"

/obj/item/slimecross/chilling/cerulean/do_effect(mob/user)
	if(isliving(user))
		user.visible_message("<span class='warning'>[src] creaks and shifts into a clone of [user]!</span>")
		var/mob/living/M = user
		M.apply_status_effect(/datum/status_effect/slime_clone)
	..()

/obj/item/slimecross/chilling/pyrite
	colour = "pyrite"

/obj/item/slimecross/chilling/pyrite/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] crystallizes into a pair of spectacles!</span>")
	new /obj/item/clothing/glasses/prism_glasses(get_turf(user))
	..()

/obj/item/slimecross/chilling/red
	colour = "red"

/obj/item/slimecross/chilling/red/do_effect(mob/user)
	var/slimesfound = FALSE
	for(var/mob/living/simple_animal/slime/S in view(get_turf(user), 7))
		slimesfound = TRUE
		S.docile = TRUE
	if(slimesfound)
		user.visible_message("<span class='notice'>[src] lets out a peaceful ring as it shatters, and nearby slimes seem calm.</span>")
	else
		user.visible_message("<span class='notice'>[src] lets out a peaceful ring as it shatters, but nothing happens...</span>")
	..()

/obj/item/slimecross/chilling/green
	colour = "green"

/obj/item/slimecross/chilling/green/do_effect(mob/user)
	var/which_hand = "l_hand"
	if(!(user.active_hand_index % 2))
		which_hand = "r_hand"
	var/mob/living/L = user
	if(!istype(user))
		return
	var/obj/item/held = L.get_active_held_item() //This should be itself, but just in case...
	L.dropItemToGround(held)
	var/obj/item/gun/magic/bloodchill/gun = new(user)
	if(!L.put_in_hands(gun))
		qdel(gun)
		user.visible_message("<span class='warning'>[src] flash-freezes [user]'s arm, cracking the flesh horribly!</span>")
	else
		user.visible_message("<span class='danger'>[src] chills and snaps off the front of the bone on [user]'s arm, leaving behind a strange, gun-like structure!</span>")
	user.emote("scream")
	L.apply_damage(30,BURN,which_hand)
	..()

/obj/item/slimecross/chilling/pink
	colour = "pink"

/obj/item/slimecross/chilling/pink/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] cracks like an egg, and an adorable puppy comes tumbling out!</span>")
	new /mob/living/simple_animal/pet/dog/corgi/puppy/slime(get_turf(user))
	..()

/obj/item/slimecross/chilling/gold
	colour = "gold"

/obj/item/slimecross/chilling/gold/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] lets off golden light as it melts and reforms into an egg-like device!</span>")
	new /obj/item/capturedevice(get_turf(user))
	..()

/obj/item/slimecross/chilling/oil
	colour = "oil"

/obj/item/slimecross/chilling/oil/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] begins to shake with muted intensity!</span>")
	addtimer(CALLBACK(src, .proc/boom), 50)

/obj/item/slimecross/chilling/oil/proc/boom()
	explosion(get_turf(src), -1, -1, 3, 10) //Large radius, but mostly light damage.
	qdel(src)

/obj/item/slimecross/chilling/black
	colour = "black"

/obj/item/slimecross/chilling/black/do_effect(mob/user)
	if(ishuman(user))
		user.visible_message("<span class='notice'>[src] crystallizes along [user]'s skin, turning into metallic scales!</span>")
		var/mob/living/carbon/human/H = user
		H.set_species(/datum/species/golem/random)
	..()

/obj/item/slimecross/chilling/lightpink
	colour = "light pink"

/obj/item/slimecross/chilling/lightpink/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] blooms into a beautiful flower!</span>")
	new /obj/item/clothing/head/peaceflower(get_turf(user))
	..()

/obj/item/slimecross/chilling/adamantine
	colour = "adamantine"

/obj/item/slimecross/chilling/adamantine/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] creaks and breaks as it shifts into a heavy set of armor!</span>")
	new /obj/item/clothing/suit/armor/heavy/adamantine(get_turf(user))
	..()

/obj/item/slimecross/chilling/rainbow
	colour = "rainbow"

/obj/item/slimecross/chilling/rainbow/do_effect(mob/user)
	var/area/area = get_area(user)
	if(area.outdoors)
		to_chat(user, "<span class='warning'>[src] can't affect such a large area.</span>")
		return
	user.visible_message("<span class='warning'>[src] reflects an array of dazzling colors and light, energy rushing to nearby doors!</span>")
	for(var/obj/machinery/door/airlock/door in area)
		new /obj/effect/forcefield/slimewall/rainbow(door.loc)
	return ..()
