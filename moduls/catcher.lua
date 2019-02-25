local M = {}
M.name = 'catcher'
M.view = nil
M.rapid = nil
M.isLeft = true
M.isJumping = false
M.startVelocityY = 10
M.startVelocityX = 10
M.velocityY = 0
M.velocityX = 0
M.gravity = 0.15
M.divX = 0
M.jump = function(direction)
  if direction == 'top' then
    M.velocityY = -M.startVelocityY
    M.velocityX = 0
    M.isJumping = true
  elseif direction == 'bottom' then
    M.velocityY = M.startVelocityY
    M.velocityX = 0
    M.isJumping = true
  elseif direction == 'left' then
    if not M.isLeft then
      M.isLeft = true
      M.view.x = M.view.x - M.divX 
      M.divX = 0
      M.view.xScale = 1
    end
    M.velocityY = 0.2 * -M.startVelocityY
    M.velocityX = -M.startVelocityX
    M.isJumping = true
  elseif direction == 'right' then
    if M.isLeft then
      M.isLeft = false
      M.divX = M.view.contentWidth
      M.view.x = M.view.x + M.divX 
      M.view.xScale = -1
    end
    M.velocityY = 0.2 * -M.startVelocityY
    M.velocityX = M.startVelocityX
    M.isJumping = true
  end
end
M.init = function(basis, rapid)
  M.rapid = rapid
  local unitLenght = rapid.w * 0.0075
  local strokeWidth = unitLenght * 0.32
  local fillColor = {200/255, 113/255, 55/255}
  local eyeColor = {255/255, 246/255, 213/255}
  local strokeColor = {0, 0, 0}
  local data = 
  { -- x, y, width, height
    {0, 3, 5, 4}, -- голова
    {1, 2, 1, 1}, -- ухо 1
    {3, 2, 1, 1}, -- ухо 2
    {5, 1, 8, 4}, -- тело
    {4, 7, 1, 2}, -- лапа 1
    {6, 5, 1, 4}, -- лапа 2
    {11, 5, 1, 4}, -- лапа 3
    {13, 5, 1, 4}, -- лапа 4
    {13, 1, 2, 1}, -- часть хвоста 1
    {15, 0, 2, 1}, -- часть хвоста 2
    {17, 1, 2, 1}, -- часть хвоста 3
    {1, 4, 1, 2}, -- глаз 1
    {3, 4, 1, 2}, -- глаз 2
  }
  local view = display.newGroup()
  basis.S:insert(view)
  view.x = basis.W + 1
  view.isVisible = false
  local rect = nil
  for i = 1, 11 do
    rect = display.newRect(view, data[i][1] * unitLenght, data[i][2] * unitLenght, data[i][3] * unitLenght, data[i][4] * unitLenght)
    rect.strokeWidth = strokeWidth
    rect:setFillColor(unpack(fillColor))
    rect:setStrokeColor(unpack(strokeColor))
  end
  for i = 12, 13 do
    rect = display.newRect(view, data[i][1] * unitLenght, data[i][2] * unitLenght, data[i][3] * unitLenght, data[i][4] * unitLenght)
    rect.strokeWidth = strokeWidth
    rect:setFillColor(unpack(eyeColor))
    rect:setStrokeColor(unpack(strokeColor))
  end
  rapid.catcher = M
  M.view = view
end
M.start = function()
  M.view.isVisible = true
  M.isJumping = false
  if not M.isLeft then
      M.isLeft = true
      M.divX = 0
      M.view.xScale = 1    
  end
end
M.update = function()
  local x, y = M.rapid.catcherLog:localToContent( -M.view.contentWidth * 0.5, -(M.view.contentHeight + M.rapid.catcherLog.contentHeight * 0.5))
  if M.isJumping then
    M.velocityY = M.velocityY + M.gravity
    if (M.velocityX == 0 and M.velocityY < 0 and M.view.y > y and (M.view.y + M.velocityY - M.rapid.speed * 2) < y) or 
    (M.velocityX == 0 and M.velocityY > 0 and M.view.y < y and (M.view.y + M.velocityY + M.rapid.speed * 2) > y) or
    (M.velocityX < 0 and M.view.x > x and (M.view.x + M.velocityX) < x) or
    (M.velocityX > 0 and (M.view.x - M.divX) < x and (M.view.x - M.divX + M.velocityX) > x) then
      M.isJumping = false
      M.rapid.captureCheck()
    else
      M.view.y = M.view.y + M.velocityY + M.rapid.speed
      M.view.x = M.view.x + M.velocityX
    end
  else
    M.view.x = math.floor(x + M.divX)
    M.view.y = math.floor(y)
  end
end
M.stop = function()
  M.view.isVisible = false
end
return M