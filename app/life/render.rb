class ConwaysGameOfLife
  # Main render tick; called at the end of every frame.
  def render
    @primitives << { x: 0, y: 0, w: @screen_width, h: @screen_height, path: :cells }
  end

  # Statically renders the grid lines; to be called on initialization.
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

  # Updates the render target with the new position of the cells.
  def build_render_target
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
