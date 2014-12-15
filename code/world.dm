/world
	view = "19x13"
	turf = /turf/floor/tile
	name = "Encrypted | The computer simulation game"
	hub = "lcooper.Encrypted"
/*
	New()
		spawn(10) src.process()
		..()
	proc/process()
		for(var/turf/T in world)
			if(!T.density)
				T.process()
		for(var/mob/M in world)
			var/turf/T = M.loc
			if(T.oxy >= 0.5)
				T.oxy -= 0.5
				T.carb += 0.5
			else
				M.suffocate()
		spawn() src.process()
*/