CELL_SIZE = 10
LINE_COLOR = { r: 220, g: 220, b: 220 }

class Cell
  attr_reader :state, :position

  # @param x [Integer] x-coordinate on the grid
  # @param y [Integer] y-coordinate on the grid
  def initialize(x, y)
    @alive = nil
    @position = [x, y]
  end

  # The X position of the cell
  def x
    @position.x
  end

  # The Y position of the cell
  def y
    @position.y
  end

  # @return [Array<Integer>] the rectangle the cell occupies on the screen
  def rect
    [x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE]
  end

  # Sets the cell state to alive.
  def set_alive
    @alive = true
  end

  # Sets the cell state to dead.
  def set_dead
    @alive = false
  end

  # Sets the cell to dead if it is alive, or to alive if it is dead.
  def toggle
    @alive = !@alive
  end

  # @return [Boolean] whether or not the cell is dead
  def dead?
    !@alive
  end

  # @return [Boolean] whether or not the cell is alive
  def alive?
    @alive
  end
end

class ConwaysGameOfLife
  def initialize(args)
    @args = args
    @solids = args.outputs.solids
    @lines = args.outputs.lines
    @mouse = args.inputs.mouse

    @screen_width = args.grid.w
    @screen_height = args.grid.h

    @grid_width = @screen_width / CELL_SIZE
    @grid_height = @screen_height / CELL_SIZE

    @running = false

    @cells = Array.new(@grid_width) { |x| Array.new(@grid_height) { |y| Cell.new(x, y) } }
  end

  def tick
    handle_mouse_click
    render
  end

  def handle_mouse_click
    return unless click = @mouse.click
    x, y = [click.point.x, click.point.y].map { |n| n / CELL_SIZE }
    @cells[x][y].toggle
  end

  def render
    render_grid
    render_cells
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

  def render_cells
    @cells.each do |column|
      column.each do |cell|
        @solids << cell.rect if cell.alive?
      end
    end
  end

  def start
    @running = true
  end

  def stop
    @running = false
  end
end

def tick(args)
  args.state.game ||= ConwaysGameOfLife.new(args)
  args.state.game.tick
end

$gtk.reset
