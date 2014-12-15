/obj/electronic/router
	icon = 'objects.dmi'
	icon_state = "router 2"
	density = 1
	ports = new/list(7)

	var/pos = 1

	verb/disconnect()
		set src in oview(1)
		var/port = input("Choose a port to disconnect:") in list("port-1 ([(src.ports[1] ? "occupied" : "empty")])","port-2 ([(src.ports[2] ? "occupied" : "empty")])","port-3 ([(src.ports[3] ? "occupied" : "empty")])","port-4 ([(src.ports[4] ? "occupied" : "empty")])","port-5 ([(src.ports[5] ? "occupied" : "empty")])","port-func ([(src.ports[6] ? "occupied" : "empty")])","port-control ([(src.ports[7] ? "occupied" : "empty")])")
		switch(copytext(port, 1, 7))
			if("port-1")
				if(src.ports[1])
					var/obj/item/wire/p = src.ports[1]
					p.icon_state = "0-[get_dir(p.p1.loc ,p.loc)]"
					p.p2 = null
					p = null
			if("port-2")
				if(src.ports[2])
					var/obj/item/wire/p = src.ports[2]
					p.icon_state = "0-[get_dir(p.p1.loc, p.loc)]"
					p.p2 = null
					p = null
			if("port-3")
				if(src.ports[3])
					var/obj/item/wire/p = src.ports[3]
					p.icon_state = "0-[get_dir(p.p1.loc, p.loc)]"
					p.p2 = null
					p = null
			if("port-4")
				if(src.ports[4])
					var/obj/item/wire/p = src.ports[4]
					p.icon_state = "0-[get_dir(p.p1.loc, p.loc)]"
					p.p2 = null
					p = null
			if("port-5")
				if(src.ports[5])
					var/obj/item/wire/p = src.ports[5]
					p.icon_state = "0-[get_dir(p.p1.loc, p.loc)]"
					p.p2 = null
					p = null
			if("port-f")
				if(src.ports[6])
					var/obj/item/wire/p = src.ports[6]
					p.icon_state = "0-[get_dir(p.p1.loc, p.loc)]"
					p.p2 = null
					p = null
			if("port-c")
				if(src.ports[7])
					var/obj/item/wire/p = src.ports[7]
					p.icon_state = "0-[get_dir(p.p1.loc, p.loc)]"
					p.p2 = null
					p = null

	proc/redirect(var/obj/packet/packet, var/dest)
		if(packet)
			packet.last_wire = src
			var/obj/packet/newpacket
			switch(text2num(dest))
				if(0 to 19)
					packet.cur_wire = src.ports[1]
					newpacket = new /obj/packet
					newpacket.activate(packet)
				if(20 to 39)
					packet.cur_wire = src.ports[2]
					newpacket = new /obj/packet
					newpacket.activate(packet)
				if(40 to 59)
					packet.cur_wire = src.ports[3]
					newpacket = new /obj/packet
					newpacket.activate(packet)
				if(60 to 79)
					packet.cur_wire = src.ports[4]
					newpacket = new /obj/packet
					newpacket.activate(packet)
				if(80 to 99)
					packet.cur_wire = src.ports[5]
					newpacket = new /obj/packet
					newpacket.activate(packet)
				if(100)
					for(var/i=1, i<=5, i++)
						packet.cur_wire = src.ports[i]
						newpacket = new /obj/packet
						newpacket.activate(packet)
			del packet

	attack(var/mob/M, var/obj/O)
		if(istype(O,/obj/item/wire))
			var/port = input("Choose a port to connect to:") in list("port-1 ([(src.ports[1] ? "occupied" : "empty")])","port-2 ([(src.ports[2] ? "occupied" : "empty")])","port-3 ([(src.ports[3] ? "occupied" : "empty")])","port-4 ([(src.ports[4] ? "occupied" : "empty")])","port-5 ([(src.ports[5] ? "occupied" : "empty")])","port-func ([(src.ports[6] ? "occupied" : "empty")])","port-control ([(src.ports[7] ? "occupied" : "empty")])")
			if(M.wiring == null)
				var/obj/item/wire/wire = new/obj/item/wire()
				wire.icon_state = "0-[get_dir(M.loc, src.loc)]"
				wire.loc = M.loc
				wire.p1 = src
				switch(copytext(port, 1, 7))
					if("port-1")
						if(!src.ports[1])
							src.ports[1] = wire
					if("port-2")
						if(!src.ports[2])
							src.ports[2] = wire
					if("port-3")
						if(!src.ports[3])
							src.ports[3] = wire
					if("port-4")
						if(!src.ports[4])
							src.ports[4] = wire
					if("port-5")
						if(!src.ports[5])
							src.ports[5] = wire
					if("port-f")
						if(!src.ports[6])
							src.ports[6] = wire
					if("port-c")
						if(!src.ports[7])
							src.ports[7] = wire
				M.wiring = wire
			else
				M.wiring.icon_state = (get_dir(M.wiring.loc, src.loc) < get_dir(M.wiring.loc, M.wiring.p1.loc) ? "[get_dir(M.wiring.loc, src.loc)]-[get_dir(M.wiring.loc, M.wiring.p1.loc)]" : "[get_dir(M.wiring.loc, M.wiring.p1.loc)]-[get_dir(M.wiring.loc, src.loc)]")
				M.wiring.p2 = src
				switch(copytext(port, 1, 7))
					if("port-1")
						src.ports[1] = M.wiring
					if("port-2")
						src.ports[2] = M.wiring
					if("port-3")
						src.ports[3] = M.wiring
					if("port-4")
						src.ports[4] = M.wiring
					if("port-5")
						src.ports[5] = M.wiring
					if("port-f")
						src.ports[6] = M.wiring
					if("port-c")
						src.ports[7] = M.wiring
				M.wiring = null

	receive(var/obj/packet/packet)
		var/list/dest = dd_text2list(packet.dest, ".")
		if(src.pos == 1) packet.func = 1
		if(!packet.func && src.ports[6])
			packet.cur_wire = src.ports[6]
			packet.last_wire = src
			spawn() packet.activate()
			return
		if(packet.last_wire == src.ports[7])
			if(packet.id == "pos" && text2num(packet.data) >= 1 && text2num(packet.data) <= 6)
				src.pos = text2num(packet.data)
				del packet
				return
		if(dest.len >= src.pos)
			redirect(packet, "[dest[src.pos]]")
		else
			if(src.ports[7])
				packet.cur_wire = src.ports[7]
				packet.last_wire = src
				spawn() packet.activate()