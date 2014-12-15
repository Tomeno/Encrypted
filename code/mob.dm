proc
	cleantext(var/T)
		var/SFlag = 0
		var/C
		var/N
		for(var/i=1, i<=length(T), i++)
			C = copytext(T, i, i+1)
			if(C != " ")
				SFlag = 0
				N += C
			else
				if(SFlag == 0)
					SFlag = 1
					N += C
		return html_encode(N)

mob
	icon = 'player.dmi'
	icon_state = "default"

	var/obj/electronic/computer/using = null
	var/obj/item/wire/wiring = null
	var/obj/equipped = null
	var/obj/pulling = null

	verb
		viewplayers()
			src << "<font color=#19C1C4>-----Who's online-----<font color=#0>"
			for(var/mob/M in world)
				src <<"<font color=#0><b>[M.key]</b><font color=#0>"
				src << "<font color=#19C1C4>----------------------<font color=#0>"

		say(T as text)
			if(!src.mute)
				T = cleantext(T)
				switch(copytext(T, 1, 4))
					if("\[s\]")
						world << "\icon[src]<b>[src]</b> shouts, '[copytext(T, 4)]'"
					if("\[w\]")
						view(1) << "\icon[src]<i><b>[src]</b> whispers, '[copytext(T, 4)]'</i>"
					else
						if(T=="/who")
							viewplayers()
						else
							view() << "\icon[src]<b>[src]</b> says, '[T]'"


		shout(T as text)
			if(!src.mute)
				world << "\icon[src]<b>[src]</b> shouts, '[cleantext(T)]'"

		reference()
			winshow(src, "excode_reference")

	verb/createcomputer()
		new/obj/electronic/computer(src.loc)

	verb/command(T as text)
		set hidden = 1
		if((src.using in oview(1)) || (src.using in src))
			src.using.command(T)
		else
			src.using = null

	verb/openpanel()
		winset(src, "admin_panel", "is-visible=true")
		var/players = 0
		for(var/mob/M in world)
			winset(src, "player_grid", "current-cell=[++players]")
			src << output(M, "player_grid")

	proc/UpdateGUI()
		var/items = 0
		for(var/obj/O in src)
			winset(src, "inventory", "current-cell=[++items]")
			src << output(O, "inventory")
		winset(src, "inventory", "cells=[items]")

		var/index = 0
		for(var/page/page in global.pages)
			winset(src, "excode_links", "current-cell=[++index]")
			src << output("<b><a href='?src=\ref[src];action=[page.name]'>[page.name]</a></b>", "excode_links")
		winset(src, "excode_links", "cells=[index]")

	Topic(href,href_list[])
		for(var/page/page in global.pages)
			if(href_list["action"] == page.name)
				src << browse("<center><h2>[page.name]</h2></center><hr /><b>Syntax:</b> [page.syntax]<br /><b>Arguments:</b><ul><li>[dd_list2text(page.args, "<li>")]</ul><br /><b>Description:</b><br /><center>[page.desc]</center>", "window=excode_browser")


	Login()
		world << "<font color=#3a4ee1><b>[src.ckey]</b> has logged in.<font color=#0>"
		var/list/regulars = list("lcooper", "tomeno", "capitainegaldor", "w12w", "tarimos", "noscopetoolbox")
		if(src.ckey in regulars)
			src.icon_state = src.ckey
		..()
		if(!src.LoadProc())

			src.loc = locate(rand(20,23), rand(23,25), 1)
		winset(src, "default", "is-maximized=true")
		winset(src, "input1", "focus=true")
		new /obj/item/wire(src)
		new /obj/item/wirecutters(src)
		new /obj/electronic/computer/signal/laptop(src)
		new /obj/gps(src)
		UpdateGUI()

	Logout()
		if(!src.SaveProc())
			world << "<font color=#3a4ee1><b>[src.ckey]</b> has logged out.<font color=#0>"
			..()
			del src

		else
			src.loc = locate(rand(20,23), rand(23,25), 1)
			var/FileName="Players/[ckey(src.key)].sav"
			if(fexists(FileName))   fdel(FileName)
			var/savefile/F=new(FileName)
			F["LastX"]<<src.x
			F["LastY"]<<src.y
			F["LastY"]<<src.z

	Move()
		var/oldloc = src.loc
		..()
		if(src.pulling)
			src.pulling.Move(oldloc)
		if(src.wiring && src.wiring.loc != src.loc)
			var/obj/item/wire/wire = new/obj/item/wire()
			orient_wires(src.wiring, src)
			wire.p1 = src.wiring
			src.wiring.p2 = wire
			wire.loc = src.loc
			wire.icon_state = "0-[get_dir(wire.loc, src.wiring.loc)]"
			src.wiring = wire

	Bump(var/A)
		if(istype(A, /obj/door))
			var/obj/door/D = A
			D.Bump(src)
		if(istype(A, /obj))
			var/obj/O = A
			var/turf/T = get_step(O,get_dir(src.loc, O.loc))
			if(O.canmove && !(locate(/mob) in T) && !(locate(/obj) in T))
				O.Move(T)
			if(O == src.pulling)
				src.pulling = null

	proc
		SaveProc()
			var/FileName="save/[ckey(src.key)].sav"
			if(fexists(FileName))   fdel(FileName)
			var/savefile/F=new(FileName)
			F["LastX"]<<src.x
			F["LastY"]<<src.y
			F["LastZ"]<<src.z
			src<<"<font color=#3a4ee1>Character Saved...<font color=#0>"

		LoadProc()
			var/FileName="save/[ckey(src.key)].sav"
			if(fexists(FileName))
				var/savefile/F=new(FileName)
				src.loc=locate(F["LastX"],F["LastY"],F["LastZ"])
				src<<"<font color=#3a4ee1>Character Loaded...<font color=#0>"
				src<<"<font color=#3a4ee1>Welcome back, [src.ckey]. Enjoy your stay!"
				return 1
			else
				src << "<font color=#3a4ee1>Welcome to Encrypted, [src.ckey]. Enjoy your stay!"

	verb
		Home()
			src.loc = locate(rand(20,23), rand(23,25), 1)
			src<<"You just respawned at 'Spawn' (Center of the map)"
