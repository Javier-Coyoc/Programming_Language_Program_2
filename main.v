module main

import os

fn display_bnf() {
    println("================= BNF GRAMMAR =================")
    println("     <graph>  ::= start <plot_stmts> end")
    println("<plot_stmts>  ::= <plot> | <plot> ; <plot_stmts>")
    println("      <plot>  ::= bar <x><y>,<y>")
    println("                | line <x><y>,<x><y>")
    println("                | grid <x><y>")
    println("                | fill <x><y>")
    println("        <x>   ::= a | b | c | d | e | f | g | h | i | j")        
    println("        <y>   ::= 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9")
    println("==============================================")
}      

fn main() {
    for {
        display_bnf()

        input_str := os.input("\nEnter a program string or STOP to exit: ").trim_space()
        if input_str == "STOP" {
            break
        }
        if input_str.len == 0 {
            continue
        }

        //tokenize input
        tokens := tokenize(input_str)

        //parse tokens & print Leftmost Derivation
        mut parser := Parser{tokens: tokens}
        commands := parser.parse() or {
            println(err)
            println("")
            continue 
        }
        
        // print Parse Tree
        _ = os.input("\nPress ENTER to view Parse Tree...")
        display_parse_tree(commands)

        // Prints graphics in command line of shapes that were entered
        _ = os.input("\nPress ENTER to render graphics window...")
        
        render_terminal_graph(commands)
        //println("Graphics window closed. Exiting...")
        //break
    }
}