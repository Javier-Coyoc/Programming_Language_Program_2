module main

//Command types that can be entered 
enum DrawCommandType {
	cmd_grid
	cmd_bar
	cmd_line
	cmd_fill
}

struct DrawCommand {
	name   string 
	coord1 string 
	coord2 string
	param  string 
}

