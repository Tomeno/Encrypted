/obj/sign
	icon = 'signs.dmi'
	density = 1
	var/info = "Empty Lab"

	New()
		..()
		src.overlays += /obj/r_sign
		src.overlays += /obj/l_sign
		//initiate_maptext(src, -32,9,90,0)
		MapText(src, "<small>[src.info]", "#006600", 1, "#000000")

/obj/r_sign
	icon = 'signs.dmi'
	icon_state = "r_sign"
	pixel_x = 32

/obj/l_sign
	icon = 'signs.dmi'
	icon_state = "l_sign"
	pixel_x = -32