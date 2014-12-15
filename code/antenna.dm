/obj/electronic/antenna
	var/e_key = 0
	icon = 'oldcomputer.dmi'
	icon_state = "antenna"
	density = 1
	ports = new/list(2)
	receive(var/obj/packet/packet)
		if(src.ports[2] == packet.last_wire)
			if(packet.id == "e_key")
				src.e_key = packet.data
		else
			var/obj/r = new
			r.icon = 'misc.dmi'
			r.icon_state = "radio"
			for(var/obj/electronic/antenna/a in world)
				if(a==src) continue
				if(a.e_key == src.e_key)
					missile(r, src, a)
					a.signal(packet)
			for(var/obj/electronic/computer/signal/l in world)
				if(l==src) continue
				if(l.e_key == src.e_key)
					missile(r, src, l)
					l.receive(packet)
		del packet

	proc
		signal(var/obj/packet/signal)
			if(src.ports[1])
				var/obj/packet/packet = new/obj/packet()
				packet.copy(signal)
				packet.cur_wire = src.ports[1]
				packet.last_wire = src
				packet.loc = src.loc
				packet.activate()