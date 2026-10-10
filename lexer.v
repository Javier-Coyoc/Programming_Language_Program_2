//The main job of the lexer is to convert the input text to tokens so the program understands

// Used to categorize input received by the user
enum TokenType {
	keyword    // start, end, bar, line, grid, fill
	coordinate // a0, b4, j9
	number     // 0-9
	comma      // ,
	semicolon  // ;
	invalid    // Any invalid characters
	eof        // End of input
}

// Used to combine the category (tokentype) and its value, the first value kind can be any one of the categories in the enum
struct Token {
	kind  TokenType
	value string
}

//Function that loops through the input
fn tokenize(input string) []Token {
	mut tokens := []Token{}
	mut pos := 0

	//if position is less than the input's length 
	for pos < input.len {
		ch := input[pos]

		//Check for conditions if it is a white space or ,
		if ch.is_space() {
			pos++
			continue
		} 
		
		if ch == `,` {
            tokens << Token{kind: .comma, value: ","}
            pos++
            continue
        }

        if ch == `;` {
            tokens << Token{kind: .semicolon, value: ";"}
            pos++
            continue
        }

		//Using the is_letter() function for strings to check if the current input position we're at is a string/character
		if ch.is_letter() {
			//record the start of the word
			start_pos := pos;

			//Loop and increment the position value as long as position is less than input's length and is a letter or a digit
			for pos < input.len && (input[pos].is_letter() || input[pos].is_digit()){
					pos++
			}

			//Once the for loop above is finished that means the word is finished so we just slice that specific word from its starting char to its final char
			text := input[start_pos..pos]

			//Checks if text variable is a keyword (ex. matches with start, end or bar)
			if text in ['start', 'end', 'bar', 'line', 'grid', 'fill'] {
				// if it is save it in tokens array[]
				tokens << Token{kind: .keyword, value: text}
			} else {
				//If it is not a keyword then it's probably a coordinate (ex. a1, b2, c3)
				tokens << Token{kind: .coordinate, value: text}
			}
			continue
		}


		//Check if input is a number <y> value
		if ch.is_digit() {
			start_pos := pos

			//current pos is less than input's length AND input's current position (current char) is a number
			for pos < input.len && input[pos].is_digit() {
				//move on to next position value 
				pos++
				
			}

			//store it in tokens array
			tokens << Token{kind: .number, value: input[start_pos..pos]}
			continue
		}
		//Invalid characters (errors)
		tokens << Token{kind: .invalid, value: ch.ascii_str()}
		pos++
	}
	//Mark end of input/wont receive anymore input from user
	tokens << Token{kind: .eof, value: ""}
	return tokens
}