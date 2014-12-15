proc
	orient_wires(var/obj/item/wire/w1, var/obj/item/wire/w2)
		var/state = w1.icon_state
		if(get_dir(w1.loc, w1.p1.loc) > get_dir(w1.loc, w2.loc))
			state = "[get_dir(w1.loc, w2.loc)]-[get_dir(w1.loc, w1.p1.loc)]"
		else
			state = "[get_dir(w1.loc, w1.p1.loc)]-[get_dir(w1.loc, w2.loc)]"
		var/v1 = text2num(dd_text2list(w1.icon_state, "-")[2])
		var/v2 = text2num(dd_text2list(state, "-")[1])
		var/v3 = text2num(dd_text2list(state, "-")[2])
		if((v1^v2)+(v1^v3))
			w1.icon_state = state

/obj/item/wire
	icon = 'wire.dmi'

	var/obj/p1 = null
	var/obj/p2 = null

	attack(var/mob/M, var/obj/O)
		if(istype(O,/obj/item/wirecutters))
			if(src.p1 && istype(src.p1, /obj/item/wire))
				var/obj/item/wire/wire = src.p1
				if(copytext(wire.icon_state, 1, 2) == "0") del wire
				else wire.icon_state = "0-[get_dir(wire.loc, wire.p1.loc)]"
			if(src.p2 && istype(src.p2, /obj/item/wire))
				var/obj/item/wire/wire = src.p2
				if(copytext(wire.icon_state, 1, 2) == "0") del wire
				else wire.icon_state = "0-[get_dir(wire.loc, wire.p2.loc)]"
			del src
		else if(istype(O,/obj/item/wire))
			if(!M.wiring)
				var/obj/item/wire/wire = new/obj/item/wire()
				wire.icon_state = "0-[get_dir(M.loc, src.loc)]"
				wire.loc = M.loc
				wire.p1 = src
				if(src.p1)
					src.p2 = wire
				else
					src.p1 = wire
				orient_wires(src, wire)
				M.wiring = wire
			else
				orient_wires(M.wiring, src)
				if(M.wiring.p1)
					M.wiring.p2 = src
				else
					M.wiring.p1 = src
				if(src.p1)
					src.p2 = M.wiring
				else
					src.p1 = M.wiring
				orient_wires(src, M.wiring)
				M.wiring = null

/obj/item/wire
	icon = 'wire.dmi'
	icon_state = "coil"

	verb/stop_wiring()
		set src in usr
		usr.wiring = null