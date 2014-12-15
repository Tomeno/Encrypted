/obj/gps
	icon = 'objects.dmi'
	icon_state = "gps"

	verb/gps(var/mob/M in world)
		usr << "X:[M.x] Y:[M.y] Z:[M.z]"