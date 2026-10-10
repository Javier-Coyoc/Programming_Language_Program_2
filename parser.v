//Main job of parser is to take the tokens that were made in the lexer.v file check if they are valid or follow the BNF rules
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

struct Parser {
mut:
	tokens	[]Token
	pos     int
	sentential_form string
}

//=======================
//	Helper Functions
//=======================
//peek looks at current token without actually moving forward 
fn (p &Parser) peek() Token {
	if p.pos >= p.tokens.len {
		return Token{kind: .eof, value: ""}
	}
	return p.tokens[p.pos]
}

// consume() checks if the token matches the grammar. If yes, it moves forward.
// If no, it throws an error (using V's `!` error return type).
fn (mut p Parser) consume(expected_kind TokenType, expected_value string) ! {
	current := p.peek()

	
	if current.kind == expected_kind && (expected_value == "" || current.value == expected_value) {
		p.pos++
	} else {
		return error("Syntax Error: Expected '${expected_value}', but got '${current.value}'")
	}
}

// Lookahead helper to check if a semicolon exists in remaining plot statements
fn (p &Parser) has_semicolon_ahead() bool {
	mut i := p.pos

	for i < p.tokens.len {
		if p.tokens[i].kind == .semicolon {
			return true
		}
		if p.tokens[i].value == 'end' || p.tokens[i].kind == .eof {
			return false
		}
		i++
	}
	return false
}

fn validate_x(x string) ! {
	if x.len == 0 || x[0] < `a` || x[0] > `j` {
		return error("Syntax Error: Invalid column coordinate '${x}'. Must be a-j.")
	}
}

// Validate row coordinate <y> is strictly between '0' and '9'
fn validate_y(y string) ! {
	if y.len == 0 || y[0] < `0` || y[0] > `9` {
		return error("Syntax Error: Invalid row coordinate '${y}'. Must be 0-9.")
	}
}

//========================
//	Recursive Functions
//========================
fn (mut p Parser) parse() ![]DrawCommand {
	// Start the chain reaction
	return p.parse_graph()
}

//Parse Graph function that reads BNF grammar input from top to bottom,expects a 'start' and 'end' keyword and between them the parse_plots
fn (mut p Parser) parse_graph() ![]DrawCommand {
	println("\n================ Starting Leftmost Derivation ================")
	p.sentential_form = "<graph>"
	println(p.sentential_form)

	//Expand <graph> -> start <plot_stmts> end
	//replace_once function removes the first instance of the 1st parameter (<graph>) and replaces it with what's in 2nd parameter
	p.sentential_form = p.sentential_form.replace_once("<graph>", "start <plot_stmts> end")
	println("=> ${p.sentential_form}")

	// Must start with 'start'
	p.consume(.keyword, "start")!
	
	// has to go to the next rule to get the commands
	commands := p.parse_plot_stmts()! 
	
	// Must end with 'end'
	p.consume(.keyword, "end")!

	//Check to see if no invalid tokens remain after end, if so return error
	if p.peek().kind != .eof {
		return error("Syntax Error: Unexpected extra tokens after 'end' keyword")
	}
	
	return commands
}

//check <plot> keyword and if it the input has any ';' which means there is another <plot_stmt>
fn (mut p Parser) parse_plot_stmts() ![]DrawCommand {
	
	mut commands := []DrawCommand{}

	// Expand <plot_stmts> based on whether another statement follows
	if p.has_semicolon_ahead() {
		p.sentential_form = p.sentential_form.replace_once("<plot_stmts>", "<plot> ; <plot_stmts>")
	} else {
		p.sentential_form = p.sentential_form.replace_once("<plot_stmts>", "<plot>")
	}
	println("=> ${p.sentential_form}")

	//Always check the first <plot> in the <plot_stmts> 
	cmd := p.parse_plot()!
	commands << cmd

	//use p.peek() to check if the next token is a ;
	if p.peek().kind == .semicolon {
		p.consume(.semicolon, ";")!

		// Recursively parse the rest of the statements and append them
		more_commands := p.parse_plot_stmts()!
		commands << more_commands
	}
		return commands
}

//main router for the <plot> grammar rule
fn (mut p Parser) parse_plot() !DrawCommand {
	current := p.peek()

	// Ensure the command starts with a keyword
	if current.kind != .keyword {
		return error("Syntax Error: expected a plot command ('bar', 'line', 'grid', 'fill'), but got '${current.value}'")
	}

	// Match the keyword to the correct parsing rule
	match current.value {
		'bar' { 
			return p.parse_bar()! }
		'line' {
			return p.parse_line()! }
		'grid' {
			return p.parse_grid()! }
		'fill' {
			return p.parse_fill()! }
		else {
			return error("Syntax Error: Unknown plot command '${current.value}'") }
	}
}

