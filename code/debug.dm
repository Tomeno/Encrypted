
/datum
	verb/Debug()
		set src in world
		var/varname = input("Choose a variable","Debug") in src.vars
		if(istype(src.vars[varname],/list))
			world << "Displaying items in list \"[varname]\""
			for(var/a in src.vars[varname])
				if(istype(a, /datum/))
					var/datum/b = a
					b.Debug()
				else
					world << a
		else if(istype(src.vars[varname],/datum))
			var/datum/d = src.vars[varname]
			d.Debug()
		else
			world << src.vars[varname]
