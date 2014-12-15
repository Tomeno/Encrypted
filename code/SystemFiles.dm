var/list/system_files = newlist(
	/system_file {
		name = "write.exe"
		ext = "excode"
		path = "/bin"
		data = {"
set;file;arg:"2
getfile;file_h;file
shell;"file_clear \[file\]
if;file_h;==;null;end
list_init;file_l
list_init;undo_l
set;main_index;"0
set;undo_index;"0
char;nl;"10
echo_var;"- Editing: \[file\]
echo_var;"- \[h\] to show commands.
id;wipe
set;input:"1;null
id;i_loop
if;input:"1;==;null;i_loop
if;input:"1;==;"\[h\];help
if;input:"1;==;"\[q\];stop
if;input:"1;==;"\[s\];show
if;input:"1;==;"\[z\];undo
if;input:"1;==;"\[y\];redo
if;input:"1;==;"\[c\];clear
if;input:"1;==;"\[e\];compile
if;input:"1;==;"\[debug\];debug
set;text;input:"1
echo_var;"-> \[text\]
eval;main_index;+=;"1
set;file_l:main_index;text
goto;wipe
id;help
echo_var;"\[nl\]- \[h\] to show commands.
echo_var;"- \[q\] to stop editing.
echo_var;"- \[s\] to show.
echo_var;"- \[z\] to undo.
echo_var;"- \[y\] to redo.
echo_var;"- \[c\] to clear.
echo_var;"- \[e\] to stop and compile.
goto;wipe
id;stop
if;main_index;<;"1;skip_s
set;i;"1
id;loop_q
set;text;file_l:i
eval;file_h;+=;text
if;i;==;main_index;next_q
eval;file_h;+=;nl
id;next_q
eval;i;+=;"1
if;i;<=;main_index;loop_q
id;skip_s
echo_var;"- Finished writing to \[file\]
goto;end
id;show
if;main_index;<;"1;wipe
echo_var;"- Showing
set;i;"1
id;loop_s
set;text;file_l:i
echo_var;"- \[text\]
eval;i;+=;"1
if;i;<=;main_index;loop_s
goto;wipe
id;undo
if;main_index;<;"1;wipe
set;tmp;file_l:main_index
eval;undo_index;+=;"1
set;undo_l:undo_index;tmp
set;file_l:main_index;null
eval;main_index;-=;"1
echo_var;"- Undo.
goto;wipe
id;redo
if;undo_index;<;"1;wipe
eval;main_index;+=;"1
set;tmp;undo_l:undo_index
set;file_l:main_index;tmp
set;undo_l:undo_index;null
eval;undo_index;-=;"1
echo_var;"- Redo.
goto;wipe
id;clear
set;file_l:"1;null
set;main_index;"0
echo_var;"- Cleared.
goto;wipe
id;compile
if;main_index;<;"1;skip_s
set;i;"1
id;loop_c
set;text;file_l:i
eval;file_h;+=;text
if;i;==;main_index;next_c
eval;file_h;+=;nl
id;next_c
eval;i;+=;"1
if;i;<=;main_index;loop_c
echo_var;"- Finished writing to \[file\]
shell;"run /bin/compiler.exe \[file\]
goto;end
id;debug
echo_var;"- Debug
echo_var;"- main_index = \[main_index\]
set;tmp;file_l:main_index
echo_var;"- file_l:main_index = \[tmp\]
echo_var;"- undo_index = \[undo_index\]
set;tmp;undo_l:undo_index
echo_var;"- undo_l:undo_index = \[tmp\]
goto;wipe
id;end
		"}
	},

	/system_file {
		name = "compiler.exe"
		ext = "excode"
		path = "/bin"
		data = {"
shell;"compile \[arg:"2\]
		"}
	}
)

system_file
	var/name
	var/ext
	var/path
	var/data