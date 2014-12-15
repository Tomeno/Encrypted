task
	var/file/file
	var/obj/electronic/computer/master
	var/list/var_list = new

	New(var/obj/electronic/computer/master, var/file/file, var/list/args)
		src.master = master
		src.file = file
		var/list/l = list()
		for(var/i=1; i<=args.len; i++)
			l[num2text(i)] = args[i]
		src.var_list["arg"] = l
		src.var_list["input"] = list()
		src.var_list["null"] = null
		src.var_list["semi"] = ";"
		src.var_list["newline"] = "\n"

	Del()
		master.tasks -= src
		..()
	proc
		execute()
			if(src.file.ext == "text")
				var/list/lines = dd_text2list(src.file.data, "\n")
				for(var/line in lines)
					var/list/commands = dd_text2list(line, ";")
					for(var/command in commands)
						if(command)
							var/list/args_s = dd_text2list(command, " ")
							master.sh.command(args_s.Copy(1,2)[1], args_s.Copy(2, args_s.len+1), master)
				master.tasks -= src
				del src
			if(src.file.ext == "excode")
				var/file/file = src.file
				var/counter = 0
				for(file.line_ptr=1, file.line_ptr<=file.code.len, file.line_ptr++)
					var/ex_command/cmd = file.code[num2text(file.line_ptr)]
					cmd.master = src
					cmd.execute()
					if(counter == 1000)
						sleep(1)
						counter = 0
					counter++
				master.tasks -= src
				del src
		echo(var/text)
			master.show(text)