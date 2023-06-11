class ConwaysGameOfLife
  def initialize(args); end
  def tick; end
end

def tick(args)
  args.state.game ||= ConwaysGameOfLife.new(args)
  args.state.game.tick
end

$gtk.reset
