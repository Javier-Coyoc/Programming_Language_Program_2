module main

import gg

const (
    win_width  = 600
    win_height = 600
    cell_size  = 60 
)

struct App {
    mut:
        gg       &gg.Context = unsafe { nil }
        commands []DrawCommand               
}

// Helper functions to map BNF grid coordinates (e.g., x = 'a'..'j') to pixel locations on screen.
fn coord_to_pixel(x_char u8, y_char u8) (f32, f32) {
    col := f32(x_char - `a`)
    row := f32(y_char - `0`)

    pixel_x := col * f32(cell_size)
    pixel_y := row * f32(cell_size)

    return pixel_x, pixel_y
}

// How the code works is that the window is set a boundary size (600/600) the top left starts at (0, 0)/(x, y) and as
// x increases it moves to the right y will remain the same and for when y decreases it goes downwards

/* (0,0) Top-left ------------------------> X increases right (600,0) Top-right
|
| (x, 0) <-- Top edge of any vertical line
| |
| | Line draws downward
| v
| (x, 600) <-- Bottom edge of any vertical line
v
Y increases down (0,600) Bottom-left -------------------> (600,600) Bottom-right */

fn (app &App) draw_background_grid() {
    for i in 0 .. 11 {
        x := f32(i * cell_size)
        app.gg.draw_line(x, 0, x, f32(win_height), gg.gray)
    }

    for i in 0 .. 11 {
        y := f32(i * cell_size)
        app.gg.draw_line(0, y, f32(win_width), y, gg.gray)
    }
}

fn (app &App) draw_bar_cmd(cmd DrawCommand) {
    if cmd.coord1.len < 2 {
        return
    }

    px, py := coord_to_pixel(cmd.coord1[0], cmd.coord1[1])
    width_cells := cmd.param.int()
    bar_width := f32(width_cells * cell_size)

    app.gg.draw_rect_filled(px, py, bar_width, f32(cell_size), gg.blue)
    app.gg.draw_rect_empty(px, py, bar_width, f32(cell_size), gg.black)
}

fn (app &App) draw_line_cmd(cmd DrawCommand) {
    if cmd.coord1.len < 2 || cmd.coord2.len < 2 {
        return
    }

    px1, py1 := coord_to_pixel(cmd.coord1[0], cmd.coord1[1])
    px2, py2 := coord_to_pixel(cmd.coord2[0], cmd.coord2[1])

    center_offset := f32(cell_size / 2)
    app.gg.draw_line(px1 + center_offset, py1 + center_offset, px2 + center_offset, py2 + center_offset, gg.red)
}

fn (app &App) draw_grid_cmd(cmd DrawCommand) {
    if cmd.coord1.len < 2 {
        return
    }
    px, py := coord_to_pixel(cmd.coord1[0], cmd.coord1[1])

    app.gg.draw_rect_empty(px, py, f32(cell_size), f32(cell_size), gg.yellow)
}

fn (app &App) draw_fill_cmd(cmd DrawCommand) {
    if cmd.coord1.len < 2 {
        return
    }
    px, py := coord_to_pixel(cmd.coord1[0], cmd.coord1[1])

    app.gg.draw_rect_filled(px, py, f32(cell_size), f32(cell_size), gg.green)
    app.gg.draw_rect_empty(px, py, f32(cell_size), f32(cell_size), gg.black)
}

fn frame(app &App) {
    app.gg.begin()

    app.draw_background_grid()

    for cmd in app.commands {
        match cmd.name {
            'bar' { app.draw_bar_cmd(cmd) }
            'line' { app.draw_line_cmd(cmd) }
            'grid' { app.draw_grid_cmd(cmd) }
            'fill' { app.draw_fill_cmd(cmd) }
            else {}
        }
    }

    app.gg.end()
}

fn render_terminal_graph(commands []DrawCommand) {
	// 1. Create a 10x10 character grid initialized with dot spacers '. '
	mut grid := [][]string{len: 10, init: []string{len: 10, init: '. '}}

	// 2. Plot commands onto the 2D grid
	for cmd in commands {
		match cmd.name {
			'fill' {
				if cmd.coord1.len >= 2 {
					x := int(cmd.coord1[0] - `a`)
					y := int(cmd.coord1[1] - `0`)
					if x >= 0 && x < 10 && y >= 0 && y < 10 {
						grid[y][x] = '█ '
					}
				}
			}
			'bar' {
				if cmd.coord1.len >= 2 {
					x := int(cmd.coord1[0] - `a`)
					y := int(cmd.coord1[1] - `0`)
					width := cmd.param.int()

					for i in 0 .. width {
						if x + i < 10 && y >= 0 && y < 10 {
							grid[y][x + i] = '█ '
						}
					}
				}
			}
			'grid' {
				if cmd.coord1.len >= 2 {
					x := int(cmd.coord1[0] - `a`)
					y := int(cmd.coord1[1] - `0`)
					if x >= 0 && x < 10 && y >= 0 && y < 10 {
						grid[y][x] = '□ '
					}
				}
			}
			'line' {
				if cmd.coord1.len >= 2 && cmd.coord2.len >= 2 {
					x1 := int(cmd.coord1[0] - `a`)
					y1 := int(cmd.coord1[1] - `0`)
					x2 := int(cmd.coord2[0] - `a`)
					y2 := int(cmd.coord2[1] - `0`)

					if x1 < 10 && y1 < 10 { grid[y1][x1] = '* ' }
					if x2 < 10 && y2 < 10 { grid[y2][x2] = '* ' }
				}
			}
			else {}
		}
	}

	// 3. Print top column labels (a-j)
	println('\n    a b c d e f g h i j')
	println('  +--------------------')

	// 4. Print rows with side row labels (0-9)
	for row in 0 .. 10 {
		print('${row} | ')
		for col in 0 .. 10 {
			print(grid[row][col])
		}
		println('')
	}
	println('')
}

pub fn render_graph(commands []DrawCommand) {
    mut app := &App{
        commands: commands
    }

    app.gg = gg.new_context(
        width: win_width
        height: win_height
        window_title: 'Vlang Plotting Interpreter'
        frame_fn: frame
        user_data: app
    )

    app.gg.run()
}