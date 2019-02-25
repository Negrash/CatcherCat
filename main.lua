display.setStatusBar(display.HiddenStatusBar)
display.setDefault("anchorX", 0)
display.setDefault("anchorY", 0)

local basis = require( "moduls.basis" )
local rapid = require( "moduls.rapid" )
local catcher = require( "moduls.catcher" )
local swarm = require( "moduls.swarm" )
local gui = require( "moduls.gui" )

local update = function()  
  local res = basis.update() or rapid.update() or catcher.update() or swarm.update() or gui.update(update)
  if res then 
    stop() 
  end
end

local touch = function(event)
  local direction = nil
  if (event.phase == "ended") then
    local divX = event.x - event.xStart
    local divY = event.y - event.yStart
    if (math.abs(divX) > math.abs(divY)) then
      if (divX > 0 ) then
        direction = 'right'
      else
        direction = 'left'
      end
    else
      if (divY > 0) then
        direction = 'bottom'
      else
        direction = 'top'
      end
    end
    rapid.jump(direction)
  end
end

local start = function()
  basis.start()
  rapid.start()
  catcher.start()
  swarm.start()  
  gui.start()
  Runtime:addEventListener("enterFrame", update)
  basis.S:addEventListener("touch", touch)   
end
local init = function()
  basis.init(0.1, 0.8)
  rapid.init(basis)
  catcher.init(basis, rapid)
  swarm.init(basis, rapid)
  gui.init(basis, start)
end
stop = function()
  Runtime:removeEventListener("enterFrame", update)
  basis.S:removeEventListener("touch", touch) 
  rapid.stop()
  catcher.stop()
  swarm.stop()
  gui.stop()
end

init()
start()

