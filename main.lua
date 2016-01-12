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

-- Particle systems
local systems = {}

function love.load()
  -- Initialize controls
  controls = {{
    key="c",
    description="clear",
    control=function() systems = {}; particles.num_particles = 0 end
  }, {
    key="m",
    description="increase rate",
    control=function()
      for _,v in ipairs(systems) do v.rate = v.rate + 10 end
    end
  }, {
    key="n",
    description="decrease rate",
    control=function()
      for _,v in ipairs(systems) do v.rate = math.max(0, v.rate-10) end
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
  for _,v in ipairs(systems) do v.update(dt) end

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
  for _,v in ipairs(systems) do v.draw() end

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
  ps = particles.new_system(x, y, 1000)
  ps.origin = {x=x, y=y}
  table.insert(systems, ps)
end
