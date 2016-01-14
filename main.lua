local particles = require 'particles'

math.randomseed(os.time())

-- Keyboard and mouse controls and debug text
local controls
local stats
local controls_list, controls_string, stats_string
local debug_string = ""
local debug_text = true      -- Whether to draw the controls on the screen
local debug_interval = 1/10  -- Time between updates
local debug_update_timer = 0
local polarity = 1           -- Default polarity for attractor / repeller


function love.load()
  -- Initialize controls
  controls = {{
    key="c",
    description="clear",
    control=function()
      particles.systems = {};
      particles.repellers = {};
      particles.num_particles = 0
    end
  }, {
    key="m",
    description="increase rate",
    control=function()
      for _,v in ipairs(particles.systems) do v.rate = v.rate + 10 end
    end
  }, {
    key="n",
    description="decrease rate",
    control=function()
      for _,v in ipairs(particles.systems) do
        v.rate = math.max(0, v.rate-10)
      end
    end
  }, {
    key="t",
    description="toggle particle textures",
    control=function()
      for _,v in ipairs(particles.systems) do
        v.texture = not v.texture
      end
    end
  }, {
    key="r",
    description="reverse polarity of attractor",
    control=function()
      polarity = polarity * -1
    end
  }, {
    key="1",
    description="preset 1",
    control=function()
      local x, y = love.mouse.getPosition()
      local config = {
        max_particles=1000,
        color={20, 255, 0, 255},
        end_color={0, 0, 255, 255},
        velocity={min=20, max=20},
        fade = false,
        lifespan = {min=1, max=1}
      }
      particles.new_system(x, y, config)
      config = {
        max_particles=1000,
        color={255, 0, 0, 255},
        velocity={min=10, max=10},
        one_shot = true,
        fade = false,
      }
      particles.new_system(x, y, config)
    end
  }, {
    key="2",
    description="preset 2",
    control=function()
      local x, y = love.mouse.getPosition()
      local config = {
        max_particles=1000,
        color={20, 255, 0, 255},
        end_color={255, 255, 0, 255},
        velocity={min=20, max=50},
        size={min=1, max=1},
        one_shot = true,
        gravity = true,
        lifespan = {min=2, max=2},
      }
      particles.new_system(x, y, config)
      config.color = {0, 0, 255, 255}
      particles.new_system(x, y, config)
      config = {
        max_particles=20,
        color={255, 0, 0, 255},
        velocity={min=5, max=10},
        size={min=5, max=10},
        one_shot = true,
        fade = false,
        lifespan = {min=2, max=2},
      }
      config.texture = true
      particles.new_system(x, y, config)
    end
  }, {
    key="3",
    description="preset 3",
    control=function()
      local x, y = love.mouse.getPosition()
      local config = {
        max_particles=1,
        color={20, 255, 0, 255},
        velocity={min=20, max=50},
        size={min=10, max=10},
        one_shot = true,
        lifespan = {min=5, max=5},
      }
      particles.new_system(x, y, config)
    end
  }, {
    key="q",
    description="quit",
    control=function() love.event.push("quit") end
  }}
  controls_list = {}
  for i,v in ipairs(controls) do
    table.insert(controls_list, v.key .. "  " .. v.description)
  end
  -- Initialize debug stats and strings
  controls_string = table.concat(controls_list, '\n')
  stats = {
    'fps ' .. love.timer.getFPS(),
    'particles ' .. particles.num_particles
  }
  stats_string = table.concat(stats, '\n')
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
      debug_string = stats_string .. '\n\n' .. controls_string
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
    local config = {max_particles=100}
    particles.new_system(x, y, config)
  elseif button==2 then
    particles.new_repeller(x, y, polarity)
  end
end
