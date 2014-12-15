/obj/electronic/computer
	var/output = "desktop_output"
	var/tab = "desktop"
	icon = 'computer.dmi'
	density = 1
	icon_state = "off"

	var/list/active_users = list() //List of users using the computer.
	var/state = "off" //The current state of the computer.
	var/fs/fs = new /fs()
	var/shell/sh
	var/list/tasks = list()
	var/list/env = list()
	var/lock = 0
	var/err_level
	ports = new/list(2)

	verb/operate() //Verb to use the computer.
		set src in oview(1)
		var/mob/M = usr
		M << output(null, "output2")
		winset(M, "terminal", "is-visible=true")
		winset(M, "input2", "focus=true")
		winset(M, "tab1", "tabs=[src.tab]")
		src.icon_state = "on"
		src.state = "on"
		if(M.using != null) //If the user was using a computer previous to this one, remove them from the previous computer's active_users list.
			var/obj/electronic/computer/prevcomputer = M.using
			for(var/mob/U in prevcomputer.active_users)
				if(U == M)
					prevcomputer.active_users -= U
			if(length(prevcomputer.active_users) == 0 /*&& prevcomputer.icon_state == "active"*/)
				prevcomputer.icon_state = "on"
		if(!(M in src.active_users))
			src.active_users += usr
		M.using = src


	verb/turn_on()
		set src in oview(1)
		if(src.state == "off")
			src.icon_state = "on"
			src.state = "on"

	verb/turn_off()
		set src in oview(1)
		for(var/mob/M in src.active_users) //Shuts down the computer, removes everyone from the active_users list, etc.
			if(M.using == src)
				M.using = null
				winset(M, "input2", "focus=true")
		src.active_users = null
		src.icon_state = "off"
		src.state = "off"
		for(var/task/task in src.tasks)
			del task
		src.lock = 0

	verb/label()
		set src in oview(1)
		src.desc = input("Enter a label:") as text

	proc/show(var/text)
		src.active_users << output("\icon[src]  [text]", "[src.output]")

	proc/command(var/cmd, var/silent = 0)
		if(src.state == "off")
			return
		if(src.lock)
			var/list/l = list()
			l["1"] = cmd
			for(var/task/t in src.tasks)
				t.var_list["input"] = l
			return
		lock = 1
		src.show("> [cmd]")
		var/list/commands = dd_text2list(cmd, ";")
		for(var/command in commands)
			var/list/args_s = dd_text2list(command, " ")
			src.sh.command(args_s.Copy(1,2)[1], args_s.Copy(2, args_s.len+1), src)
		lock = 0


	receive(var/obj/packet/packet)
		if(src.state != "off")
			var/file/file = src.fs.fp2f("/usr/packet[packet.id].scr")
			if(file)
				var/list/argms = list(packet.source, packet.dest, packet.id, packet.data)
				var/task/task = new /task(src, file, argms)
				src.tasks += task
				spawn() task.execute()
				del packet
			else
				var/folder/folder = src.fs.dp2d("/tmp")
				file = src.fs.fp2f("/tmp/packet[packet.id].dat")
				if(file) del file
				file = folder.makefile("packet[packet.id].dat")
				file.data = "[packet.source]:[packet.dest]:[packet.id]:[packet.data]"
		del packet

	New()
		..()
		src.sh = computer_shell
		src.env["path"] = "/bin"

/obj/electronic/computer/signal
	var/e_key = 0
	receive(var/obj/packet/packet)
		if(src.state != "off")
			var/file/file = src.fs.fp2f("/usr/packet[packet.id].scr")
			if(file)
				var/list/argms = list(packet.source, packet.dest, packet.id, packet.data)
				var/task/task = new /task(src, file, argms)
				src.tasks += task
				spawn() task.execute()
				del packet
			else
				var/folder/folder = src.fs.dp2d("/tmp")
				file = src.fs.fp2f("/tmp/packet[packet.id].dat")
				if(file) del file
				file = folder.makefile("packet[packet.id].dat")
				file.data = "[packet.source]:[packet.dest]:[packet.id]:[packet.data]"

/obj/electronic/computer/signal/robot
	icon = 'robot.dmi'
	icon_state = "off"
	output = "robot_output"
	tab = "robot"
	canmove = 1
	verb/pull()
		set src in oview(1)
		usr.pulling = src
	New()
		..()
		src.sh = robot_shell
	attack()

/obj/electronic/computer/signal/laptop
	icon = 'laptop.dmi'
	icon_state = "off"
	output = "laptop_output"
	tab = "laptop"
	New()
		..()
		src.sh = laptop_shell
	attack()
	operate()
		set src in usr
		..()
	turn_off()
		set src in usr
		..()
	turn_on()
		set src in usr
		..()
	label()
		set src in usr
		..()


/obj/packet
	icon = 'packet.dmi'
	var/obj/item/wire/cur_wire = null
	var/obj/last_wire = null
	var/source = "0"
	var/dest = "0"
	var/id = "0"
	var/data = "0"
	var/func = 0
	proc/copy(var/obj/packet/packet)
		src.cur_wire = packet.cur_wire
		src.last_wire = packet.last_wire
		src.source = packet.source
		src.id = packet.id
		src.data = packet.data
		src.func = packet.func
	proc/activate(var/obj/packet/packet)
		if(packet)
			src.cur_wire = packet.cur_wire
			src.last_wire = packet.last_wire
			src.source = packet.source
			src.id = packet.id
			src.data = packet.data
			src.func = packet.func
		spawn()
			if(!cur_wire) del src
			if(istype(src.cur_wire.p1, /obj/electronic/computer) && istype(src.cur_wire.p2, /obj/electronic/computer))
				del src
			else
				if(src.cur_wire.p1 == src.last_wire)
					if(istype(src.cur_wire.p2, /obj/item/wire))
						src.Move(src.cur_wire.p2.loc)
						src.last_wire = src.cur_wire
						src.cur_wire = src.cur_wire.p2
						spawn() src.activate()
					else if(istype(src.cur_wire.p2, /obj/electronic/))
						src.Move(src.cur_wire.p2.loc)
						src.last_wire = src.cur_wire
						src.cur_wire = src.cur_wire.p2
						var/obj/electronic/e = src.cur_wire
						e.receive(src)
				else
					if(istype(src.cur_wire.p1, /obj/item/wire))
						src.Move(src.cur_wire.p1.loc)
						src.last_wire = src.cur_wire
						src.cur_wire = src.cur_wire.p1
						spawn() src.activate()
					else if(istype(src.cur_wire.p1, /obj/electronic/))
						src.Move(src.cur_wire.p1.loc)
						src.last_wire = src.cur_wire
						src.cur_wire = src.cur_wire.p1
						var/obj/electronic/e = src.cur_wire
						e.receive(src)