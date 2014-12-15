/obj/laser
	icon = 'laser.dmi'
	icon_state = "laser"

	var/obj/electronic/laserpointer/pointer = null
	var/obj/laser/master = null
	var/obj/laser/prev = null
	var/obj/laser/next = null

	proc/remove()
		if(src.next)
			src.next.remove()
		del src

	proc/propagate(var/obj/laser/first, var/obj/electronic/laserpointer/control)
		var/turf/T = get_step(src, src.dir)
		if(T && !T.density && !src.next && !(locate(/mob) in T))
			var/obj/laser/nextl = new/obj/laser()
			nextl.dir = src.dir
			nextl.loc = get_step(src, src.dir)
			nextl.prev = src
			src.next = nextl
			nextl.propagate(first, control)
		src.master = first
		src.pointer = control

/obj/electronic/laserpointer
	icon = 'laser.dmi'
	icon_state = "off"
	density = 1

	var/obj/laser/first = null
	var/obj/item/wire/port = null

	verb/turn_on()
		set src in oview(1)
		if(src.first == null)
			var/turf/T = get_step(src, src.dir)
			if(T && !T.density && !(locate(/mob) in T))
				var/obj/laser/master = new/obj/laser()
				master.dir = src.dir
				master.loc = get_step(src, src.dir)
				src.first = master
				master.propagate(master, src)
			src.icon_state = "on"
			var/o = src.renew()
			while(!o)
				o = src.renew()
				sleep(10)

	verb/turn_off()
		set src in oview(1)
		if(src.first)
			src.icon_state = "off"
			src.first.remove()

	proc/renew()
		if(src.icon_state == "on")
			if(src.first)
				return 1
			else
				var/turf/T = get_step(src, src.dir)
				if(T && !T.density && !(locate(/mob) in T))
					var/obj/laser/master = new/obj/laser()
					master.dir = src.dir
					master.loc = get_step(src, src.dir)
					src.first = master
					master.propagate(master, src)
					return 1
				else
					return 0

	proc/canmove()
		if(port)
			return 0
		else
			return 1

	proc/hit(var/dist)
		if(src.port)
			var/obj/packet/packet = new/obj/packet()
			packet.dest = "1"
			packet.id = "laserdist"
			packet.data = dist
			packet.cur_wire = src.port
			packet.last_wire = src
			packet.loc = src.loc
			spawn() packet.activate()

	attack(var/mob/M, var/obj/O)
		if(istype(O,/obj/item/wire) && src.port == null)
			if(M.wiring == null)
				var/obj/item/wire/wire = new/obj/item/wire()
				wire.icon_state = "0-[get_dir(M.loc, src.loc)]"
				wire.loc = M.loc
				wire.p1 = src
				src.port = wire
				M.wiring = wire
			else
				M.wiring.icon_state = (get_dir(M.wiring.loc, src.loc) < get_dir(M.wiring.loc, M.wiring.p1.loc) ? "[get_dir(M.wiring.loc, src.loc)]-[get_dir(M.wiring.loc, M.wiring.p1.loc)]" : "[get_dir(M.wiring.loc, M.wiring.p1.loc)]-[get_dir(M.wiring.loc, src.loc)]")
				M.wiring.p2 = src
				src.port = M.wiring
				M.wiring = null

	receive(var/obj/packet/packet)
		if(packet.id == "dir")
			if(packet.data == "NORTH")
				src.dir = NORTH
			if(packet.data == "SOUTH")
				src.dir = SOUTH
			if(packet.data == "EAST")
				src.dir = EAST
			if(packet.data == "WEST")
				src.dir = WEST
			if(src.icon_state == "on")
				src.turn_off()
				src.turn_on()
		if(packet.id == "power")
			if(packet.data == "1")
				spawn() src.turn_on()
		if(packet.id == "power")
			if(packet.data == "0")
				spawn() src.turn_off()

		del packet

	Move()
		..()
		if(src.first)
			src.first.remove()
			spawn(10) src.turn_on()