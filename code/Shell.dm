#define DEBUG
var/shell/computer_shell = new /shell(newlist(
	/command/shutdown,
	/command/extern,
	/command/ls,
	/command/cd,
	/command/make,
	/command/makedir,
	/command/read,
	/command/run,
//	/command/write,
	/command/delete,
	/command/delay,
	/command/root,
	/command/help,
	/command/compile,
	/command/echo,
	/command/deletedir,
	/command/processes,
	/command/back,
	/command/file_add,
	/command/file_clear,
	/command/setenv,
	/command/getenv,
	/command/rename,
	/command/copy
	)
)
var/shell/laptop_shell = new /shell(newlist(/command/e_key), computer_shell)
var/shell/robot_shell = new /shell(newlist(/command/move), laptop_shell)

shell
	var/list/commands = new

	proc
		command(var/cmd, var/list/args, var/obj/electronic/computer/master)
			if(src.commands[cmd])
				var/command/c = src.commands[cmd]
				if(c.args_len == -1 || args.len == c.args_len)
					c.execute(args, master)
				else
					master.show("ERROR: [cmd] requires [c.args_len] parameter[(c.args_len == 1 ? "" : "s")].")
			else
				var/file/f = master.fs.fp2f("[master.env["path"]]/[cmd].exe")
				if(f)
					var/task/t = new /task(master, f, list(cmd)+args)
					master.tasks += t
					t.execute()
				else
					master.show("Unknown command: [cmd]")

	proc
		add(var/list/l)
			for(var/command/c in l)
				for(var/name in c.names)
					src.commands[name] = c

	New(var/list/l, var/shell/parent)
		if(parent)
			for(var/c in parent.commands)
				src.commands[c] = parent.commands[c]
		for(var/command/c in l)
			for(var/name in c.names)
				src.commands[name] = c

