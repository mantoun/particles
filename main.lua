local particles = require 'particles'

math.randomseed(os.time())

-- Keyboard and mouse controls and debug text
local controls
local stats
local controls_list, stats_string
local debug_string = ""
local debug_text = true       -- Whether to draw the controls on the screen
local debug_interval = 1/10   -- Time between updates
local debug_update_timer = 0
local last = {rate=0}         -- The most recently placed system
local config = {}             -- User changeable config for systems
config.max_particles = 500
config.rate = 100
config.texture = false
config.one_shot = false
config.degrees = {min=1, max=360}
config.gravity = false
config.lifespan = {min=1, max=4}
config.velocity = {min=1, max=100}

-- A utility function to copy tables
function deepcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[deepcopy(orig_key)] = deepcopy(orig_value)
    end
    setmetatable(copy, deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

function love.load()
  -- Initialize controls
  controls = {{
    key="w",
    description="min angle -",
    control=function()
      last.degrees.min = last.degrees.min - 10
      config.degrees.min = config.degrees.min - 10
    end
  }, {
    key="e",
    description="min angle +",
    control=function()
      last.degrees.min = last.degrees.min + 10
      config.degrees.min = config.degrees.min + 10
    end
  }, {
    key="s",
    description="max angle -",
    control=function()
      last.degrees.max = last.degrees.max - 10
      config.degrees.max = config.degrees.max - 10
    end
  }, {
    key="d",
    description="max angle +",
    control=function()
      last.degrees.max = last.degrees.max + 10
      config.degrees.max = config.degrees.max + 10
    end
  }, {
    key="j",
    description="max particles -",
    control=function()
      last.max_particles = last.max_particles - 20
      config.max_particles = config.max_particles - 20
    end
  }, {
    key="k",
    description="max particles +",
    control=function()
      last.max_particles = last.max_particles + 20
      config.max_particles = config.max_particles + 20
    end
  }, {
    key="g",
    description="max velocity -",
    control=function()
      last.velocity.max = last.velocity.max - 20
      config.velocity.max = config.velocity.max - 20
    end
  }, {
    key="h",
    description="max particles +",
    control=function()
      last.velocity.max = last.velocity.max + 20
      config.velocity.max = config.velocity.max + 20
    end
  }, {
    key="m",
    description="emission rate +",
    control=function()
      last.rate = last.rate + 20
      config.rate = config.rate + 20
    end
  }, {
    key="n",
    description="emission rate -",
    control=function()
      last.rate = last.rate - 20
      config.rate = config.rate - 20
    end
  }, {
    key="r",
    description="gravity",
    control=function()
      config.gravity = not config.gravity
      for _,v in ipairs(particles.systems) do
        v.gravity = config.gravity
      end
    end
  }, {
    key="t",
    description="particle textures",
    control=function()
      local texture = not config.texture
      last.texture = texture
      config.texture = texture
    end
  }, {
    key="y",
    description="burst",
    control=function() config.one_shot = not config.one_shot end
  }, {
    key="o",
    description="place attractor",
    control=function()
      local x, y = love.mouse.getPosition()
      particles.new_repeller(x, y, 1)
    end
  }, {
    key="p",
    description="place repeller",
    control=function()
      local x, y = love.mouse.getPosition()
      particles.new_repeller(x, y, -1)
    end
  }, {
    key="1",
    description="preset",
    control=function()
      local x, y = love.mouse.getPosition()
      local red = {255, 0, 0, 255}
      local orange = {255, 175, 64, 255}
      local purple = {100, 10, 235, 255}
      local blue = {0, 0, 255, 255}
      local yellow = {255, 255, 64, 255}
      local config = {}
      -- Inner. Orange to red
      config.one_shot = true
      config.max_particles = 100
      config.velocity = {min=1, max=200}
      config.color = orange
      config.end_color = red
      config.gravity = true
      config.texture = false
      particles.new_system(x, y, config)

      -- Faster, smaller, purple to blue
      config = {}
      config.one_shot = true
      config.max_particles = 400
      config.size = {min=1, max=1}
      config.color = blue
      config.end_color = red
      config.velocity = {min=50, max=350}
      config.gravity = true
      particles.new_system(x, y, config)

      -- Larger high-velocity
      config = {}
      config.one_shot = true
      config.max_particles = 50
      config.size = {min=2, max=5}
      config.color = orange
      config.end_color = red
      config.velocity = {min=1, max=500}
      config.gravity = true
      particles.new_system(x, y, config)

      -- Ring
      config = {}
      config.one_shot = true
      config.max_particles = 300
      config.size = {min=2, max=2}
      config.color = red
      config.end_color = orange
      config.velocity = {min=200, max=200}
      config.gravity = true
      particles.new_system(x, y, config)
    end
  }, {
    key="2",
    description="preset",
    control=function()
      local x, y = love.mouse.getPosition()
      local green = {0, 255, 0, 255}
      local blue = {0, 0, 255, 255}
      local orange = {255, 175, 64, 255}
      local purple = {100, 10, 235, 255}
      local red = {255, 0, 0, 255}
      local yellow = {255, 255, 64, 255}
      local config = {}

      -- Large, high velocity
      config = {}
      config.max_particles = 50
      config.size = {min=2, max=6}
      config.velocity = {min=1, max=400}
      config.lifespan = {min=1, max=2}
      config.color = purple
      config.end_color = green
      config.gravity = false
      config.one_shot = true
      particles.new_system(x, y, config)

      -- Faster, smaller, purple to green
      config = {}
      config.one_shot = true
      config.max_particles = 200
      config.size = {min=1, max=1}
      config.color = purple
      config.end_color = green
      config.lifespan = {min=1, max=2}
      config.velocity = {min=1, max=600}
      particles.new_system(x, y, config)

      -- Middle.
      config = {}
      config.max_particles = 500
      config.rate = 300
      config.velocity = {min=160, max=220}
      config.color = blue
      config.end_color = green
      config.gravity = false
      config.one_shot = true
      config.texture = true
      particles.new_system(x, y, config)

      -- Ring
      config = {}
      config.one_shot = true
      config.max_particles = 1000
      config.size = {min=1, max=1}
      config.color = orange
      config.end_color = yellow
      config.velocity = {min=160, max=160}
      config.gravity = false
      particles.new_system(x, y, config)
    end
  }, {
    key="3",
    description="preset",
    control=function()
      local x, y = love.mouse.getPosition()
      local white = {255, 255, 255, 255}
      local green = {0, 255, 40, 255}
      local blue = {183, 213, 240, 255}
      local orange = {255, 175, 64, 255}
      local purple = {100, 10, 235, 255}
      local red = {255, 0, 0, 255}
      local yellow = {255, 255, 64, 255}
      local config = {}

      -- Puff
      config = {}
      config.max_particles = 50
      config.size = {min=3, max=4}
      config.velocity = {min=1, max=20}
      config.lifespan = {min=1, max=1}
      config.color = white
      config.end_color = blue
      config.gravity = true
      config.one_shot = true
      particles.new_system(x, y, config)

      -- Jet
      config = {}
      config.one_shot = true
      config.max_particles = 200
      config.degrees = {min=269, max=271}
      config.size = {min=1, max=1}
      config.color = orange
      config.end_color = red
      config.lifespan = {min=1, max=2}
      config.velocity = {min=1, max=800}
      config.gravity = true
      particles.new_system(x, y, config)

      -- Inner
      config = {}
      config.max_particles = 100
      config.velocity = {min=380, max=500}
      config.lifespan = {min=1, max=1}
      config.size = {min=2, max=5}
      config.color = purple
      config.end_color = green
      config.one_shot = true
      config.gravity = true
      particles.new_system(x, y, config)

      -- Ring.
      config = {}
      config.max_particles = 3000
      config.rate = 300
      config.velocity = {min=500, max=500}
      config.lifespan = {min=1, max=1}
      config.size = {min=3, max=3}
      config.color = purple
      config.end_color = green
      config.one_shot = true
      config.gravity = true
      particles.new_system(x, y, config)
    end
  }, {
    key="c",
    description="clear",
    control=function()
      particles.systems = {};
      particles.repellers = {};
      particles.num_particles = 0
    end
  }, {
    key="q",
    description="quit",
    control=function() love.event.push("quit") end
  }}
end

function love.update(dt)
  -- Update all particle systems
  particles.update(dt)

  -- Update debug text if it's time
  debug_update_timer = debug_update_timer + dt
  if debug_text then
    if debug_update_timer > debug_interval then
      stats = {
        'fps ' .. love.timer.getFPS(),
        'particles ' .. particles.num_particles
      }
      stats_string = table.concat(stats, '\n')
      -- Regenerate the controls list to reflect current config values
      controls_list = {}
      for i,v in ipairs(controls) do
        local d = v.description
        if v.key == "m" then
          d = string.format("%s [%s]", d, config.rate)
        elseif v.key == "t" then
          d = string.format("%s [%s]", d, config.texture)
        elseif v.key == "y" then
          d = string.format("%s [%s]", d, config.one_shot)
        elseif v.key == "w" then
          d = string.format("%s [%s]", d, config.degrees.min)
        elseif v.key == "j" then
          d = string.format("%s [%s]", d, config.max_particles)
        elseif v.key == "s" then
          d = string.format("%s [%s]", d, config.degrees.max)
        elseif v.key == "g" then
          d = string.format("%s [%s]", d, config.velocity.max)
        elseif v.key == "r" then
          d = string.format("%s [%s]", d, config.gravity)
        elseif v.key == "p" then
          -- Add a divider
          d = string.format("%s\n----------------", d)
        end
        table.insert(controls_list, v.key .. "  " .. d)
      end
      debug_string = stats_string .. '\n\n' .. table.concat(controls_list, '\n')
      debug_update_timer = 0
    end
  end
end

function love.draw()
  -- Draw all particle systems
  particles.draw()

  -- Draw debug text
  if debug_text then
    love.graphics.setColor({255, 255, 255})
    love.graphics.print(debug_string, 20, 20)
  end
end

function love.keypressed(key, unicode)
  -- Handle keystrokes
  for i,v in ipairs(controls) do
    if key == v.key then v.control() end
  end
end

function love.mousepressed(x, y, button)
  if button==1 then
    -- Place a new system with the global config
    local c = deepcopy(config)
    last = particles.new_system(x, y, c)
  end
end
