-- A simple particle system for Love 0.10.0
local rand = math.random
local randf = function(min, max) return rand() * (max - min) + min end
local lerp = function(a,b,t) return (1 - t) * a + t * b end

-- The module
local particles = {}
particles.num_particles = 0   -- Track the global number of particles
particles.systems = {}        -- All particle systems
particles.forces = {}         -- Arbitrary force vectors to apply
particles.repellers = {}      -- Repellers / attractors
local gravity = {x=0, y=100}

-- Initialize and return a new particle system
function particles.new_system(x, y, conf)

  -- Create the system
  local ps = {}
  ps.particles = {}   -- Track all particles in the system
  ps.timer = 0        -- Track time between emissions
  -- Configure the particle system
  local conf = conf or {}
  ps.max_particles = conf.max_particles or 1000
  ps.rate = conf.rate or 100            -- Emission in particles per second
  ps.origin = conf.origin or {x=x, y=y} -- The origin of the system
  ps.color = conf.color or nil          -- A default color
  ps.end_color = conf.end_color or nil  -- A target color
  ps.degrees = conf.degrees or {min=1, max=360}
  ps.mass = conf.mass or 1              -- The mass of particles
  ps.one_shot = conf.one_shot or false  -- Emit all particles at once then stop
  ps.size = conf.size or {min=1, max=2} -- TODO: support different w & h
  ps.velocity = conf.velocity or {min=1, max=100}
  ps.lifespan = conf.lifespan or {min=1, max=10}  -- Lifespan in seconds
  ps.texture = conf.texture or false              -- Draw a textured mesh
  ps.image = conf.image or 'img/particle.png'
  ps.gravity = conf.gravity or false
  ps.fade = not (conf.fade==false or false)       -- Default to true

  -- Create a mesh for the particles
  local image = love.graphics.newImage(ps.image)
  local verts = {}
  verts[1] = {-1, -1, 0, 0}
  verts[2] = {-1, 1, 0, 1}
  verts[3] = {1, -1, 1, 0}
  verts[4] = {1, 1, 1, 1}
  local mesh = love.graphics.newMesh(verts, "strip", "static")
  mesh:setTexture(image)

  function ps.new_particle()
    local p = {}  -- The particle
    local color
    if ps.color then
      color = {ps.color[1], ps.color[2], ps.color[3], ps.color[4]}  -- A copy
    else
      color = {rand(0, 255), rand(0, 255), rand(0, 255), 255}
    end
    local location = {x=ps.origin.x, y=ps.origin.y}
    local mass = ps.mass
    local rotation = math.rad(rand(360))
    local angular_velocity = randf(-1.5, 1.5)
    local size = randf(ps.size.min, ps.size.max)
    local lifespan = randf(ps.lifespan.min, ps.lifespan.max)
    local elapsed = 0

    -- Generate a random angle and magnitude
    local theta = math.rad(randf(ps.degrees.min, ps.degrees.max))
    local r = randf(ps.velocity.min, ps.velocity.max)
    -- Convert them to a velocity vector
    local velocity = {x=r*math.cos(theta), y=r*math.sin(theta)}

    function p.update(dt)
      -- Update the particle. Return true if it's still alive.
      elapsed = elapsed + dt
      if elapsed > lifespan then return false end
      if ps.fade then
        -- Reduce alpha based on lifespan.
        color[4] = color[4] - 255/lifespan * dt
      end
      -- Apply rotation
      rotation = rotation + angular_velocity * dt
      -- Apply gravity (a special force that ignores mass) to each particle
      if ps.gravity then
        velocity.x = velocity.x + gravity.x * dt
        velocity.y = velocity.y + gravity.y * dt
      end
      -- Apply forces to each particle
      for _,f in ipairs(particles.forces) do
        local x = f.x / mass
        local y = f.y / mass
        velocity.x = velocity.x + x * dt
        velocity.y = velocity.y + y * dt
      end
      -- Apply repellers to each particle
      for _,r in ipairs(particles.repellers) do
        local acceleration = r.repel(location)
        local x = acceleration.x / mass
        local y = acceleration.y / mass
        velocity.x = velocity.x + x * dt
        velocity.y = velocity.y + y * dt
      end
      -- Update particle location
      location.x = location.x + velocity.x * dt
      location.y = location.y + velocity.y * dt
      -- Update particle color. TODO: lerp in HSV space instead
      if ps.color and ps.end_color then
        local t = elapsed / lifespan
        color[1] = lerp(ps.color[1], ps.end_color[1], t)
        color[2] = lerp(ps.color[2], ps.end_color[2], t)
        color[3] = lerp(ps.color[3], ps.end_color[3], t)
      end
      return true
    end

    function p.render()
      -- Draw the particle
      love.graphics.setColor(color)
      if ps.texture then
        love.graphics.draw(mesh, location.x, location.y, rotation, 4*size)
      else
        --love.graphics.ellipse('fill', location.x, location.y, size, size)
        --love.graphics.rectangle('fill', location.x, location.y, size, size)
        love.graphics.circle('fill', location.x, location.y, size)
      end
    end

    table.insert(ps.particles, p)  -- Register the particle with the system.
    particles.num_particles = particles.num_particles + 1
  end

  function ps.update(dt)
    local dead = {}
    ps.timer = ps.timer + dt  -- Track the time since last emission
    -- If the system isn't at max capacity, add more particles.
    if #ps.particles < ps.max_particles then
      if ps.timer > 1/ps.rate then
        -- Compute how many particles to emit
        local need = ps.max_particles - #ps.particles
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

  -- If this is a one-shot system emit all particles at once and set
  -- max_particles to 0 to stop further emissions.
  if ps.one_shot then
    for i=1,ps.max_particles do
      ps.new_particle()
      ps.max_particles = 0
      -- TODO: ideally we'd remove the system from the particles.systems after
      -- the last of its particles was destroyed
    end
  end

  table.insert(particles.systems, ps)
  return ps
end

function particles.new_repeller(x, y, polarity)
  local r = {}
  r.strength = 250000
  r.polarity = polarity or -1
  local red = {255, 0, 0, 255}
  local blue = {0, 0, 255, 255}
  local color = (r.polarity==-1) and red or blue
  local size = 4
  local out = true

  function r.draw()
    love.graphics.setColor(color)
    love.graphics.circle('line', x, y, size)
  end

  function r.update(dt)
    -- Fade transparency in and out over time
    color[4] = lerp(150, 255, (math.sin(6*love.timer.getTime()) + 1) / 2)
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
  -- Update all particle systems and repellers
  for _,v in ipairs(particles.systems) do
    v.update(dt)
  end
  for _,v in ipairs(particles.repellers) do
    v.update(dt)
  end
end

return particles
