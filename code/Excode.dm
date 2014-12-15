var/excode/excode = new
excode
	proc
		compile(var/file/file)
			var/list/lines = dd_text2list(file.data, "\n")
			var/list/code = new
			file.ext = "excode"
			for(var/line in lines)
				var/list/params = dd_text2list(line, ";")
				switch(params[1])
					if("set")
						if(params.len == 3)
							code[num2text(code.len+1)] = new /ex_command/ex_set(params[2], params[3])
					if("echo_var")
						if(params.len == 2)
							code[num2text(code.len+1)] = new /ex_command/ex_echo(params[2])
					if("ascii")
						if(params.len == 3)
							code[num2text(code.len+1)] = new /ex_command/ex_ascii(params[2], params[3])
					if("char")
						if(params.len == 3)
							code[num2text(code.len+1)] = new /ex_command/ex_char(params[2], params[3])
					if("ckey")
						if(params.len == 3)
							code[num2text(code.len+1)] = new /ex_command/ex_ckey(params[2], params[3])
					if("copytext")
						if(params.len == 5)
							code[num2text(code.len+1)] = new /ex_command/ex_copytext(params[2], params[3], params[4], params[5])
					if("dumpfile")
						if(params.len == 3)
							code[num2text(code.len+1)] = new /ex_command/ex_dumpfile(params[2], params[3])
					if("getfile")
						if(params.len == 3)
							code[num2text(code.len+1)] = new /ex_command/ex_getfile(params[2], params[3])
					if("dumppath")
						if(params.len == 3)
							code[num2text(code.len+1)] = new /ex_command/ex_dumppath(params[2], params[3])
					if("eval")
						if(params.len == 4)
							code[num2text(code.len+1)] = new /ex_command/ex_eval(params[2], params[3], params[4])
					if("findtext")
						if(params.len == 6)
							code[num2text(code.len+1)] = new /ex_command/ex_findtext(params[2], params[3], params[4], params[5], params[6])
					if("id")
						if(params.len == 2)
							file.goto_list[params[2]] = code.len
					if("goto")
						if(params.len == 2)
							code[num2text(code.len+1)] = new /ex_command/ex_goto(params[2])
					if("if")
						if(params.len == 5)
							code[num2text(code.len+1)] = new /ex_command/ex_if(params[2], params[3], params[4], params[5])
					if("length")
						if(params.len == 3)
							code[num2text(code.len+1)] = new /ex_command/ex_length(params[2], params[3])
					if("lowertext")
						if(params.len == 3)
							code[num2text(code.len+1)] = new /ex_command/ex_lowertext(params[2], params[3])
					if("uppertext")
						if(params.len == 3)
							code[num2text(code.len+1)] = new /ex_command/ex_uppertext(params[2], params[3])
					if("md5")
						if(params.len == 3)
							code[num2text(code.len+1)] = new /ex_command/ex_md5(params[2], params[3])
					if("rand")
						if(params.len == 4)
							code[num2text(code.len+1)] = new /ex_command/ex_rand(params[2], params[3], params[4])
					if("replacetext")
						if(params.len == 5)
							code[num2text(code.len+1)] = new /ex_command/ex_replacetext(params[2], params[3], params[4], params[5])
					if("list_init")
						if(params.len == 2)
							code[num2text(code.len+1)] = new /ex_command/ex_list_init(params[2])
					if("shell")
						if(params.len == 2)
							code[num2text(code.len+1)] = new /ex_command/ex_shell(params[2])
					if("end")
						if(params.len == 2)
							code[num2text(code.len+1)] = new /ex_command/ex_end(params[2])
					if("setenv")
						if(params.len == 3)
							code[num2text(code.len+1)] = new /ex_command/ex_setenv(params[2], params[3])
					if("getenv")
						if(params.len == 3)
							code[num2text(code.len+1)] = new /ex_command/ex_getenv(params[2], params[3])

			file.code = code

