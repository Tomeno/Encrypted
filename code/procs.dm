proc
	replace_placeholders(var/t)
		var/t2
		t2 = dd_replacetext(t, "\[semi\]", ";")
		t2 = dd_replacetext(t2, "\[newline\]", "\n")
		return t2