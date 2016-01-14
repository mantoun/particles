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
local config = {}             -- User changeable config for systems
config.rate = 100
config.texture = false
config.one_shot = true
config.degrees = {min=1, max=360}
config.gravity = false
config.lifespan = {min=1, max=4}

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
    key="w",
    description="min angle -",
    control=function() config.degrees.min = config.degrees.min - 10 end
  }, {
    key="e",
    description="min angle +",
    control=function() config.degrees.min = config.degrees.min + 10 end
  }, {
    key="s",
    description="max angle -",
    control=function() config.degrees.max = config.degrees.max - 10 end
  }, {
    key="d",
    description="max angle +",
    control=function() config.degrees.max = config.degrees.max + 10 end
  }, {
    key="m",
    description="emission rate +",
    control=function() config.rate = config.rate + 20 end
  }, {
    key="n",
    description="emission rate -",
    control=function() config.rate = config.rate - 20 end
  }, {
    key="r",
    description="gravity",
    control=function() config.gravity = not config.gravity end
  }, {
    key="t",
    description="particle textures",
    control=function() config.texture = not config.texture end
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
    description="preset 1",
    control=function()
      local x, y = love.mouse.getPosition()
      local config = {}
      particles.new_system(x, y, config)
      config = {}
      particles.new_system(x, y, config)
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
        elseif v.key == "s" then
          d = string.format("%s [%s]", d, config.degrees.max)
        elseif v.key == "r" then
          d = string.format("%s [%s]", d, config.gravity)
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
    particles.new_system(x, y, config)
  end
end
