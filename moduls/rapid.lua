local M = {}
M.name = 'rapid'
M.bit = require( "plugin.bit" )
do
  M.scene = nil             -- сцена для отображения
  M.y = nil                 -- координата по высоте для стремнины
  M.w = nil                 -- ширина стремнины
  M.h = nil                 -- высота стремнины
  M.streamH = nil
  M.streamY = nil
  M.rapidColor = nil        -- цвет заливки стремнины для отладки -- 
  M.bankColor = nil         -- цвет заливки берегов стремнины для отладки --
  M.ratioCoef = 1.618       -- коэффициент для вычисления расстояния между бревнами по высоте
  M.log = {}                -- таблица для характеристик бревен
  M.log.num = 3             -- число бревен в ряду
  M.log.w = nil             -- ширина бревна
  M.log.h = nil             -- высота бревна
  M.log.fillColor = 
  {80/255, 45/255, 22/255}  -- цвет заливки отладочного отображения бревна -- 
  M.log.strokeColor = 
  {40/255, 23/255, 11/255}  -- цвет обрамления отладочного отображения бревна -- 
  M.log.catcherColor =
  {120/255, 68/255, 33/255} -- цвет заливки для отладочного бревна на которое прыгнул ловец -- 
  M.log.strokeWidth = nil   -- ширина обрамления отладочного отображения бревна --   
  M.log.gab = nil           -- расстояние от правого края бревна до левого края следующего бревна
  M.row = {}                -- таблица для ряда бревен
  M.row.gab = nil           -- расстояние от нижнего края бревна до верхнего края бревна в следующем ряду
  M.row.num = nil           -- число рядов бревен в стремнине
  M.rows = {}               -- коллекция рядов бревен
  M.topRow = nil
  M.catcherLog = nil
  M.speedCoef = 0.06        -- коэффициент для высчитывания скорости бревен в стремнине
  M.startSpeed = nil
  M.speed = nil             -- скорость перемещения бревен в стремнине
  M.deltaSpeed = nil
  M.deltaSpeed = nil        -- величина приращения скорости бревен в стремнине
  M.catcher = nil
  M.swarm = nil
  M.basis = nil
end
M.getLog = function(parent, x, y)
  local log = display.newRect(parent, x, y, M.log.w, M.log.h)
    log:setFillColor(unpack(M.log.fillColor))
    log:setStrokeColor(unpack(M.log.strokeColor))
    log.strokeWidth = M.log.strokeWidth
  return log
end
M.getRow = function(parent, x, y)
  local row = display.newGroup()
  parent:insert(row)  
  row.x = x
  row.y = y  
  for i = 1, M.log.num do
    M.getLog(row, (i - 1) * (M.log.w + M.log.gab), 0)
  end
  for i = 1, M.log.num do
    if i == 1 then
      row[i].leftLog = nil
    else
      row[i].leftLog = row[i - 1]
    end
    if i == M.log.num then
      row[i].rightLog = nil
    else
      row[i].rightLog = row[i + 1]
    end
  end
  return row
end
M.jump = function(direction)
  local targetLog = nil
  local catcherLog = M.catcherLog
  if direction == 'top' then
    targetLog = catcherLog.topLog
  elseif direction == 'bottom' then
    targetLog = catcherLog.bottomLog
  elseif direction == 'left' then
    targetLog = catcherLog.leftLog
  elseif direction == 'right' then
    targetLog = catcherLog.rightLog
  end
  if targetLog and targetLog.isVisible and not M.catcher.isJumping then
    catcherLog:setFillColor(unpack(M.log.fillColor))
    targetLog:setFillColor(unpack(M.log.catcherColor))
    M.catcherLog = targetLog
    M.catcher.jump(direction)
  end
end
M.getSumBits = function(num, cnt)
  local res = 0
  for i = 1, cnt do
    res = res + M.bit.band(1, M.bit.rshift(num, i - 1))
  end
  return res
end
M.getRowCode = function(row)
  local code = 0
  local tmp = 0
  for i = 1, M.log.num do
    tmp = 0
    if row[i].isVisible then
      tmp = 1
    end
    code = M.bit.bor(code, M.bit.lshift(tmp, M.log.num - i))
  end
  return code
