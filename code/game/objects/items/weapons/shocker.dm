/obj/item/weapon/melee/shocker
	name = "shocker"
	desc = "A shocker for incapacitating people with."
	icon_state = "shocker"
	item_state = "shocker"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	force = 10
	throwforce = 7
	w_class = 3
	var/charges = 10
	var/status = 0
	var/mob/foundmob = "" //Used in throwing proc.

	origin_tech = "combat=3"

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is putting the live [src.name] in \his mouth! It looks like \he's trying to commit suicide.</b>"
		return (FIRELOSS)

/obj/item/weapon/melee/shocker/update_icon()
	if(status)
		icon_state = "shocker_active"
	else
		icon_state = "shocker"

/obj/item/weapon/melee/shocker/attack_self(mob/user as mob)
	if(status && (CLUMSY in user.mutations) && prob(50))
		user << "\red You grab the [src] on the wrong side."
		user.Weaken(30)
		charges--
		if(charges < 1)
			status = 0
			update_icon()
		return
	if(charges > 0)
		status = !status
		user << "<span class='notice'>\The [src] is now [status ? "on" : "off"].</span>"
		playsound(src.loc, "sparks", 75, 1, -1)
		update_icon()
	else
		status = 0
		user << "<span class='warning'>\The [src] is out of charge.</span>"
	add_fingerprint(user)

/obj/item/weapon/melee/shocker/attack(mob/M as mob, mob/user as mob)
	if(status && (CLUMSY in user.mutations) && prob(50))
		user << "<span class='danger'>You accidentally hit yourself with the [src]!</span>"
		user.Weaken(30)
		charges--
		if(charges < 1)
			status = 0
			update_icon()
		return

	var/mob/living/carbon/human/H = M
	if(isrobot(M))
		..()
		return

	if(user.a_intent == "hurt")
		if(!..()) return
		//H.apply_effect(5, WEAKEN, 0)
		H.visible_message("<span class='danger'>[M] has been beaten with the [src] by [user]!</span>")

		user.attack_log += "\[[time_stamp()]\]<font color='red'> Beat [H.name] ([H.ckey]) with [src.name]</font>"
		H.attack_log += "\[[time_stamp()]\]<font color='orange'> Beaten by [user.name] ([user.ckey]) with [src.name]</font>"
		msg_admin_attack("[user.name] ([user.ckey]) beat [H.name] ([H.ckey]) with [src.name] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

		playsound(src.loc, "sparks", 50, 1, -1)
	else if(!status)
		H.visible_message("<span class='warning'>[M] has been prodded with the [src] by [user]. Luckily it was off.</span>")
		return

	if(status)
		H.apply_effect(10, STUN, 0)
		H.apply_effect(10, WEAKEN, 0)
		H.apply_effect(10, STUTTER, 0)
		user.lastattacked = M
		H.lastattacker = user
		if(isrobot(src.loc))
			var/mob/living/silicon/robot/R = src.loc
			if(R && R.cell)
				R.cell.use(50)
		else
			charges--
		H.visible_message("<span class='danger'>[M] has been stunned with the [src] by [user]!</span>")

		user.attack_log += "\[[time_stamp()]\]<font color='red'> Stunned [H.name] ([H.ckey]) with [src.name]</font>"
		H.attack_log += "\[[time_stamp()]\]<font color='orange'> Stunned by [user.name] ([user.ckey]) with [src.name]</font>"
		log_attack("[user.name] ([user.ckey]) stunned [H.name] ([H.ckey]) with [src.name]")

		playsound(src.loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
		if(charges < 1)
			status = 0
			update_icon()

	add_fingerprint(user)

/obj/item/weapon/melee/shocker/throw_impact(atom/hit_atom)
	. = ..()
	if (prob(50))
		if(istype(hit_atom, /mob/living))
			var/mob/living/carbon/human/H = hit_atom
			if(status)
				H.apply_effect(10, STUN, 0)
				H.apply_effect(10, WEAKEN, 0)
				H.apply_effect(10, STUTTER, 0)
				charges--

				for(var/mob/M in player_list) if(M.key == src.fingerprintslast)
					foundmob = M
					break

				H.visible_message("<span class='danger'>[src], thrown by [foundmob.name], strikes [H] and stuns them!</span>")

				H.attack_log += "\[[time_stamp()]\]<font color='orange'> Stunned by thrown [src.name] last touched by ([src.fingerprintslast])</font>"
				log_attack("Flying [src.name], last touched by ([src.fingerprintslast]) stunned [H.name] ([H.ckey])" )

/obj/item/weapon/melee/shocker/emp_act(severity)
	switch(severity)
		if(1)
			charges = 0
		if(2)
			charges = max(0, charges - 5)
	if(charges < 1)
		status = 0
		update_icon()