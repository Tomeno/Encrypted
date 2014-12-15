page
	var
		name
		syntax
		args
		desc

var/list/pages = newlist(
	/page {
		name = "ascii"
		syntax = "ascii;variable;char"
		args = list(
			"variable: The variable you want to dump your result to.",
			"char: The character you want to convert into a number."
		)
		desc = "The ascii function allows you to convert ascii characters into their number counterpart."
	},
	/page {
		name = "char"
		syntax = "char;variable;number"
		args = list(
			"variable: The variable you want to dump your result to.",
			"number: The number you wish to convert."
		)
		desc = "The char function allows you to convert a number into its ascii counterpart."
	},
	/page {
		name = "ckey"
		syntax = "ckey;variable;string"
		args = list(
			"variable: The variable you want to dump your result to.",
			"string: The string you want to convert."
		)
		desc = "The ckey function allows you to convert a variable into its canonical form. Eg: 'Hello World!' becomes 'helloworld'."
	},
	/page {
		name = "copytext"
		syntax = "copytext;variable;string;start;end"
		args = list(
			"variable: The variable you want to dump your result to.",
			"string: The string to cut.",
			"start: Where to start cutting.",
			"end: Where to end cutting."
		)
		desc = "The copytext function allows you to take a string, cut a portion out of it and dump the portion into another variable."
	},
	/page {
		name = "dumpfile"
		syntax = "dumpfile;variable;path"
		args = list(
			"variable: The variable you want to dump the file contents to.",
			"path: The path (location) of the file."
		)
		desc = "The dumpfile function allows you to dump the contents of a file into a variable."
	},
	/page {
		name = "dumppath"
		syntax = "dumppath;variable;file"
		args = list(
			"variable: The variable to dump the path to.",
			"file: The file handler (obtained with getfile) variable."
		)
		desc = "The dumppath function allows you to dump the path of a file handler into another variable."
	},
	/page {
		name = "echo_var"
		syntax = "echo_var;variable"
		args = list(
			"variable: The variable you want to echo."
		)
		desc = "The echo_var function allows you to easily echo the value of a variable, helpful for quick debugging."
	},
	/page {
		name = "end"
		syntax = "end;err_level"
		args = list(
			"err_level: Sets the system err_level to the given value."
		)
		desc = "The end function will terminate your program as soon as the function is called and set err_level."
	},
	/page {
		name = "eval"
		syntax = "eval;variable;operation;value"
		args = list(
			"eval;variable;operation;value",
			"operation: The mathematical operation you want to perform (listed below).",
			"value: The value you want to alter the variable with."
		)
		desc = "The eval function allows you to perform mathematical operations on a variable, you can also use it to append a string to another string. You can use +=, -=, *=, /=, %=. &=, ^=, |=, ~, <<, >>."
	},
	/page {
		name = "findtext"
		syntax = "findtext;variable;string;find;start;end"
		args = list(
			"variable: The variable to dump your result.",
			"string: The string to search.",
			"find: The string to look for.",
			"start: The starting point to look from (default: 1).",
			"end: The last point to look at (default: string.length 1)."
		)
		desc = "The findtext function allows you to return the position of the first instance of a string within another string."
	},
	/page {
		name = "getenv"
		syntax = "getenv;variable;environment_var"
		args = list(
			"variable: The variable to dump the result to.",
			"environment_var: The environment variable to get the value of."
		)
		desc = "The getenv function allows you to get the value of one of the system's environment variables. (If only a single argument is supplied a list of environment variables will be dumped into the variable given as the single argument)"
	},
	/page {
		name = "getfile"
		syntax = "getfile;variable;path"
		args = list(
			"variable: The variable to dump the file handler.",
			"path: The path to the file."
		)
		desc = "The getfile function allows you to create a file handler variable which allows you to easily write to a file using the eval function."
	},
	/page {
		name = "goto"
		syntax = "goto;id"
		args = list(
			"id: The id you wish to send your code to."
		)
		desc = "The goto function allows you to skip around your code by moving between various set id's."
	},
	/page {
		name = "id"
		syntax = "id;string"
		args = list(
			"string: The name of the id you want to set."
		)
		desc = "The id function allows you to set id's in your code to move to in various cases."
	},
	/page {
		name = "if"
		syntax = "if;variable;condition;other_variable;id"
		args = list(
			"variable: The variable or string to check",
			"condition: The conditional expression to use. (listed below)",
			"other_variable: The variable or string to check against.",
			"id: The id to go to if the condition passes."
		)
		desc = "The if function (or statement) works much like any other language, it checks one thing against another, and if the condition is met it goes to a certain id in your code. You can use ==, != , >, <, >=, <=."
	},
	/page {
		name = "length"
		syntax = "length;variable;other_variable"
		args = list(
			"variable: The variable you want to dump the length into.",
			"other_variable: The variable you want to check the length of."
		)
		desc = "The length function allows you to check the length of a string or list."
	},
	/page {
		name = "lowertext"
		syntax = "lowertext;variable;other_variable"
		args = list(
			"variable: The variable to dump your results.",
			"other_variable: The variable to change."
		)
		desc = "The lowertext function allows you to change a string into its lower-case form."
	},
	/page {
		name = "md5"
		syntax = "md5;variable;other_variable"
		args = list(
			"variable: The variable to dump the result to.",
			"other_variable: The variable to hash."
		)
		desc = "The md5 function allows you to hash a string or variable using the md5 system."
	},
	/page {
		name = "rand"
		syntax = "rand;variable;lbound;rbound"
		args = list(
			"variable: The variable to dump the result.",
			"lbound: The lowest the random number can be.",
			"rbound: The highest the random number can be."
		)
		desc = "The rand function allows you to generate a random number within a specified range."
	},
	/page {
		name = "replacetext"
		syntax = "replacetext;variable;string;needle;replacement"
		args = list(
			"variable: The variable to dump the result.",
			"string: The string to search.",
			"needle: The string to locate.",
			"replacement: The string to replace needle with."
		)
		desc = "The replacetext function allows to to find and replace a string within a string."
	},
	/page {
		name = "set"
		syntax = "set;variable;value"
		args = list(
			"variable: The variable you want to set.",
			"value; The new value of the variable."
		)
		desc = "The set function allows you to set the value of a variable."
	},
	/page {
		name = "setenv"
		syntax = "setenv;variable;value"
		args = list(
			"variable:The environment variable you want to change/add.",
			"value: The value of the variable."
		)
		desc = "The setenv function allows you to set and remove environment variable, using a value of null will remove the variable. (Note: Variables are stripped of non-standard characters excluding - and _)"
	},
	/page {
		name = "shell"
		syntax = "shell;command"
		args = list(
			"command: The command you want to execute."
		)
		desc = "The shell function allows you to execute commands directly at console-level."
	},
	/page {
		name = "uppertext"
		syntax = "uppertext;variable;other_variable"
		args = list(
			"variable: The variable you want to dump the result to.",
			"other_variable: The variable you want to change."
		)
		desc = "The uppertext function allows you to change a string into its upper-case form."
	}
)