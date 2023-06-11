class ConwaysGameOfLife
  CELL_SIZE = 10
  LINE_COLOR = { r: 220, g: 220, b: 220 }

  def initialize(args)
    @args = args
    @solids = args.outputs.solids
    @lines = args.outputs.lines

    @screen_width = args.grid.w
    @screen_height = args.grid.h

    @grid_width = @screen_width / CELL_SIZE
    @grid_height = @screen_height / CELL_SIZE
  end

  def tick
    render
  end

  def render
    render_grid
  end

  def render_grid
    # Verticals
    (1..@grid_width - 1).each do |x_i|
      x = x_i * CELL_SIZE
      @lines << { x: x, x2: x, y: 0, y2: @screen_height, **LINE_COLOR }
    end

    # Horizontals
    (1..@grid_width - 1).each do |y_i|
      y = y_i * CELL_SIZE
      @lines << { x: 0, x2: @screen_width, y: y, y2: y, **LINE_COLOR }
    end
  end
end

def tick(args)
  args.state.game ||= ConwaysGameOfLife.new(args)
  args.state.game.tick
end

$gtk.reset
