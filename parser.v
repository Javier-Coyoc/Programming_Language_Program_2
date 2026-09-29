//Main job of parser is to take the tokens that were made in the lexer.v file check if they are valid or follow the BNF rules
module main

import os

struct Parser {
mut:
	input   string
	pos     int
	sentential_form string
}

fn (mut p Parser) parse() []DrawCommand {
	println("Starting Leftmost Derivation:")
	// Print step-by-step substitution:
	// <start> -> <plot_stmt_list>
	// ...
	mut commands := []DrawCommand{}
	
	// Process input tokens sequentially...
	return commands
}

fn display_parse_tree(commands []DrawCommand) {
	println("================ PARSE TREE ================")
	println("<start>")
	println(" └── <plot_stmt_list>")
	for cmd in commands {
		println("      ├── <plot_stmt>: ${cmd.cmd}")
	}
	println("============================================")
}