ex_command
	var/task/master
	proc
		execute()
		islist(var/text)
			if(findtext(text, ":")) return 1
			return
		getlist(var/text)
			var/i = findtext(text, ":")
			return master.var_list[copytext(text, 1, i)]
		getindex(var/text)
			var/i = findtext(text, ":")
			text = parse_var(copytext(text, i+1))
			if(isnum(text))
				return num2text(text)
			return text
		parse_embedded(var/text)
			var/start = 1
			var/end
			while(start)
				start = findtext(text, "\[", start)
				if(!start) return text
				end = findtext(text, "\]", start)
				var/var_name = copytext(text, start+1, end)
				if(parse_var(var_name))
					var/v = parse_var(var_name)
					if(isnum(v)) v = num2text(v)
					text = dd_replaceText(text, "\["+var_name+"\]", v)
				if(start) start++
			return text
		parse_var(var/text)
			if(copytext(text, 1, 2) == "\"")
				return parse_embedded(copytext(text, 2))
			else
				if(islist(text))
					var/list/l = getlist(text)
					return l[getindex(text)]
				else
					return master.var_list[text]
	ex_set
		var/var_1
		var/var_2
		New(var/var_1, var/var_2)
			src.var_1 = var_1
			src.var_2 = var_2
		execute()
			if(islist(var_1))
				var/list/l = getlist(var_1)
				l[getindex(var_1)] = parse_var(var_2)
			else
				master.var_list[var_1] = parse_var(var_2)

	ex_echo
		var/var_1
		New(var/var_1)
			src.var_1 = var_1
		execute()
			master.echo(parse_var(var_1))

	ex_ascii
		var/var_1
		var/var_2
		New(var/var_1, var/var_2)
			src.var_1 = var_1
			src.var_2 = var_2
		execute()
			if(islist(var_1))
				var/list/l = getlist(var_1)
				l[getindex(var_1)] = text2ascii(parse_var(var_2))
			else
				master.var_list[var_1] = text2ascii(parse_var(var_2))

	ex_char
		var/var_1
		var/var_2
		New(var/var_1, var/var_2)
			src.var_1 = var_1
			src.var_2 = var_2
		execute()
			if(islist(var_1))
				var/list/l = getlist(var_1)
				l[getindex(var_1)] = ascii2text(text2num(parse_var(var_2)))
			else
				master.var_list[var_1] = ascii2text(text2num(parse_var(var_2)))

	ex_ckey
		var/var_1
		var/var_2
		New(var/var_1, var/var_2)
			src.var_1 = var_1
			src.var_2 = var_2
		execute()
			if(islist(var_1))
				var/list/l = getlist(var_1)
				l[getindex(var_1)] = ckey(parse_var(var_2))
			else
				master.var_list[var_1] = ckey(parse_var(var_2))

	ex_copytext
		var/var_1
		var/var_2
		var/var_3
		var/var_4
		New(var/var_1, var/var_2, var/var_3, var/var_4)
			src.var_1 = var_1
			src.var_2 = var_2
			src.var_3 = var_3
			src.var_4 = var_4
		execute()
			if(islist(var_1))
				var/list/l = getlist(var_1)
				l[getindex(var_1)] = copytext(parse_var(var_2), parse_var(var_3), parse_var(var_4))
			else
				master.var_list[var_1] = copytext(parse_var(var_2), parse_var(var_3), parse_var(var_4))

	ex_dumpfile
		var/var_1
		var/var_2
		New(var/var_1, var/var_2)
			src.var_1 = var_1
			src.var_2 = var_2
		execute()
			var/file/file = master.master.fs.fp2f(parse_var(var_2))
			if(file)
				if(islist(var_1))
					var/list/l = getlist(var_1)
					l[getindex(var_1)] = file.data
				else
					master.var_list[var_1] = file.data
			else
				master.var_list[var_1] = null

	ex_getfile
		var/var_1
		var/var_2
		New(var/var_1, var/var_2)
			src.var_1 = var_1
			src.var_2 = var_2
		execute()
			var/file/file = master.master.fs.fp2f(parse_var(var_2))
			if(istype(file, /file))
				if(islist(var_1))
					var/list/l = getlist(var_1)
					l[getindex(var_1)] = file
				else
					master.var_list[var_1] = file
			else
				master.var_list[var_1] = null

	ex_dumppath
		var/var_1
		var/var_2
		New(var/var_1, var/var_2)
			src.var_1 = var_1
			src.var_2 = var_2
		execute()
			var/file/file = parse_var(var_2)
			if(istype(file, /file))
				var/folder/folder = file.parent
				if(islist(var_1))
					var/list/l = getlist(var_1)
					l[getindex(var_1)] = folder.path()+"/[file.name]"
				else
					master.var_list[var_1] = folder.path()+"/[file.name]"
			else
				master.var_list[var_1] = null

	ex_eval
		var/var_1
		var/var_2
		var/var_3
		New(var/var_1, var/var_2, var/var_3)
			src.var_1 = var_1
			src.var_2 = var_2
			src.var_3 = var_3
		execute()
			var/v3 = parse_var(var_3)
			if(v3 == null) return
			if(istype(v3, /file/))
				var/file/f = v3
				v3 = f.data
			if(!istype(parse_var(var_1), /file/))
				if(isnum(text2num(master.var_list[var_1])))
					if(isnum(text2num(v3)))
						master.var_list[var_1] = text2num(master.var_list[var_1])
						v3 = text2num(v3)
					else
						master.var_list[var_1] = num2text(master.var_list[var_1])
				else
					master.var_list[var_1] = num2text(master.var_list[var_1])
					v3 = num2text(v3)

			switch(var_2)
				if("+=")
					if(istype(parse_var(var_1), /file/))
						var/file/f = parse_var(var_1)
						f.data += v3
					else
						if(islist(var_1))
							var/list/l = getlist(var_1)
							l[getindex(var_1)] += v3
						else
							master.var_list[var_1] += v3
				if("-=")
					if(islist(var_1))
						var/list/l = getlist(var_1)
						l[getindex(var_1)] -= v3
					else
						master.var_list[var_1] -= v3
				if("*=")
					if(islist(var_1))
						var/list/l = getlist(var_1)
						l[getindex(var_1)] *= v3
					else
						master.var_list[var_1] *= v3
				if("/=")
					if(islist(var_1))
						var/list/l = getlist(var_1)
						l[getindex(var_1)] /= v3
					else
						master.var_list[var_1] /= v3
				if("%=")
					if(islist(var_1))
						var/list/l = getlist(var_1)
						l[getindex(var_1)] = ~v3
					else
						master.var_list[var_1] %= v3
				if("&=")
					if(islist(var_1))
						var/list/l = getlist(var_1)
						l[getindex(var_1)] &= v3
					else
						master.var_list[var_1] &= v3
				if("^=")
					if(islist(var_1))
						var/list/l = getlist(var_1)
						l[getindex(var_1)] ^= v3
					else
						master.var_list[var_1] ^= v3
				if("|=")
					if(islist(var_1))
						var/list/l = getlist(var_1)
						l[getindex(var_1)] |= v3
					else
						master.var_list[var_1] |= v3
				if("~")
					if(islist(var_1))
						var/list/l = getlist(var_1)
						l[getindex(var_1)] = ~l[getindex(var_1)]
					else
						master.var_list[var_1] = ~master.var_list[var_1]
				if("<<")
					if(islist(var_1))
						var/list/l = getlist(var_1)
						l[getindex(var_1)] = l[getindex(var_1)] << v3
					else
						master.var_list[var_1] = master.var_list[var_1] << v3
				if(">>")
					if(islist(var_1))
						var/list/l = getlist(var_1)
						l[getindex(var_1)] = l[getindex(var_1)] >> v3
					else
						master.var_list[var_1] = master.var_list[var_1] >> v3

	ex_findtext
		var/var_1
		var/var_2
		var/var_3
		var/var_4
		var/var_5
		New(var/var_1, var/var_2, var/var_3, var/var_4, var/var_5)
			src.var_1 = var_1
			src.var_2 = var_2
			src.var_3 = var_3
			src.var_4 = var_4
			src.var_5 = var_5
		execute()
			if(islist(var_1))
				var/list/l = getlist(var_1)
				l[getindex(var_1)] = findtext(parse_var(var_2), parse_var(var_3), parse_var(var_4), parse_var(var_5))
			else
				master.var_list[var_1] = findtext(parse_var(var_2), parse_var(var_3), parse_var(var_4), parse_var(var_5))

	ex_goto
		var/var_1
		New(var/var_1)
			src.var_1 = var_1
		execute()
			var/file/file = master.file
			file.line_ptr = file.goto_list[var_1]

	ex_if
		var/var_1
		var/var_2
		var/var_3
		var/var_4
		New(var/var_1, var/var_2, var/var_3, var/var_4)
			src.var_1 = var_1
			src.var_2 = var_2
			src.var_3 = var_3
			src.var_4 = var_4
		execute()
			var/v1 = parse_var(var_1)
			var/v3 = parse_var(var_3)
			if(istype(v1, /file/))
				var/file/f = v1
				v1 = f.data
			if(istype(v3, /file/))
				var/file/f = v3
				v3 = f.data
			if(isnum(text2num(v1)))
				if(isnum(text2num(v3)))
					v1 = text2num(v1)
					v3 = text2num(v3)
				else
					v1 = num2text(v1)
			else
				if(isnum(text2num(v3)))
					v3 = num2text(v3)


			var/file/file = master.file
			switch(var_2)
				if("==")
					if(v1 == v3)
						file.line_ptr = file.goto_list[var_4]
				if("!=")
					if(v1 != v3)
						file.line_ptr = file.goto_list[var_4]
				if("<")
					if(v1 < v3)
						file.line_ptr = file.goto_list[var_4]
				if(">")
					if(v1 > v3)
						file.line_ptr = file.goto_list[var_4]
				if("<=")
					if(v1 <= v3)
						file.line_ptr = file.goto_list[var_4]
				if(">=")
					if(v1 >= v3)
						file.line_ptr = file.goto_list[var_4]

	ex_length
		var/var_1
		var/var_2
		New(var/var_1, var/var_2)
			src.var_1 = var_1
			src.var_2 = var_2
		execute()
			if(islist(var_1))
				var/list/l = getlist(var_1)
				l[getindex(var_1)] = length(parse_var(var_2))
			else
				master.var_list[var_1] = length(parse_var(var_2))

	ex_lowertext
		var/var_1
		var/var_2
		New(var/var_1, var/var_2)
			src.var_1 = var_1
			src.var_2 = var_2
		execute()
			if(islist(var_1))
				var/list/l = getlist(var_1)
				l[getindex(var_1)] = lowertext(parse_var(var_2))
			else
				master.var_list[var_1] = lowertext(parse_var(var_2))

	ex_uppertext
		var/var_1
		var/var_2
		New(var/var_1, var/var_2)
			src.var_1 = var_1
			src.var_2 = var_2
		execute()
			if(islist(var_1))
				var/list/l = getlist(var_1)
				l[getindex(var_1)] = uppertext(parse_var(var_2))
			else
				master.var_list[var_1] = uppertext(parse_var(var_2))

	ex_md5
		var/var_1
		var/var_2
		New(var/var_1, var/var_2)
			src.var_1 = var_1
			src.var_2 = var_2
		execute()
			if(islist(var_1))
				var/list/l = getlist(var_1)
				l[getindex(var_1)] = md5(parse_var(var_2))
			else
				master.var_list[var_1] = md5(parse_var(var_2))

	ex_rand
		var/var_1
		var/var_2
		var/var_3
		New(var/var_1, var/var_2, var/var_3)
			src.var_1 = var_1
			src.var_2 = var_2
			src.var_3 = var_3
		execute()
			if(islist(var_1))
				var/list/l = getlist(var_1)
				l[getindex(var_1)] = rand(text2num(parse_var(var_2)), text2num(parse_var(var_3)))
			else
				master.var_list[var_1] = rand(text2num(parse_var(var_2)), text2num(parse_var(var_3)))

	ex_replacetext
		var/var_1
		var/var_2
		var/var_3
		var/var_4
		New(var/var_1, var/var_2, var/var_3, var/var_4)
			src.var_1 = var_1
			src.var_2 = var_2
			src.var_3 = var_3
			src.var_4 = var_4
		execute()
			if(islist(var_1))
				var/list/l = getlist(var_1)
				l[getindex(var_1)] = dd_replaceText(parse_var(var_2), parse_var(var_3), parse_var(var_4))
			else
				master.var_list[var_1] = dd_replaceText(parse_var(var_2), parse_var(var_3), parse_var(var_4))

	ex_list_init
		var/var_1
		New(var/var_1)
			src.var_1 = var_1
		execute()
			master.var_list[var_1] = list()

	ex_shell
		var/var_1
		New(var/var_1)
			src.var_1 = var_1
		execute()
			var/list/commands = dd_text2list(parse_var(var_1), ";")
			for(var/command in commands)
				var/list/args_s = dd_text2list(command, " ")
				master.master.sh.command(args_s.Copy(1,2)[1], args_s.Copy(2), master.master)

	ex_end
		var/var_1
		New(var/var_1)
			src.var_1 = var_1
		execute()
			master.master.err_level = parse_var(var_1)
			del master

	ex_setenv
		var/var_1
		var/var_2
		New(var/var_1)
			src.var_1 = var_1
			src.var_2 = var_2
		execute()
			master.master.env[parse_var(var_1)] = parse_var(var_2)

	ex_getenv
		var/var_1
		var/var_2
		New(var/var_1)
			src.var_1 = var_1
			src.var_2 = var_2
		execute()
			master.var_list[var_1] = parse_var(var_2)