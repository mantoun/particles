-- A simple particle system for Love 0.10.0

-- The module
local particles = {
  num_particles = 0,  -- Track the global number of particles
  systems = {},
  forces = {
    {x=0, y=80}  -- Gravity
  },
  repellers = {},
  image = love.graphics.newImage('img/particle.png')
}

function particles.new_system(x, y, max_particles)
  -- Initialize and return a new particle system
  local rand = math.random

  -- Create a mesh for the particles
  local verts = {}
  verts[1] = {-1, -1, 0, 0}
  verts[2] = {-1, 1, 0, 1}
  verts[3] = {1, -1, 1, 0}
  verts[4] = {1, 1, 1, 1}
  local mesh = love.graphics.newMesh(verts, "strip", "static")
  mesh:setTexture(particles.image)
  
  local ps = {  -- The particle system
    rate = 60,  -- Emission rate in particles per second
    timer = 0,  -- Emission timer. Emit particles every 1/rate seconds
    origin = {x=x, y=y},
    particles = {},  -- Track all particles in the system
    color = nil,
    degrees = {min=1, max=360},
    texture = true  -- Whether or not to draw the mesh for each particle
  }

  function ps.new_particle()
    local p = {}  -- the particle
    local color
    if ps.color then
      color = {ps.color[1], ps.color[2], ps.color[3], ps.color[4]}  -- A copy
    else
      color = {rand(0, 255), rand(0, 255), rand(0, 255), 255}
    end
    local location = {x=x, y=y}


    -- Generate a random angle and magnitude
    local theta = math.rad(rand(ps.degrees.min, ps.degrees.max))
    local r = rand(1, 50)
    -- Convert them to a velocity vector
    local velocity = {x=r*math.cos(theta), y=r*math.sin(theta)}
    local acceleration = {x=0, y=0}

    local width = rand(1, 2)
    local size = {x=width, y=width}
    local lifespan = rand(1, 3)  -- lifespan in seconds

    function p.update(dt)
      -- Update the particle. Return true if it's still alive.
      -- Reduce alpha based on lifespan.
      color[4] = color[4] - 255/lifespan * dt
      if color[4] <= 0 then
        return false
      end

      -- TODO: particle mass
      -- Apply forces to each particle
      for _,f in ipairs(particles.forces) do
        velocity.x = velocity.x + f.x * dt
        velocity.y = velocity.y + f.y * dt
      end
      -- Apply repellers to each particle
      for _,r in ipairs(particles.repellers) do
        local acceleration = r.repel(location)
        velocity.x = velocity.x + acceleration.x * dt
        velocity.y = velocity.y + acceleration.y * dt
      end
      -- Update particle location
      location.x = location.x + velocity.x * dt
      location.y = location.y + velocity.y * dt
      return true
    end

    function p.render()
      -- Draw the particle.
      love.graphics.setColor(color)
      if ps.texture then
        love.graphics.draw(mesh, location.x, location.y, 0, 4*size.x)
      else
        --love.graphics.ellipse('fill', location.x, location.y, size.x, size.y)
        --love.graphics.rectangle('fill', location.x, location.y, size.x, size.y)
        love.graphics.circle('fill', location.x, location.y, size.x)
      end

    end

    table.insert(ps.particles, p)  -- Register the particle with the system.
    particles.num_particles = particles.num_particles + 1
  end

  function ps.update(dt)
    local dead = {}
    ps.timer = ps.timer + dt  -- Track the time since last emission
    -- If the system isn't at max capacity, add more particles.
    if #ps.particles < max_particles then
      if ps.timer > 1/ps.rate then
        -- Compute how many particles to emit
        local need = max_particles - #ps.particles
        for i=1,math.min(need, math.ceil(ps.rate*dt)) do
          ps.new_particle()
        end
        ps.timer = 0
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
      particles.num_particles = particles.num_particles - 1
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
  for i=1,max_particles do
    ps.new_particle()
  end
  --]]

  table.insert(particles.systems, ps)
  return ps
end

function particles.new_repeller(x, y, polarity)
  local r = {}
  r.strength = 250000
  r.polarity = polarity or -1
  local red = {255, 0, 0}
  local blue = {0, 0, 255}
  local size = 4

  function r.draw()
    local color = (r.polarity==-1) and red or blue
    love.graphics.setColor(color)
    love.graphics.circle('fill', x, y, size)
  end

  function r.repel(location)
    -- Given a location, return an accelaration
    dir = {}
    dir.x = x - location.x
    dir.y = y - location.y
    mag = math.sqrt(dir.x^2 + dir.y^2)
    -- Normalize
    dir.x = dir.x / mag
    dir.y = dir.y / mag
    -- Constrain magnitude
    mag = math.max(mag, 5)
    mag = math.min(mag, 100)
    -- Calculate and apply force
    force = r.polarity * r.strength / mag^2;
    dir.x = dir.x * force
    dir.y = dir.y * force
    return dir;
  end
  table.insert(particles.repellers, r)
  return r
end

function particles.draw()
  -- Draw all particle systems and repellers
  for _,v in ipairs(particles.systems) do
    v.draw()
  end
  for _,v in ipairs(particles.repellers) do
    v.draw()
  end
end

function particles.update(dt)
  -- Update all particle systems
  for _,v in ipairs(particles.systems) do
    v.update(dt)
  end
end

return particles
