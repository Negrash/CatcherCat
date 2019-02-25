local M = {}
M.name = 'basis'
--M.goldenRatio = 1.618
M.F = display.fps
M.W = display.contentWidth
M.H = display.contentHeight
M.S = display.newGroup()
M.top = {}
M.middle = {}
M.bottom = {}
M.score = 0
M.init = function(coefY, coefH) --коефициенты для вычисления координаты Y и высоты основной сцены игры
  M.middle.y = coefY * M.H
  M.middle.h = M.H * coefH  --привести потом к целому, которое делится на 2
  if coefY > 0 then
    M.top.h = M.middle.y  
  end
  if M.H < (M.middle.y + M.middle.h + 2) then
    M.bottom.y = M.middle.y + M.middle.h
    M.bottom.h = M.H - M.bottom.y
  end
  -- код для проверки - выводит области экрана в разной градации серого
  display.newRect(M.S, 0, 0, M.W, M.H):setFillColor(0.25)
  display.newRect(M.S, 0, M.middle.y, M.W, M.middle.h):setFillColor(0.75)
  -- конец кода для проверки
end
M.start = function()
  M.score = 0
end
M.update = function()
  local name = 'update()'
  local resStr = 'ok'  
  local res = false
  
  if res then 
    resStr = 'err' 
  end
  --print(M.name..': '..name..' - '..resStr)
  return res
end
return M