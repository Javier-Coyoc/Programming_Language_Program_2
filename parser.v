//Main job of parser is to take the tokens that were made in the lexer.v file check if they are valid or follow the BNF rules
module main

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

//========================
//	Recursive Functions
//========================
fn (mut p Parser) parse() ![]DrawCommand {
	// Start the chain reaction
	return p.parse_graph()!
}

//Parse Graph function that reads BNF grammar input from top to bottom
//Basically making the program expect that there will be a 'start' and 'end' keyword and between them the parse_plots
fn (mut p Parser) parse_graph() ![]DrawCommand {
	println("Starting Leftmost Derivation:")
	println("<graph> -> start <plot_stmts> end")
	
	mut commands := []DrawCommand{}

	// Must start with 'start'
	p.consume(.keyword, "start")!
	
	// has to go to the next rule to get the commands
	// commands = p.parse_plot_stmts()! 
	
	// Must end with 'end'
	p.consume(.keyword, "end")!
	
	return commands
}

//check <plot> keyword and if it the input has any ';' which means there is another <plot_stmt>
fn (mut p Parser) parse_plot_stmts() ![]DrawCommand {
	//Every plot_stmts starts with at least one <plot>
	cmd := p.parse_plot()!
	commands << cmd

	//use p.peek() to check if the next token is a ;
	current := p.peek()
	if current.kind == .semicolon {
		// Consume it
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
		return error("Syntax Error: Expected a plot command ('bar', 'line', 'grid', 'fill'), but got '${current.value}'")
	}

	// Match the keyword to the correct parsing rule
	match current.value {
		'bar' {
			return p.parse_bar()!
		}
		'line' {
			return p.parse_line()!
		}
		'grid' {
			return p.parse_grid()!
		}
		'fill' {
			return p.parse_fill()!
		}
		else {
			return error("Syntax Error: Unknown plot command '${current.value}'")
		}
	}
}

// Rule: bar <x><y>,<y>
fn (mut p Parser) parse_bar() !DrawCommand {
	p.consume(.keyword, "bar")!

	coord := p.peek()
	p.consume(.coordinate, "")! // Expects a coordinate like 'b4'

	p.consume(.comma, ",")!

	width := p.peek()
	p.consume(.number, "")! 

return DrawCommand{cmd: "bar ${coord.value},${width.value}"}
}

// line <x><y>,<x><y>
fn (mut p Parser) parse_line() !DrawCommand {
	p.consume(.keyword, "line")!
	
	coord1 := p.peek()
	p.consume(.coordinate, "")!
	
	p.consume(.comma, ",")!
	
	coord2 := p.peek()
	p.consume(.coordinate, "")!

	return DrawCommand{cmd: "line ${coord1.value},${coord2.value}"}
}

// grid <x><y>
fn (mut p Parser) parse_grid() !DrawCommand {
	p.consume(.keyword, "grid")!
	
	coord := p.peek()
	p.consume(.coordinate, "")!

	return DrawCommand{cmd: "grid ${coord.value}"}
}

// fill <x><y>
fn (mut p Parser) parse_fill() !DrawCommand {
	p.consume(.keyword, "fill")!
	
	coord := p.peek()
	p.consume(.coordinate, "")!

	return DrawCommand{cmd: "fill ${coord.value}"}
}

//======================
//	Output
//======================

fn display_parse_tree(commands []DrawCommand) {
	println("\n================ PARSE TREE ================")
	println("<graph>")
	println(" ├── start")
	println(" ├── <plot_stmts>")
	for cmd in commands {
		println(" │    ├── <plot>: ${cmd.cmd}")
	}
	println(" └── end")
	println("============================================")
}