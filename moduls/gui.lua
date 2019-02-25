local M = {}
M.name = 'gui'
M.widget = require( "widget" )
M.basis = nil
M.stopDialog = nil
M.scoreText = 'Number caught: '
M.scoreOutput = nil
M.init = function(basis, restartFunction)
  M.basis = basis
  M.scoreOutput = display.newText(basis.S, M.scoreText..basis.score, 100, 50, native.systemFont, 33)
  local stopDialogW = basis.W * 0.8
  local stopDialogH = stopDialogW * 0.7
  local stopDialogText = 'GAME OVER  -_-'
  local exitButtonText = 'EXIT  :('
  local restartBtnText = 'RESTART  :)'
  local btnDefaultFillColor = {0.7,0.7,0.7,1}
  local btnOverFillColor = {0.5,0.5,0.5,1}
  local btnDefaultStrokeColor = {0.6,0.6,0.6,1}
  local btnOverStrokeColor = {0.4,0.4,0.4,1}
  local btnDefaultLableColot = {0.2,0.2,0.2,1}
  local btnOverLableColot = {0.1,0.1,0.1,1}
  local stopDialog = display.newGroup()
  stopDialog.x = basis.W + 1
  stopDialog.isVisible = false
  basis.S:insert(stopDialog)
  stopDialog.hideX = stopDialog.x
  stopDialog.showUpX = (basis.W - stopDialogW) * 0.5
  stopDialog.y = (basis.H - stopDialogH) * 0.5
  display.newRoundedRect(stopDialog, 0, 0, stopDialogW, stopDialogH, stopDialogH * 0.1):setFillColor(0.25)
  display.newText(stopDialog, stopDialogText, stopDialogW * 0.2, stopDialogH * 0.25, native.systemFont, 44)
  stopDialog:insert( M.widget.newButton(
      {
          label = exitButtonText,
          onEvent = function(event) 
              if (event.phase == "ended") then
                os.exit() 
              end
            end,
          emboss = false,
          fontSize = 27,
          -- Properties for a rounded rectangle button
          shape = "roundedRect",
          x = stopDialogW * 0.05,
          y = stopDialogH * 0.6,
          width = stopDialogW * 0.4,
          height = stopDialogW * 0.1,
          cornerRadius = stopDialogW * 0.002,
          fillColor = { default=btnDefaultFillColor, over=btnOverFillColor },
          strokeColor = { default=btnDefaultStrokeColor, over=btnOverStrokeColor },
          labelColor = { default=btnDefaultLableColot, over=btnOverLableColot },
          strokeWidth = stopDialogW * 0.02
      }
    )
  )
  stopDialog:insert( M.widget.newButton(
      {
          label = restartBtnText,
          onEvent = function(event) 
              if (event.phase == "ended") then
                restartFunction()
              end
            end,
          emboss = false,
          fontSize = 27,
          -- Properties for a rounded rectangle button
          shape = "roundedRect",
          x = stopDialogW - (stopDialogW * 0.07 + stopDialogW * 0.4),
          y = stopDialogH * 0.6,
          width = stopDialogW * 0.4,
          height = stopDialogW * 0.1,
          cornerRadius = stopDialogW * 0.002,
          fillColor = { default=btnDefaultFillColor, over=btnOverFillColor },
          strokeColor = { default=btnDefaultStrokeColor, over=btnOverStrokeColor },
          labelColor = { default=btnDefaultLableColot, over=btnOverLableColot },
          strokeWidth = stopDialogW * 0.02
      }
    )
  ) 
  M.stopDialog = stopDialog
end
M.start = function()
  M.stopDialog.isVisible = false
  M.stopDialog.x = M.stopDialog.hideX
end
M.update = function()
  M.scoreOutput.text = M.scoreText..M.basis.score
end
M.stop = function()
  M.stopDialog.isVisible = true
  M.stopDialog.x = M.stopDialog.showUpX
end
return M