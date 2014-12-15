fs															//File system datum.
	var/folder/root
	var/folder/cd
	New()
		src.root = new /folder(name = "root")				//Initialize the file system with root directory.
		src.root.makefolder("usr")
		src.root.makefolder("bin")
		src.root.makefolder("tmp")
		src.root.makefolder("log")
		var/folder/sys = src.root.makefolder("sys")
		sys.makefolder("registry")
		src.cd = src.root
		for(var/system_file/sf in system_files)
			var/file/fn = new /file(name = sf.name)
			var/folder/dp = dp2d(sf.path)
			fn.data = sf.data
			fn.ext = sf.ext
			fn.parent = dp
			dp.files[fn.name] = fn
			if(sf.ext == "excode")
				fn.data = sf.data
				global.excode.compile(fn)



	proc/fp2d(var/path)										//File path to directory proc.
		var/folder/fd = src.cd
		var/list/path_list = dd_text2list(path, "/")
		if(!path_list[1])
			path_list.Cut(1,2)
			fd = src.root
		path_list.Cut(path_list.len)
		for(var/dir in path_list)
			if(dir == "..") fd = fd.parent
			else if(fd.folders[dir]) fd = fd.folders[dir]
			else return
		return fd
	proc/fp2f(var/path)										//File path to file proc.
		var/folder/fp = fp2d(path)
		var/list/path_list = dd_text2list(path, "/")
		if(fp)
			return fp.files[path_list[path_list.len]]
	proc/dp2d(var/path)										//Folder path to folder proc.
		var/folder/fd = src.cd
		var/list/path_list = dd_text2list(path, "/")
		if(!path_list[1])
			path_list.Cut(1,2)
			fd = src.root
		for(var/dir in path_list)
			if(!dir) continue
			if(dir == "..") fd = fd.parent
			else if(fd.folders[dir]) fd = fd.folders[dir]
			else return
		return fd

folder														//Folder datum.
	var/name
	var/list/files = new
	var/list/folders = new
	var/folder/parent
	New(var/name)
		src.parent = src
		src.name = name
	proc/makefolder(var/name)								//Add folder to src proc.
		var/folder/fn = new /folder(name = name)
		fn.parent = src
		src.folders[name] = fn
		return fn
	proc/makefile(var/name)									//Add file to src proc.
		var/file/fn = new /file(name = name)
		fn.ext = "text"
		fn.parent = src
		src.files[name] = fn
		return fn
	proc/path()												//Return path to folder as text.
		var/list/path_list = new
		var/folder/fp = src.parent
		path_list.Insert(1, src.name)
		while(fp.parent != fp)
			path_list.Insert(1, fp.name)
			fp = fp.parent
		return "/"+dd_list2text(path_list, "/")

file														//File datum.
	var/name
	var/ext
	var/data
	var/list/code
	var/list/goto_list = new
	var/line_ptr
	var/folder/parent
	New(var/name)
		src.name = name
	proc/path()												//Return path to flie as text.
		var/list/path_list = new
		var/folder/fp = src.parent
		while(fp.parent != fp)
			path_list.Insert(1, fp.name)
			fp = fp.parent
		return "/"+dd_list2text(path_list, "/")
	proc/copy()
		var/file/fn = new /file(name = src.name)
		fn.ext = src.ext
		fn.data = src.data
		fn.code = src.code
		fn.goto_list = src.goto_list
		fn.line_ptr = src.line_ptr
		fn.parent = src.parent