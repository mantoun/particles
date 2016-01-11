-- A simple particle system for Love 0.10.0

-- The module
local particles = {}

-- Initialize a new particle system
function particles.new_system(num_particles)
  local ps = {}  -- The particle system
  -- TODO: use
  local origin = {x=0, y=0}

  -- TODO: ability to configure system

  ps.particles = {}  -- Track all particles in the system

  function ps.new_particle(x, y)
    print("Creating new particle at " .. x .. ", " .. y)
    local p = {}  -- the particle
    local color = {40, 0, 200}
    local location = {x=x, y=y}
    local velocity = {x=0, y=100}
    local acceleration = {x=100, y=0}
    local size = {x=10, y=10}
    local lifespan = 1  -- lifespan in seconds

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

    -- Draw the particle.
    function p.render()
      love.graphics.setColor(color)
      love.graphics.rectangle('fill', location.x, location.y, size.x, size.y)
    end
    table.insert(ps.particles, p)  -- register the particle with the system
  end

  function ps.update(dt)
    for k,p in ipairs(ps.particles) do
      local alive = p.update(dt)
      if not alive then
        ps.particles[k] = nil
      end
    end
  end

  function ps.draw()
    for _,p in ipairs(ps.particles) do
      p.render()
    end
  end

  -- Initialize the system with particles
  for i=1,num_particles do
    local x = math.random() * 100
    local y = math.random() * 100
    ps.new_particle(x, y)
  end

  return ps
end

return particles
