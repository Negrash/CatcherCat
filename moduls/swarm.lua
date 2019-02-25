local M = {}
M.name = 'swarm'
M.insects = {}
M.rapid = nil
M.basis = nil
M.getStartXY = function()
  local r = math.sqrt(M.basis.H ^ 2 + M.basis.W ^ 2) * 0.52
  local a = math.rad(math.random(1, 360))
  local x = r * math.cos(a) + M.basis.W * 0.5
  local y = r * math.sin(a) + M.basis.H * 0.5
  return x, y
end
M.drawInsect = function(insect)
  --display.newRect(insect, 0, 0, 40, 40):setFillColor(0.7, 0.2, 0.1)
  local unitLenght = M.basis.W * 0.0075
  local strokeWidth = unitLenght * 0.32
  local topColor = {255/255, 204/255, 0/255}
  local bottomColor = {255/255, 102/255, 0/255}
  local midleColor = {80/255, 22/255, 22/255}
  local strokeColor = {0/255, 0/255, 0/255}
  local data = 
  { -- x, y, width, height, cornerRadius
    {0, 0, 3, 3, 0.5}, -- левое большое крыло
    {4, 0, 3, 3, 0.5}, -- правое большое крыло
    {1, 3, 2, 2, 0.5}, -- левое малое крыло
    {4, 3, 2, 2, 0.5}, -- правое малое крыло
    {3, 1, 1, 3, 0.5}, -- тело
  }
  local rect = nil
  for i = 1, 2 do
    rect = display.newRoundedRect(insect, data[i][1] * unitLenght, data[i][2] * unitLenght, data[i][3] * unitLenght, 
      data[i][4] * unitLenght, data[i][5] * unitLenght)
    rect.strokeWidth = strokeWidth
    rect:setFillColor(unpack(topColor))
    rect:setStrokeColor(unpack(strokeColor))
  end
  for i = 3, 4 do
    rect = display.newRoundedRect(insect, data[i][1] * unitLenght, data[i][2] * unitLenght, data[i][3] * unitLenght, 
      data[i][4] * unitLenght, data[i][5] * unitLenght)
    rect.strokeWidth = strokeWidth
    rect:setFillColor(unpack(bottomColor))
    rect:setStrokeColor(unpack(strokeColor))
  end
  local i = 5
  rect = display.newRoundedRect(insect, data[i][1] * unitLenght, data[i][2] * unitLenght, data[i][3] * unitLenght, 
    data[i][4] * unitLenght, data[i][5] * unitLenght)
  rect.strokeWidth = strokeWidth
  rect:setFillColor(unpack(midleColor))
  rect:setStrokeColor(unpack(strokeColor))   
end
M.getInsect = function(target)
  local insect = display.newGroup()
  insect.isVisible = false
  M.basis.S:insert(insect)
  M.drawInsect(insect)
  insect.angleX = 0
  insect.angleY = 0
  insect.divAngleX = 4.8
  insect.divAngleY = 21.7
  insect.target = target
  local startX, startY = M.getStartXY()
  insect.realX = startX
  insect.realY = startY
  insect.x = startX
  insect.y = startY
  insect.isFlying = true
  M.insects[#M.insects + 1] = insect
  insect.isVisible = true
  return insect
end
M.init = function(basis, rapid)
  rapid.swarm = M
  M.rapid = rapid
  M.basis = basis
end
M.start = function()
  local name = 'start()'
  local res = false
  local resStr = 'ok'
  if res then 
    resStr = 'err' 
  end
  --print(M.name..': '..name..' - '..resStr)
  
  return res
end
M.oscillation = function(angle, div, amplitude) 
  local tmpAngle = angle + div
  if tmpAngle > 360 then
    tmpAngle = tmpAngle - 360
  end
  return tmpAngle, math.sin(math.rad(tmpAngle)) * amplitude
end
M.insectFlight = function(insect)
  local target = insect.target
  local targetX, targetY = target:localToContent(0 - insect.contentWidth * 0.5, 0 - (target.contentHeight + insect.contentHeight) * 0.5)
  local divX = math.abs(targetX - insect.x + insect.contentWidth * 0.5)
  local divY = math.abs(targetY - insect.y + insect.contentHeight  * 0.5)
  if divX < insect.contentWidth * 1.1 and divY < insect.contentHeight * 1.1 and target ~= M.rapid.catcherLog then
    insect.isFlying = false
  else
    targetX, targetY = target:localToContent(0 - insect.contentWidth * 0.5, 0 - (target.contentHeight + insect.contentHeight) * 0.5)    
    divX = targetX - insect.realX
    divY = targetY - insect.realY
    local pathLength = math.sqrt(divX ^ 2 + divY ^ 2)
    local insectSpeed = M.rapid.speed * 2.3
    divX = divX * (insectSpeed / pathLength)
    divY = divY * (insectSpeed / pathLength)
    insect.realX = insect.realX + divX
    insect.realY = insect.realY + divY
    insect.angleX, divX = M.oscillation(insect.angleX, insect.divAngleX, 90)
    insect.angleY, divY = M.oscillation(insect.angleY, insect.divAngleY, 20)
    insect.x = insect.realX + divX
    insect.y = insect.realY + divY    
  end
end
M.insectFroze = function(insect)
  local target = insect.target
  local targetX, targetY = target:localToContent(0 - insect.contentWidth * 0.5, 0 - (target.contentHeight + insect.contentHeight) * 0.5)
  insect.x = math.floor(targetX)
  insect.y = math.floor(targetY)
end
M.removeInsect = function(insect)
  insect.isRemoving = true
end
M.update = function()
  local insect = nil
  for i = #M.insects, 1, -1 do
    -- код для обновления всех бабочек
    insect = M.insects[i]
    if insect.isRemoving then
      insect:removeSelf()
      table.remove(M.insects, i)      
    elseif insect.isFlying then
      M.insectFlight(insect)
    else
      M.insectFroze(insect)
    end
  end
end
M.stop = function()
  for i = #M.insects, 1, -1 do
    -- код для удаления всех бабочек
    M.insects[i]:removeSelf()
    table.remove(M.insects, i)
  end  
end
return M