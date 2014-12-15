/obj/door
	icon = 'objects.dmi'
	icon_state = "door"
	density = 1
	opacity = 1

	var/code = "mirror"
	var/owner = ""

	DblClick()
		var/input = input("Enter the password:") as text
		if(input == src.code)
			flick("dooropening", src)
			icon_state = "dooropen"
			opacity = 0
			density = 0
			spawn(40)
				flick("doorclosing", src)
				density = 1
				opacity = 1
				icon_state = "door"

	Bump(var/mob/M)
		if(M.client.ckey == src.owner)
			flick("dooropening", src)
			icon_state = "dooropen"
			opacity = 0
			density = 0
			spawn(40)
				flick("doorclosing", src)
				density = 1
				opacity = 1
				icon_state = "door"

