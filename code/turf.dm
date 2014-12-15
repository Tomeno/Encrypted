/turf
	var/oxy = 0
	var/nitro = 0
	var/carb = 0
	var/nitroxy = 0

	proc/process()
		for(var/turf/T in oview(1, src))
			if(!T.density)
				var/oxychange = (src.oxy-T.oxy)/2
				var/nitrochange = (src.nitro-T.nitro)/2
				var/carbchange = (src.carb-T.carb)/2
				var/nitroxychange = (src.nitroxy-T.nitroxy)/2
				src.oxy -= oxychange
				src.nitro -= nitrochange
				src.carb -= carbchange
				src.nitroxy -= nitroxychange
				T.oxy += oxychange
				T.nitro += nitrochange
				T.carb += carbchange
				T.nitroxy += nitroxychange

	proc/pressure()
		return src.oxy + src.nitro + src.carb + src.nitroxy


/turf/floor
	icon = 'floor.dmi'
	oxy = 22.286
	nitro = 79.014

/turf/floor/tile
	icon_state = "tile"

/turf/floor/ctile
	icon_state = "ctile"

/turf/wall
	icon = 'wall.dmi'
	density = 1
	opacity = 1

/turf/wall/metal
	icon_state = "metal"