end
M.randomLogs = function(row, nextRow)
  local nextCode = M.getRowCode(nextRow)
  local code = 0
  repeat
    code = math.random((2 ^ M.log.num) - 1)
  until M.getSumBits(M.bit.band(nextCode, code), M.log.num) > 1
  for i = M.log.num, 1, -1 do
    local shift = M.log.num - i
    local mask = M.bit.lshift(1, shift)
    local isVisible = true
    local log = row[i]
    if M.bit.band(code, mask) == 0 then
      isVisible = false
    end
    log.isVisible = isVisible
  end  
end
M.init = function(basis)
  M.basis = basis
  M.scene = basis.S
  M.y = basis.middle.y
  M.w = basis.W
  M.h = basis.middle.h
  M.row.num = math.floor(M.w * M.ratioCoef / M.log.num)
  M.speed = M.h * M.speedCoef / basis.F
  M.deltaSpeed = M.speed * 0.05
  M.startSpeed = M.speed
  -- код для отладки
  local logAreaW = M.w / M.log.num
  M.logAreaH = logAreaW / M.ratioCoef
  M.row.num = math.floor(M.h / M.logAreaH)
  M.streamH = M.row.num * M.logAreaH
  M.streamY = M.y + (M.h - M.streamH) * 0.5
  M.log.gab = logAreaW * 0.25 / M.ratioCoef
  M.log.w = logAreaW - M.log.gab * 2
  M.log.h = M.log.w / (M.ratioCoef * 3)
  M.log.strokeWidth = 4
  local rect = nil
  for i = 0, M.row.num - 1 do
    M.rows[i + 1] = M.getRow(M.scene, M.log.gab * 2, i * M.logAreaH + M.streamY)
  end
  -- конец кода для отладки
end
M.start = function()
  M.speed = M.startSpeed
  local rows = M.rows
  local row = nil
  for i = 1, M.row.num do
    row = rows[i]
    row.y = (i - 1) * M.logAreaH + M.streamY
    for j = 1, M.log.num do
      if i == 1 then
        M.topRow = row
        row[j].topLog = nil
      else
        row[j].topLog = rows[i - 1][j]
      end
      if i == M.row.num then
        row[j].bottomLog = nil
      else
        row[j].bottomLog = rows[i + 1][j]
      end
      row[j].isVisible = true
    end
    row.isVisible = true
  end
  if M.catcherLog then
    M.catcherLog:setFillColor(unpack(M.log.fillColor))
  end
  M.catcherLog = rows[1][M.log.num]
  M.catcherLog:setFillColor(unpack(M.log.catcherColor))
end
M.update = function() 
  local res = false
  local rows = M.rows
  local row = nil
  local y = nil
  for i = 1, M.row.num do
    row = rows[i]
    y = row.y + M.speed
    if y > (M.streamY + M.streamH) then
      y = M.streamY
      for j = 1, M.log.num do
        if row[j] == M.catcherLog then
          return true
        end
        if row[j].insect ~= nil then
          M.swarm.removeInsect(row[j].insect)
          row[j].insect = nil          
        end
        row[j].topLog.bottomLog = nil
        row[j].topLog = nil
        row[j].bottomLog = M.topRow[j]
        M.topRow[j].topLog = row[j]
      end
      M.randomLogs(row, M.topRow)
      M.topRow = row
      local k = 0
      repeat
        k = math.random(1, M.log.num)
      until row[k].isVisible and row[k].insect == nil
      local insect = M.swarm.getInsect(row[k])
      row[k].insect = insect
      M.speed = M.speed + M.deltaSpeed
    end
    row.y = y
  end
  return res
end
M.captureCheck = function()
  local insect = M.catcherLog.insect
  if insect ~= nil and not insect.isFlying then
    M.swarm.removeInsect(insect)
    M.catcherLog.insect = nil
    M.basis.score = M.basis.score + 1
  end
end
M.stop = function()
  for i = 1, M.row.num do
    M.rows[i].isVisible = false
  end
end
return M