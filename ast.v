module main

// converts letters inputted from a-j into numbers based on their positions (ex a = 1, b = 2)
fn parse_x_val(ch u8) int {
	//check if the inputted char is between a and j 
	if ch >= `a` && ch <= `j` {
		//subtract the character from 'a' ASCII value (96) 
		//example: ch = b (97) -> b (97) - a (96) = 1 + 1 = 2, so b = 2
		return int(ch - `a`) + 1
	}
	return 0
}

//Command types that can be entered 
enum DrawCommandType {
	cmd_grid
	cmd_bar
	cmd_line
	cmd_fill
}

struct DrawCommand {
	cmd DrawCommandType
	x1  int
	y1  int
	x2  int
	y2  int 
}