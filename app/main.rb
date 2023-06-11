%w[constants cell life render].each { |n| require "app/life/#{n}.rb" }

def tick(args)
  args.state.game ||= ConwaysGameOfLife.new(args)
  args.state.game.tick
end
