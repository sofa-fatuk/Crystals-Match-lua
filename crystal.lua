local Letters = {'A', 'B', 'C', 'D', 'E', 'F'}

function delay(ms, callback)
  os.execute("sleep " .. ms / 1000)
  callback()
end

function clearConsole()
  os.execute("clear")
end

local function getRandomNumber(min, max)
  min = min or 1
  max = max or #Letters
  return math.random(min, max)
end

local Field = {}
local FieldXLength = 10
local FieldYLength = 10

for x = 1, FieldXLength do
    Field[x] = {}
    for y = 1, FieldYLength do
        Field[x][y] = nil
    end
end

local lastMove = {}

local function init()
  for x = 1, FieldXLength do
    Field[x] = {}
    for y = 1, FieldYLength do
      Field[x][y] = Letters[getRandomNumber()]
    end
  end
end

local function mix()
  local mixed = false

  while not mixed do
    -- Clone the original Field array to perform the mixing
    local mixedField = {}
    for x = 1, FieldXLength do
      mixedField[x] = {}
      for y = 1, FieldYLength do
        mixedField[x][y] = Field[x][y]
      end
    end
    mixed = true

    -- Mix the Field array
    for x = 1, FieldXLength do
      for y = 1, FieldYLength do
        -- Check for horizontal three-in-a-row match
        if y >= 3 and mixedField[x][y] == mixedField[x][y - 1] and mixedField[x][y] == mixedField[x][y - 2] then
          local validLetters = {}
          for _, letter in ipairs(Letters) do
            if letter ~= mixedField[x][y] then
              table.insert(validLetters, letter)
            end
          end
          mixedField[x][y] = validLetters[getRandomNumber(1, #validLetters)]
          mixed = false
        end

        -- Check for vertical three-in-a-column match
        if x >= 3 and mixedField[x][y] == mixedField[x - 1][y] and mixedField[x][y] == mixedField[x - 2][y] then
          local validLetters = {}
          for _, letter in ipairs(Letters) do
            if letter ~= mixedField[x][y] then
              table.insert(validLetters, letter)
            end
          end
          mixedField[x][y] = validLetters[getRandomNumber(1, #validLetters)]
          mixed = false
        end
      end
    end
    -- Copy the mixedField back to Field
    Field = mixedField
  end
end

local function dump()
  print("\n")
  for y = 1, FieldYLength do
    local line = {}
    for x = 1, FieldXLength do
      table.insert(line, Field[x][y] and Field[x][y] or 'o')
    end
    print(table.concat(line, ' '))
  end
end

function undoLastMove()
  if #lastMove > 0 then
    local fX, fY, tX, tY = lastMove[1], lastMove[2], lastMove[3], lastMove[4]
    local oldElement = Field[fX][fY]

    Field[fX][fY] = Field[tX][tY]
    Field[tX][tY] = oldElement
  end

  lastMove = {}
end

local function move(from, to)
  local fX, fY = from[1], from[2]
  local tX, tY = to[1], to[2]

  local oldElement = Field[fX][fY]

  Field[fX][fY] = Field[tX][tY]
  Field[tX][tY] = oldElement

  lastMove[#lastMove + 1] = fX
  lastMove[#lastMove + 1] = fY
  lastMove[#lastMove + 1] = tX
  lastMove[#lastMove + 1] = tY
end

local function handleUserInput(input)
  local action, x, y, direction = string.match(input, "([^%s]+) ([^%s]+) ([^%s]+) ([^%s]+)")
  x = tonumber(x) + 1
  y = tonumber(y) + 1

  if direction == "r" then
    local point = {x + 1, y}
    move({x, y}, point)
  elseif direction == "l" then
    local point = {x - 1, y}
    move({x, y}, point)
  elseif direction == "u" then
    local point = {x, y - 1}
    move({x, y}, point)
  elseif direction == "d" then
    local point = {x, y + 1}
    move({x, y}, point)
  end
end

local function checkMatches(_field, matchCount)
  field = _field or Field
  matchCount = matchCount or 3
  local matches = {}

  -- Check for horizontal matches
  for y = 1, FieldYLength do
    local count = 1
    for x = 2, FieldXLength do
      if field[x][y] == field[x - 1][y] then
        count = count + 1
      else
        if count >= matchCount then
          for i = x - count, x - 1 do
            table.insert(matches, {i, y})
          end
        end
        count = 1
      end
    end
    if count >= matchCount then
      for i = FieldXLength - count, FieldXLength - 1 do
        table.insert(matches, {i, y})
      end
    end
  end

  -- Check for vertical matches
  for x = 1, FieldXLength do
    local count = 1
    for y = 2, FieldYLength do
      if field[x][y] == field[x][y - 1] then
        count = count + 1
      else
        if count >= matchCount then
          for i = y - count, y - 1 do
            table.insert(matches, {x, i})
          end
        end
        count = 1
      end
    end
    if count >= matchCount then
      for i = FieldYLength - count, FieldYLength - 1 do
        table.insert(matches, {x, i})
      end
    end
  end

  return matches
end

local function removeMatches(matches)
  for _, match in pairs(matches) do
    local x, y = match[1], match[2]
    Field[x][y] = nil
  end
end


function checkAnimationRequired()
  local animationRequired = false
  local FieldXLength = #Field
  local FieldYLength = #Field[1]

  for x = 1, FieldXLength do
      for y = 1, FieldYLength do
          if Field[x][y] == nil then
              animationRequired = true
              break
          end
      end
      if animationRequired then
          break
      end
  end

  return animationRequired
end

function countPossibleMoves(board)
  local rows = #board
  local columns = #board[1]
  local count = 0

  -- Check for horizontal moves
  for row = 1, rows do
    for col = 1, columns - 1 do
      -- Create a deep copy of the board
      local boardCopy = {}
      for i = 1, rows do
        boardCopy[i] = {}
        for j = 1, columns do
          boardCopy[i][j] = board[i][j]
        end
      end

      -- Swap adjacent letters
      boardCopy[row][col], boardCopy[row][col + 1] = boardCopy[row][col + 1], boardCopy[row][col]

      -- Check if the move creates a match
      if #checkMatches(boardCopy) > 0 then
        count = count + 1
      else
        -- Undo the move
        boardCopy[row][col], boardCopy[row][col + 1] = boardCopy[row][col + 1], boardCopy[row][col]
      end
    end
  end

  -- Check for vertical moves
  for col = 1, columns do
    for row = 1, rows - 1 do
      -- Create a deep copy of the board
      local boardCopy = {}
      for i = 1, rows do
        boardCopy[i] = {}
        for j = 1, columns do
          boardCopy[i][j] = board[i][j]
        end
      end

      -- Swap adjacent letters
      boardCopy[row][col], boardCopy[row + 1][col] = boardCopy[row + 1][col], boardCopy[row][col]

      -- Check if the move creates a match
      if #checkMatches(boardCopy) > 0 then
        count = count + 1
      else
        -- Undo the move
        boardCopy[row][col], boardCopy[row + 1][col] = boardCopy[row + 1][col], boardCopy[row][col]
      end
    end
  end

  return count
end

function addItems()
  local y = 1
  for x = 1, FieldYLength do
    if Field[x][y] == nil then
      Field[x][y] = Letters[getRandomNumber()]
    end
  end
end

function moveItemsDown()
  local movedField = {}
  for x = 1, FieldXLength do
    movedField[x] = {}
    for y = 1, FieldYLength do
      movedField[x][y] = Field[x][y]
    end
  end

  for x = 1, FieldXLength do
    for y = FieldYLength, 2, -1 do
      if Field[x][y] == nil then
        -- item above
        if Field[x][y - 1] then
          movedField[x][y] = movedField[x][y - 1]
          movedField[x][y - 1] = nil
        end
      end
    end
  end

  Field = movedField
end



function promptGet(inputCallback)
  io.write("userInput: ")
  local userInput = io.read()

  inputCallback(userInput)
end

function animationLoop()
  local matches = checkMatches()
  for i, match in ipairs(matches) do
  end

  function renderLoop()
    while checkAnimationRequired() do
      dump()

      delay(700, function()
          moveItemsDown()
          addItems()
          dump()

          delay(700, function()
              animationLoop()
          end)
      end)
    end

    local hasMatches = #checkMatches() > 0
    if hasMatches then
        animationLoop()
    end
  end

  if #matches > 0 then
      removeMatches(matches)
  else
      dump()

      delay(700, function()
          undoLastMove()
          dump()

          delay(700, renderLoop)
      end)
  end
  renderLoop()
end

function loop()
  promptGet(function(userInput)
      if userInput == "" then
        print("Game is canceled: no input")
        return
      end

      if userInput == "q" then
        print("Game is canceled")
        return
      end

      handleUserInput(userInput)

      animationLoop()

      local moves = countPossibleMoves(Field)
      print(moves)
      if moves == 0 then
          init()
          mix()
          dump()
      end

      loop()
  end)
end

clearConsole()
init()
mix()
dump()
loop()