// Rule: bar <x><y>,<y>
fn (mut p Parser) parse_bar() !DrawCommand {
	p.consume(.keyword, "bar")!
	coord := p.peek()
	p.consume(.coordinate, "")!
	p.consume(.comma, ",")!
	width := p.peek()
	p.consume(.number, "")!

	if coord.value.len < 2 {
		return error("Syntax Error: Invalid coordinate '${coord.value}'")
	}

	x_char := coord.value[0..1]
	y_char := coord.value[1..2]

	validate_x(x_char)!
	validate_y(y_char)!
	validate_y(width.value)!

	p.sentential_form = p.sentential_form.replace_once("<plot>", "bar <x><y>,<y>")
	println("=> ${p.sentential_form}")

	p.sentential_form = p.sentential_form.replace_once("<x>", x_char)
	println("=> ${p.sentential_form}")

	p.sentential_form = p.sentential_form.replace_once("<y>", y_char)
	println("=> ${p.sentential_form}")

	p.sentential_form = p.sentential_form.replace_once("<y>", width.value)
	println("=> ${p.sentential_form}")

	return DrawCommand{name: "bar", coord1: coord.value, param: width.value}
}

// Rule: line <x><y>,<x><y>
fn (mut p Parser) parse_line() !DrawCommand {
	p.consume(.keyword, "line")!
	coord1 := p.peek()
	//The reason for the "" - empty quotation is because its expecting dynamic user input (we cant predict it that would be static hard-coding)
	p.consume(.coordinate, "")!
	p.consume(.comma, ",")!
	coord2 := p.peek()
	p.consume(.coordinate, "")!

	if coord1.value.len < 2 || coord2.value.len < 2 {
		return error("Syntax Error: Invalid coordinate format")
	}

	x1 := coord1.value[0..1]
	y1 := coord1.value[1..2]
	x2 := coord2.value[0..1]
	y2 := coord2.value[1..2]

	validate_x(x1)!
	validate_y(y1)!
	validate_x(x2)!
	validate_y(y2)!

	p.sentential_form = p.sentential_form.replace_once("<plot>", "line <x><y>,<x><y>")
	println("=> ${p.sentential_form}")

	// Step-by-step substitution of each non-terminal in leftmost order
	p.sentential_form = p.sentential_form.replace_once("<x>", x1)
	println("=> ${p.sentential_form}")

	p.sentential_form = p.sentential_form.replace_once("<y>", y1)
	println("=> ${p.sentential_form}")

	p.sentential_form = p.sentential_form.replace_once("<x>", x2)
	println("=> ${p.sentential_form}")

	p.sentential_form = p.sentential_form.replace_once("<y>", y2)
	println("=> ${p.sentential_form}")

	return DrawCommand{name: "line", coord1: coord1.value, coord2: coord2.value}
}

// Rule: grid <x><y>
fn (mut p Parser) parse_grid() !DrawCommand {
	p.consume(.keyword, "grid")!
	coord := p.peek()
	p.consume(.coordinate, "")!

	if coord.value.len < 2 {
		return error("Syntax Error: Invalid coordinate '${coord.value}'")
	}

	x_char := coord.value[0..1]
	y_char := coord.value[1..2]

	validate_x(x_char)!
	validate_y(y_char)!

	p.sentential_form = p.sentential_form.replace_once("<plot>", "grid <x><y>")
	println("=> ${p.sentential_form}")
	p.sentential_form = p.sentential_form.replace_once("<x>", x_char)
	println("=> ${p.sentential_form}")
	p.sentential_form = p.sentential_form.replace_once("<y>", y_char)
	println("=> ${p.sentential_form}")

	return DrawCommand{name: "grid" coord1: coord.value}
}

// Rule: fill <x><y>
fn (mut p Parser) parse_fill() !DrawCommand {
	p.consume(.keyword, "fill")!
	coord := p.peek()
	p.consume(.coordinate, "")!

	if coord.value.len < 2 {
		return error("Syntax Error: Invalid coordinate '${coord.value}'")
	}

	x_char := coord.value[0..1]
	y_char := coord.value[1..2]

	validate_x(x_char)!
	validate_y(y_char)!

	p.sentential_form = p.sentential_form.replace_once("<plot>", "fill <x><y>")
	println("=> ${p.sentential_form}")
	p.sentential_form = p.sentential_form.replace_once("<x>", x_char)
	println("=> ${p.sentential_form}")
	p.sentential_form = p.sentential_form.replace_once("<y>", y_char)
	println("=> ${p.sentential_form}")
	return DrawCommand{name: "fill" coord1: coord.value}
}

//======================
//	Output
//======================

fn display_parse_tree(commands []DrawCommand) {
	println("=================== PARSE TREE ===================")
	println("<graph>")
	println("|-- start")
	println("|-- <plot_stmts>")

	for cmd in commands {
		println("|   |-- <plot>")
		println("|   |   |-- ${cmd.name}")

		// Print first coordinate breakdown (<x> and <y>)
		if cmd.coord1.len >= 2 {
			println("|   |   |-- <x> -> ${cmd.coord1[0..1]}")
			println("|   |   |-- <y> -> ${cmd.coord1[1..2]}")

		}

		// Print second coordinate (for line) or width parameter (for bar)
		if cmd.coord2.len >= 2 {
			println("|   |   |-- ,")
			println("|   |   |-- <x> -> ${cmd.coord2[0..1]}")
			println("|   |   |-- <y> -> ${cmd.coord2[1..2]}")
		} else if cmd.param.len > 0 {
			println("|   |   |-- ,")
			println("|   |   |-- <y> -> ${cmd.param}")
		}
	}

	println("|-- end")
	println("==================================================")
}