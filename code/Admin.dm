mob/var/mute=0
mob/Login()
	if(src.key in Admins)
		src.verbs += typesof(/mob/Admin/verb)
		winset(src, "admin_menu", "is-disabled=false")
	..()
var
	AdminSave=new/savefile("Admins.sav")
	list
		Admins = list("Lcooper", "CapitaineGaldor", "W12W", "Tomeno", "NoscopeToolbox")
		TempAdmins = list()
		SavedAdmins = list()
world
	New()
		..()
		AdminSave["Admins"] >> SavedAdmins
	Del()
		AdminSave["Admins"] << SavedAdmins
		..()

mob
	proc
		ip_ban(mob/M,n as num)
			var/a = "[M.client.address]"
			if(n != 1)
				switch(alert("Are you sure you want to ban [a]?","Ban [M.name]","Yes","No"))
					if("Yes")
						var/F = new/savefile("EasyBan.sav")
						F["BanListA"] >> BanListA
						BanListA += a
						F["BanListA"] << BanListA
						world << "[src] IP banned [M.name]"
						del(M)
			else
				var/F = new/savefile("EasyBan.sav")
				F["BanListA"] >> BanListA
				BanListA += a
				F["BanListA"] << BanListA
				world << "[src] IP banned [M.name]"
				del(M)

		key_ban(mob/M,n as num)
			var/a = M.key
			if(n != 1)
				switch(alert("Really ban [M.key]?","Ban [M.name]","Yes","No"))
					if("Yes")
						var/F = new/savefile("EasyBan.sav")
						F["BanListK"] >> BanListK
						BanListK += a
						F["BanListK"] << BanListK
						world << "[src] key banned [M.name]"
						del(M)
			else
				var/F = new/savefile("EasyBan.sav")
				F["BanListK"] >> BanListK
				BanListK += a
				F["BanListK"] << BanListK
				world << "[src] key banned [M.name]"
				del(M)
		full_ban(mob/M)
			switch(alert("Really ban [M.key]/[M.name]","Ban","Yes","No"))
				if("Yes")
					key_ban(M,1)
					ip_ban(M,1)
		un_ban()
			var/F = new/savefile("EasyBan.sav")
			F["BanListK"] >> BanListK
			F["BanListA"] >> BanListA
			UnBanListA = list()
			UnBanListK = list()
			UnBanListA += BanListA
			UnBanListK += BanListK
			switch(alert("Key or IP?",,"Key","IP"))
				if("Key")
					var/a=input("Who do you want to unban?") in UnBanListK
					switch(alert("Unban [a]?",,"Yes","No"))
						if("Yes")
							BanListK -= a
				if("IP")
					var/a=input("Who do you want to unban?") in UnBanListK
					switch(alert("Unban [a]?",,"Yes","No"))
						if("Yes")
							BanListA -= a
			F["BanListK"] << BanListK
			F["BanListA"] << BanListA
		Kick(mob/M as mob in world)
			if(!M.key)return
			switch(alert("Really kick [M]?",,"Yes","No"))
				if("Yes")
					world << "[src] kicked [M]"
					del M
				if("No")
					return
		Mute(mob/M as mob in world)
			if(!M.key)return
			switch(alert("Really mute [M]?",,"Yes","No"))
				if("Yes")
					src.mute=1
					world << "[src] muted [M]"
				if("No")
					return
		UnMute(mob/M as mob in world)
			if(!M.key)return
			switch(alert("Really un-mute [M]?",,"Yes","No"))
				if("Yes")
					src.mute=0
					world << "[src] un-muted [M]"
				if("No")
					return
		AddGM(mob/M as mob in world)
			if(!M.key)return
			switch(alert("Really make [M] an admin?",,"Yes","No"))
				if("Yes")
					switch(alert("Temporary, or permanent(can be removed)",,"Temporary","Permanent"))
						if("Temporary")
							TempAdmins += "[src.key]"
							src.verbs += typesof(/mob/Admin/verb)
						if("Permanent")
							SavedAdmins += "[src.key]"
							src.verbs += typesof(/mob/Admin/verb)
proc
	rb()
		if(rb>1)
			if(rb<=10) world << "Rebooting in [rb]."
			rb--
			spawn(10) rb()
		else if(rb==1)
			world.Reboot()
	sd()
		if(sd>1)
			if(sd<=10) world << "Shutting down in [sd]."
			sd--
			spawn(10) sd()
		if(sd==1)
			shutdown()
var
	rb=0
	sd=0
	list
		BanListA = list()
		BanListK = list()
		UnBanListA = list()
		UnBanListK = list()
mob/Login()
	..()
	var/F = new/savefile("EasyBan.sav")
	F["BanListK"] >> BanListK
	F["BanListA"] >> BanListA
	//spawn(50) Ban()//Strange bug occuring temporarily disabled
mob/proc/Ban()
	if(BanListA.Find("[src.client.address]"))
		src << "You can't login, your banned!"
		del(src)
	if(BanListK.Find(src.key))
		src << "You can't login, your banned!"
		del(src)
	..()

mob/Admin/verb
	ipban(mob/M as mob in world)
		set name = "Ban IP"
		ip_ban(M)
	keyban(mob/M as mob in world)
		set name = "Ban Key"
		key_ban(M)
	fullban(mob/M as mob in world)
		set name = "Full Ban"
		full_ban(M)
	unban()
		set name = "Unban"
		un_ban()
	kick(mob/M as mob in world)
		set name = "Kick Player"
		Kick(M)
	mute(mob/M as mob in world)
		set name = "Mute Player"
		Mute(M)
	unmute(mob/M as mob in world)
		set name = "Un-mute Player"
		UnMute(M)
	pagemaker()
		var/a=input("Send what message to Lcooper?") as text
		switch(input("Send message \"[a]\" to Lcooper?") in list("Yes","No"))
			if("No")
				return
		src.client.SendPage(a,"Lcooper","summon=1")
	emailmaker()
		var/a=input("Send what message to Lcooper?") as text
		switch(input("Send message \"[a]\" to Lcooper?") in list("Yes","No"))
			if("No")
				return
		src.client.SendPage(a,"Lcooper","email=1,subject=Encrypted")
	pagedevg()
		var/a=input("Send what message to CapitaineGaldor?") as text
		switch(input("Send message \"[a]\" to CapitaineGaldor?") in list("Yes","No"))
			if("No")
				return
		src.client.SendPage(a,"CapitaineGaldor","summon=1")
	emaildevg()
		var/a=input("Send what message to CapitaineGaldor?") as text
		switch(input("Send message \"[a]\" to CapitaineGaldor?") in list("Yes","No"))
			if("No")
				return
		src.client.SendPage(a,"CapitaineGaldor","email=1,subject=Encrypted")
	rebootworld()
		switch(input("When do you want the world to reboot?") in list("Now","Timed","Cancel"))
			if("Now")
				world << "[src] is rebooting the world!"
				world.Reboot()
			if("Timed")
				rb=input("How many seconds until reboot?") as num
				spawn(10) rb()
	admingps()
		for(var/mob/M in world)
			src << "[M.ckey] | X:[M.x] Y:[M.y] Z:[M.z]"

	cancelreboot()
		rb=0
		src << "Reboot canceled."
	shutdownworld()
		switch(input("When do you want the world to shutdown?") in list("Now","Timed","Cancel"))
			if("Now")
				world << "[src] is shutting down the world!"
				shutdown()
			if("Timed")
				sd=input("How many seconds until shutdown?") as num
				spawn(10) sd()
	cancelshutdown()
		sd=0
		src << "Shutdown canceled."