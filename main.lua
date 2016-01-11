local particles = require 'particles'

math.randomseed(os.time())

function love.load()
  ps = particles.new_system(3)
  --ps2 = particles.new_system(4)
end

function love.update(dt)
  ps.update(dt)
  --ps2.update(dt)
end

function love.draw()
  ps.draw()
  --ps2.draw()
end
