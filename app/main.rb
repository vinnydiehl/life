CELL_SIZE = 10
LINE_COLOR = { r: 220, g: 220, b: 220 }.freeze
GENERATION_TIME = 2

class Cell
  attr_accessor :toggleable
  attr_reader :state, :position

  # @param x [Integer] x-coordinate on the grid
  # @param y [Integer] y-coordinate on the grid
  def initialize(x, y)
    @alive = nil
    @position = [x, y]
    @toggleable = true
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
    [x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE].solid
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

  # @return [Array<Array<Integer>>] a list of the coordinates of the 8 neighboring cells
  def neighbors
    (-1..1).map do |x_offset|
      (-1..1).map do |y_offset|
        [x + x_offset, y + y_offset]
      end
    end.flatten(1).reject { |coord| coord == [x, y] }
  end
end

class ConwaysGameOfLife
  def initialize(args)
    @args = args
    @primitives = args.outputs.primitives
    @static_borders = args.outputs.static_borders
    @static_lines = args.outputs.static_lines
    @mouse = args.inputs.mouse
    @kb = args.inputs.keyboard.key_down

    @screen_width = args.grid.w
    @screen_height = args.grid.h

    @grid_width = @screen_width / CELL_SIZE
    @grid_height = @screen_height / CELL_SIZE

    @running = false
    @frames = 0

    @cells = Array.new(@grid_width) { |x| Array.new(@grid_height) { |y| Cell.new(x, y) } }

    render_grid
  end

  def tick
    handle_mouse
    handle_keyboard_input
    handle_timer if @running
    render
  end

  def handle_mouse
    if @mouse.held
      x, y = [@mouse.position.x, @mouse.position.y].map { |n| n / CELL_SIZE }

      @cells[x][y].tap do |cell|
        if cell.toggleable
          cell.toggle
          cell.toggleable = false
          create_render_target
        end
      end
    elsif @mouse.up
      @cells.each do |column|
        column.each { |cell| cell.toggleable = true }
      end
    end
  end

  def handle_keyboard_input
    if @kb.space
      @running = !@running
    end
  end

  def handle_timer
    @frames += 1
    advance_generation if @frames % GENERATION_TIME == 0
  end

  def render
    render_cells
  end

  def render_grid
    # Outline
    @static_borders << { x: 0, y: 0, w: @screen_width, h: @screen_height, **LINE_COLOR }

    # Verticals
    (1..@grid_width - 1).each do |x_i|
      x = x_i * CELL_SIZE
      @static_lines << { x: x, x2: x, y: 0, y2: @screen_height, **LINE_COLOR }
    end

    # Horizontals
    (1..@grid_height - 1).each do |y_i|
      y = y_i * CELL_SIZE
      @static_lines << { x: 0, x2: @screen_width, y: y, y2: y, **LINE_COLOR }
    end
  end

  def render_cells
    @primitives << { x: 0, y: 0, w: @screen_width, h: @screen_height, path: :cells }
  end

  def advance_generation
    marked_cells = []

    @cells.each do |column|
      column.each do |cell|
        living_neighbors = cell.neighbors.select do |x, y|
          x >= 0 && x <= @grid_width - 1 && y >= 0 && y <= @grid_height - 1 && @cells[x][y].alive?
        end.size

        marked_cells << cell if (cell.alive? && (living_neighbors < 2 || living_neighbors > 3)) ||
                                (cell.dead? && living_neighbors == 3)
      end
    end

    marked_cells.each(&:toggle)

    create_render_target
  end

  def create_render_target
    cells_render_target = @args.render_target(:cells).tap do |t|
      t.clear_before_render = true
      t.width = @screen_width
      t.height = @screen_height
    end.primitives

    @cells.each do |column|
      column.each do |cell|
        cells_render_target << cell.rect if cell.alive?
      end
    end
  end
end

def tick(args)
  args.state.game ||= ConwaysGameOfLife.new(args)
  args.state.game.tick
end
