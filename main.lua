local particles = require 'particles'

math.randomseed(os.time())

-- Keyboard and mouse controls and debug text
local controls, stats
local debug_text = true

-- Initialization
function love.load()
  ps = particles.new_system(100)
  -- ps.origin = {300, 300}
  ps2 = particles.new_system(4)
  -- ps2.origin = {500, 200}
  ps2.color = {255, 255, 255}

  controls = {{
    key="q",
    description="quit",
    control=function() love.event.push("quit") end
  }}
end

function love.update(dt)
  -- Update all particle systems
  ps.update(dt)
  ps2.update(dt)

  if debug_text then
    stats = {
      'fps ' .. love.timer.getFPS()
    }
  end
end

function love.draw()
  -- Draw all particle systems
  ps.draw()
  ps2.draw()

  -- Draw debug text
  if debug_text then
    love.graphics.setColor({255, 255, 255})
    local stats_string = table.concat(stats, '\n')
    local controls_list = {}
    for i,v in ipairs(controls) do
      table.insert(controls_list, v.key .. "  " .. v.description)
    end
    local controls_string = table.concat(controls_list, '\n')
    local debug_string = stats_string .. '\n\n' .. controls_string
    love.graphics.print(debug_string, 20, 20)
  end
end

function love.keypressed(key, unicode)
  -- Execute control function if a control's key is pressed
  for i,v in ipairs(controls) do
    if key == v.key then v.control() end
  end
end

function love.mousepressed(x, y, button)
  if button == 'l' then
  end
end
