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
