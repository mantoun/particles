-- A simple particle system for Love 0.10.0

-- The module
local particles = {}

-- Keep track of all particles
local all_particles = {}

-- TODO: should init a new system
function particles.init(num_particles)
  for i=1,num_particles do
    local x = math.random() * 100
    local y = math.random() * 100
    particles.new_particle(x, y)
  end
end

function particles.new_particle(x, y)
  print("Creating new particle at " .. x .. ", " .. y)
  local p = {}  -- the particle
  local color = {40, 0, 200}
  local location = {x=x, y=y}
  local velocity = {x=0, y=100}
  local acceleration = {x=100, y=0}
  local size = {x=10, y=10}
  local lifespan = 2  -- lifespan in seconds
  function p.update(dt)
    velocity.x = velocity.x + acceleration.x * dt
    velocity.y = velocity.y + acceleration.y * dt
    location.x = location.x + velocity.x * dt
    location.y = location.y + velocity.y * dt
    lifespan = lifespan - dt
  end
  function p.render()
    --color[4] = alpha  -- TODO: alpha
    if lifespan <= 0 then
      return
    end
    love.graphics.setColor(color)
    love.graphics.rectangle('fill', location.x, location.y, size.x, size.y)
  end
  table.insert(all_particles, p)  -- register the particle
  return p
end

function particles.update(dt)
  for _,p in ipairs(all_particles) do
    p.update(dt)
  end
end

function particles.draw()
  for _,p in ipairs(all_particles) do
    p.render()
  end
end

return particles
