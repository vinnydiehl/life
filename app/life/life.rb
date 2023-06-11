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
    build_render_target
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
          build_render_target
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

    build_render_target
  end
end