command
	var/list/names
	var/args_len = 0
	var/syntax = "No syntax available."
	var/desc = "No description available."
	proc
		execute(var/list/args, var/obj/electronic/computer/master)

	shutdown
		names = list("shutdown")
		syntax = "shutdown"
		desc = "Shutdowns the computer."
		execute(var/list/args, var/obj/electronic/computer/master)
			master.show("Shutting down...")
			master.turn_off()

	extern
		names = list("extern")
		args_len = 4
		syntax = "extern \[src_id\] \[dest_id\] \[packet_id\] \[packet_data\]"
		desc = "Sends a packet to dest_id. Creates packet\[packet_id\].dat in the destination computer's /tmp folder with \[packet_data\] as the files contents."
		execute(var/list/args, var/obj/electronic/computer/master)
			var/obj/packet/packet = new/obj/packet()
			packet.source = args[1]
			packet.dest = args[2]
			packet.id = args[3]
			packet.data = dd_list2text(args.Copy(4,args.len+1), " ")
			if(istype(master, /obj/electronic/computer/signal/))
				var/obj/electronic/computer/signal/s = master
				var/obj/r = new
				r.icon = 'misc.dmi'
				r.icon_state = "radio"
				for(var/obj/electronic/antenna/a in world)
					if(a==s) continue
					if(a.e_key == s.e_key)
						missile(r, s, a)
						a.signal(packet)
				for(var/obj/electronic/computer/signal/l in world)
					if(l==s) continue
					if(l.e_key == s.e_key)
						missile(r, master, l)
						l.receive(packet)
			else
				if(packet.source == "0:1")
					packet.cur_wire = master.ports[2]
				packet.cur_wire = master.ports[1]
				packet.last_wire = master
				packet.loc = master.loc
				packet.activate()

	ls
		names = list("dir", "ls", "display")
		syntax = "ls"
		desc = "Shows all files and folders in a directory."
		execute(var/list/args, var/obj/electronic/computer/master)
			master.show("Displaying files in: /[master.fs.cd.name]")
			for(var/f in master.fs.cd.folders)
				master.show("\t[f]\t(DIR)")
			for(var/f in master.fs.cd.files)
				master.show("\t[f]")

	cd
		names = list("cd")
		args_len = 1
		syntax = "cd \[path\]"
		desc = "Changes the current directory to \[path\]."
		execute(var/list/args, var/obj/electronic/computer/master)
			if(master.fs.dp2d(args[1]))
				master.fs.cd = master.fs.dp2d(args[1])
				master.show("You are now in: [master.fs.cd.path()]")
			else
				master.show("ERROR: Invalid directory: [args[1]]")

	root
		names = list("root")
		syntax = "root"
		desc = "Changes the current directory to the root directory."
		execute(var/list/args, var/obj/electronic/computer/master)
			if(master.fs.dp2d("/"))
				master.fs.cd = master.fs.root
				master.show("You are now in: [master.fs.root.path()]")
	make
		names = list("make", "mk")
		args_len = 1
		syntax = "make \[file_name\]"
		desc = "Creates a file with name \[file_name\]."
		execute(var/list/args, var/obj/electronic/computer/master)
			var/file/f = master.fs.fp2f(args[1])
			if(f)
				master.show("ERROR: Name already taken: [args[1]]")
			else
				var/folder/folder = master.fs.fp2d(args[1])
				if(folder)
					var/list/path = dd_text2list(args[1], "/")
					var/name = path.[path.len]
					master.show("Created file: [name]")
					folder.makefile(name)
				else
					master.show("ERROR: Invalid directory.")

	makedir
		names = list("makedir", "mkdir")
		args_len = 1
		syntax = "makedir \[dir_name\]"
		desc = "Creates a directory with name \[dir_name\]."
		execute(var/list/args, var/obj/electronic/computer/master)
			if(master.fs.cd.folders[args[1]])
				master.show("ERROR: Directory already exists: [args[1]]")
			else
				master.show("Directory created: [args[1]]")
				master.fs.cd.makefolder(args[1])

	read
		names = list("read")
		args_len = 1
		syntax = "read \[file_name\]"
		desc = "Reads the text file with the name \[file_name\]."
		execute(var/list/args, var/obj/electronic/computer/master)
			var/file/f = master.fs.fp2f(args[1])
			if(f)
				if(f.ext == "text")
					master.show("[f.name]:")
					master.show("[f.data]")
				else
					master.show("Error: Invalid filetype.")
			else
				master.show("Error: Invalid filename.")
	run
		names = list("run")
		args_len = -1
		syntax = "run \[file_name\]"
		desc = "Runs the file \[file_name\]. This command halts input from the console until completion."
		execute(var/list/args, var/obj/electronic/computer/master)
			var/file/f = master.fs.fp2f(args[1])
			if(f)
				if(master.tasks.len <10)
					var/task/t = new /task(master, f, args)
					master.tasks += t
					t.execute()
				else
					master.show("ERROR: CPU overloaded!")

			else
				master.show("ERROR: Unable to find: [args[1]]")

	back
		names = list("back")
		args_len = -1
		syntax = "back \[file_name\]"
		desc = "Run the file \[file_name\] in the background. This allows input from the console."
		execute(var/list/args, var/obj/electronic/computer/master)
			var/file/f = master.fs.fp2f(args[1])
			if(f)
				if(master.tasks.len <10)
					var/task/t = new /task(master, f, args)
					master.tasks += t
					spawn() t.execute()
				else
					master.show("ERROR: CPU overloaded!")

			else
				master.show("ERROR: Unable to find: [args[1]]")

	write
		names = list("write")
		args_len = 1
		syntax = "write \[file_name\]"
		desc = "Open a prompt to write data to the file \[file_name\]."
		execute(var/list/args, var/obj/electronic/computer/master)
			var/file/f = master.fs.fp2f(args[1])
			if(f)
				f.data = input("Enter data:") as message
			else
				master.show("ERROR: [args[1]] does not exist.")

	delete
		names = list("del", "rm")
		args_len = 1
		syntax = "del \[file_name\]"
		desc = "Deletes the file \[file_name\]."
		execute(var/list/args, var/obj/electronic/computer/master)
			var/file/f = master.fs.fp2f(args[1])
			if(f)
				master.show("Deleting: [args[1]]")
				del f
			else
				master.show("ERROR: [args[1]] does not exist.")

	deletedir
		names = list("deldir", "rmdir")
		args_len = 1
		syntax = "deldir \[directory_name\]"
		desc = "Deletes the directory \[directory\]."
		execute(var/list/args, var/obj/electronic/computer/master)
			var/folder/f = master.fs.dp2d(args[1])
			if(f == master.fs.root)
				master.show("ERROR: You cannot delete the root directory.")
				return
			if(f)
				master.show("Deleting: [args[1]]")
				del f
			else
				master.show("ERROR: [args[1]] does not exist.")

	delay
		names = list("delay")
		args_len = 1
		syntax = "delay \[amount\]"
		desc = "Sleeps for \[amount\]/10 seconds."
		execute(var/list/args, var/obj/electronic/computer/master)
			master.state = "sleep"
			sleep(text2num(args[1]))
			master.state = "on"

	say
		names = list("say")
		args_len = -1
		syntax = "say \[words\]"
		desc = "Makes the computer say \[words\]."
		execute(var/list/args, var/obj/electronic/computer/master)
			if(master.desc)
				oviewers(,master) << "<b>[master] '[master.desc]'</b> says, \"[cleantext(dd_list2text(args, " ", 2))]\""
			else
				oviewers(,master) << "<b>[master]</b> says, \"[cleantext(dd_list2text(args, " ", 2))]\""
			sleep(5)

	copy
		names = list("cp", "copy")
		args_len = 2
		syntax = "copy \[file_name\] \[path\]"
		desc = "Copies the file \[file_name\] into the folder \[path\]."
		execute(var/list/args, var/obj/electronic/computer/master)
			var/file/f = master.fs.fp2f(args[1])
			var/folder/fr = master.fs.dp2d(args[2])
			if(f)
				master.show("ERROR: Unable to find: [args[1]]")
			else
				if(fr)
					var/file/newfile = new f.type
					for(var/i=1, i<=f.vars.len-4, i++)
						newfile.vars[f.vars[i]] = f.vars[f.vars[i]]
					newfile.parent = fr
					fr.files += newfile

	compile
		names = list("compile")
		args_len = 1
		syntax = "compile \[file_name\]"
		desc = "Compiles excode containing file \[file_name\] into an executable."
		execute(var/list/args, var/obj/electronic/computer/master)
			var/file/f = master.fs.fp2f(args[1])
			if(f)
				global.excode.compile(f)
				master.show("Deleting: [args[1]]")
				master.show("Executable [args[1]] compiled!")
			else
				master.show("ERROR: Unable to find: [args[1]]")

	help
		names = list("help")
		args_len = -1
		syntax = "help \[command\]"
		desc = "Shows helpful information pertaining to \[command\]."
		execute(var/list/args, var/obj/electronic/computer/master)
			if(args.len == 0)
				master.show("Please use: help \[command\] on one of these commands.")
				var/i = 0
				var/str = ""
				var/list/t_list = new
				for(var/cmd in master.sh.commands)
					var/command/c = master.sh.commands[cmd]
					var/name = c.names.Copy(1,2)[1]
					if(name in t_list)
						continue
					else
						str += name
						t_list += name
					if(i == 4)
						master.show(str)
						str = ""
						i = 0
						continue
					else
						str += "\t"
					i++
				if(str) master.show(str)
			else
				var/command/cmd = master.sh.commands[args[1]]
				if(cmd)
					master.show("Command: [args[1]]")
					master.show("Syntax: [cmd.syntax]")
					master.show("Alias: [dd_list2text(cmd.names, " ")]")
					master.show("Description: [cmd.desc]")

	move
		names = list("move")
		args_len = -1
		syntax = "move \[dir\] \[amount\]"
		desc = "Moves the robot in one of the cardinal directions \[amount\] amount of times. Directions can be: up, down, left, or right."
		execute(var/list/args, var/obj/electronic/computer/master)
			var/arg_count = args.len
			if(arg_count)
				var/loop_count = 1
				if(arg_count == 2)
					loop_count = (text2num(args[2]) > 15 ? 15 : text2num(args[2]))
				if(args[1] == "up")
					for(var/i=0, i<loop_count, i++)
						if(master.state != "off")
							step(master, NORTH)
							sleep(5)
						else
							break
				if(args[1] == "down")
					for(var/i=0, i<loop_count, i++)
						if(master.state != "off")
							step(master, SOUTH)
							sleep(5)
						else
							break
				if(args[1] == "left")
					for(var/i=0, i<loop_count, i++)
						if(master.state != "off")
							step(master, WEST)
							sleep(5)
						else
							break
				if(args[1] == "right")
					for(var/i=0, i<loop_count, i++)
						if(master.state != "off")
							step(master, EAST)
							sleep(5)
						else
							break

	echo
		names = list("echo")
		args_len = -1
		syntax = "echo \[words\]"
		desc = "Echoes \[words\] to the command line."
		execute(var/list/args, var/obj/electronic/computer/master)
			master.show(dd_list2text(args, " "))

	processes
		names = list("processes", "tasks")
		args_len = 0
		syntax = "processes"
		desc = "Shows a list of the running processes."
		execute(var/list/args, var/obj/electronic/computer/master)
			master.show("Processes:")
			for(var/task/task in master.tasks)
				master.show("\t[task.file.name]")

	file_add
		names = list("file_add")
		args_len = -1
		syntax = "file_add \[file_name\] \[data\]"
		desc = "Appends \[data\] to the file \[file_name\]."
		execute(var/list/args, var/obj/electronic/computer/master)
			var/file/f = master.fs.fp2f(args[1])
			if(f)
				f.data += dd_list2text(args.Copy(2), " ")
			else
				master.show("ERROR: [args[1]] does not exist.")

	file_clear
		names = list("file_clear")
		args_len = 1
		syntax = "file_clear \[file_name\]"
		desc = "Clears \[file_name\]."
		execute(var/list/args, var/obj/electronic/computer/master)
			var/file/f = master.fs.fp2f(args[1])
			if(f)
				f.data = ""
			else
				master.show("ERROR: [args[1]] does not exist.")

	setenv
		names = list("setenv")
		args_len = 2
		syntax = "setenv \[env_name\] \[env_value\]"
		desc = "Sets the environment variable \[env_name\] to \[env_value\]."
		execute(var/list/args, var/obj/electronic/computer/master)
			master.env[args[1]] = args[2]

	getenv
		names = list("getenv")
		args_len = -1
		syntax = "getenv \[env_name\]"
		desc = "Returns the environment variable \[env_name\]."
		execute(var/list/args, var/obj/electronic/computer/master)
			if(!args.len)
				for(var/env in master.env)
					master.show(master.show("[env] = [master.env[env]]"))
			else
				var/env = master.env[args[1]]
				if(env)
					master.show("[args[1]] = [env]")

	e_key
		names = list("e_key")
		args_len = 1
		syntax = "e_key \[number\]"
		desc = "Sets the e_key to \[number\]. Can be between 0 and 65,000."
		execute(var/list/args, var/obj/electronic/computer/master)
			var/obj/electronic/computer/signal/s = master
			s.e_key = args[1]
			s.show("Encryption key set to [args[1]]!")

	rename
		names = list("rename")
		args_len = 2
		syntax = "rename \[file_name\] \[new_file_name\]"
		desc = "Renames \[file_name\] to \[new_file_name\]."
		execute(var/list/args, var/obj/electronic/computer/master)
			var/file/f = master.fs.fp2f(args[1])
			var/file/nf = master.fs.fp2f(args[2])
			if(!f)
				master.show("ERROR: [args[1]] does not exist.")
			else
				if(istype(nf, /file/))
					master.show("ERROR: [args[2]] already exists.")
				else
					f.name = args[2]
