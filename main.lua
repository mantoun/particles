local particles = require 'particles'

math.randomseed(os.time())

function love.load()
  particles.init(10)
  --particles.new_particle()
end

function love.update(dt)
  particles.update(dt)
end

function love.draw()
  particles.draw()
end
