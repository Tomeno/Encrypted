/obj
	var/canmove = 0
	DblClick()
		if(src in oview(1))
			src.attack(usr, usr.equipped)

	proc/attack()

/obj/item
	var/rname
	New()
		..()
		rname = src.name

	DblClick()
		..()
		if(src in usr)
			var/obj/item/equipped = usr.equipped
			if(usr.equipped == src)
				src.name = src.rname
				usr.equipped = null
			else
				if(usr.equipped)
					equipped.name = equipped.rname
				usr.equipped = src
				src.name += " \[E\]"
		usr.UpdateGUI()

/obj/electronic
	var/list/ports
	proc/receive()
	proc/wire_port(var/obj/item/wire/wire)
		for(var/i=1, i<=src.ports.len, i++)
			if(!src.ports[i])
				src.ports[i] = wire
				return
	proc/freeport()
		for(var/i=1, i<=src.ports.len, i++)
			if(!src.ports[i])
				return 1
	attack(var/mob/M, var/obj/O)
		if(istype(O,/obj/item/wire) && src.freeport())
			if(M.wiring == null)
				var/obj/item/wire/wire = new/obj/item/wire()
				wire.icon_state = "0-[get_dir(M.loc, src.loc)]"
				wire.loc = M.loc
				wire.p1 = src
				src.wire_port(wire)
				M.wiring = wire
			else
				orient_wires(M.wiring, src)
				M.wiring.p2 = src
				src.wire_port(M.wiring)
				M.wiring = null