module main

import os

fn display_bnf() {
    println("=================BNF GRAMMAR=================")
	println("<graph> ::= start <plot_stmts> end")
    println("<plot_stmts> ::= <plot> 
            | <plot> ; <plot_stmt>")
    println("<plot_stmt> ::= bar <x><y>,<y>
            | line <x><y>,<x><y>
            | grid <y>,<y>
            | fill <x><y>")
    println("<x> ::= a | b | c | d | e | f | g | h | i | j")        
    println("<y> ::= 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9");
    println("=============================================")
}      

fn main() {
    for {
        display_bnf()

        input_str := os.input("Enter a program string or STOP to exit: ")
        if input_str == "STOP" {
            break
        }

    //runs parser function on input string
    mut parser := Parser{input: input_str}
		commands := parser.parse()
		
		_ = os.input("Press ENTER to view Parse Tree...")

    }
}

