-- A simple particle system for Love 0.10.0

-- The module
local particles = {}

function particles.new_system(num_particles)
  -- Initialize and return a new particle system
  local rand = math.random
  local ps = {}  -- The particle system
  -- TODO: use
  local origin = {x=0, y=0}
  local rate = 60  -- Emission rate in particles per second
  local timer = 0  -- Emission timer. Emit particles every 1/rate seconds.

  -- TODO: ability to configure system

  ps.particles = {}  -- Track all particles in the system

  function ps.new_particle(x, y)
    local p = {}  -- the particle
    local color = ps.color or {rand(0, 255), rand(0, 255), rand(0, 200)}
    local location = {x=x, y=y}
    local velocity = {x=rand(-200, 200), y=rand(-200, 200)}
    local acceleration = {x=rand(-200, 200), y=rand(-200, 200)}
    local width = rand(2, 10)
    local size = {x=width, y=width}
    local lifespan = rand(1, 3)  -- lifespan in seconds

    function p.update(dt)
      -- Update the particle. Return true if it's still alive.
      lifespan = lifespan - dt
      if lifespan <= 0 then
        return false
      end
      velocity.x = velocity.x + acceleration.x * dt
      velocity.y = velocity.y + acceleration.y * dt
      location.x = location.x + velocity.x * dt
      location.y = location.y + velocity.y * dt
      return true
    end

    function p.render()
      -- Draw the particle.
      love.graphics.setColor(color)
      love.graphics.rectangle('fill', location.x, location.y, size.x, size.y)
    end

    table.insert(ps.particles, p)  -- Register the particle with the system.
  end

  function ps.update(dt)
    local dead = {}
    timer = timer + dt  -- Track the time since last emission
    -- If the system isn't at max capacity, add another particle.
    if table.getn(ps.particles) < num_particles then
      if timer > 1/rate then
        local x = math.random(0, 800)
        local y = math.random(0, 600)
        ps.new_particle(x, y)
        timer = 0
      end
    end
    -- Update all particles keeping track of whether or not they've died.
    for k,p in ipairs(ps.particles) do
      local alive = p.update(dt)
      if not alive then
        dead[#dead+1] = k
      end
    end
    -- Remove dead particles.
    while #dead > 0 do
      table.remove(ps.particles, table.remove(dead, #dead))
    end
  end

  function ps.draw()
    for _,p in ipairs(ps.particles) do
      p.render()
    end
  end

  -- Initialize the system with particles
  -- TODO: if one-shot
  --[[
  for i=1,num_particles do
    local x = math.random() * 100
    local y = math.random() * 100
    ps.new_particle(x, y)
  end
  --]]

  return ps
end

return particles