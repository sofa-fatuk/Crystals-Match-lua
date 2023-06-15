local Letters = {'A', 'B', 'C', 'D', 'E', 'F'}

local defaultDelay = 500

function delay(_ms)
  local ms = _ms or defaultDelay
  os.execute("sleep " .. ms / 1000)
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

local function checkMatches(_field, matchCount)
  field = _field or Field
  matchCount = matchCount or 3
  local matches = {}

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

local function mix()
  local mixed = false

  while not mixed do
    local mixedField = {}
    for x = 1, FieldXLength do
      mixedField[x] = {}
      for y = 1, FieldYLength do
        mixedField[x][y] = Field[x][y]
      end
    end
    mixed = true

    local matches = checkMatches(mixedField)

    if (#matches > 0) then
      mixed = false

      for _, match in pairs(matches) do
        local x, y = match[1], match[2]
        local validLetters = {}

        for _, letter in ipairs(Letters) do
          if letter ~= mixedField[x][y] then
            table.insert(validLetters, letter)
          end
        end

        mixedField[x][y] = validLetters[getRandomNumber(1, #validLetters)]
      end
    end

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

function undoLastMove()
  if #lastMove > 0 then
    local fX, fY, tX, tY = lastMove[1], lastMove[2], lastMove[3], lastMove[4]
    local oldElement = Field[fX][fY]

    Field[fX][fY] = Field[tX][tY]
    Field[tX][tY] = oldElement
  end

  lastMove = {}
end

local function removeMatches(matches)
  for _, match in pairs(matches) do
    local x, y = match[1], match[2]
    Field[x][y] = nil
  end
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
        if Field[x][y - 1] then
          movedField[x][y] = movedField[x][y - 1]
          movedField[x][y - 1] = nil
        end
      end
    end
  end

  Field = movedField
end

function checkForEmptyItems()
  local hasEmptyItems = false
  local FieldXLength = #Field
  local FieldYLength = #Field[1]

  for x = 1, FieldXLength do
      for y = 1, FieldYLength do
          if Field[x][y] == nil then
            hasEmptyItems = true
              break
          end
      end
      if hasEmptyItems then
        break
      end
  end

  return hasEmptyItems
end

function countPossibleMoves(board)
  local rows = #board
  local columns = #board[1]
  local count = 0

  for row = 1, rows do
    for col = 1, columns - 1 do
      local boardCopy = {}
      for i = 1, rows do
        boardCopy[i] = {}
        for j = 1, columns do
          boardCopy[i][j] = board[i][j]
        end
      end

      boardCopy[row][col], boardCopy[row][col + 1] = boardCopy[row][col + 1], boardCopy[row][col]

      if #checkMatches(boardCopy) > 0 then
        count = count + 1
      else
        boardCopy[row][col], boardCopy[row][col + 1] = boardCopy[row][col + 1], boardCopy[row][col]
      end
    end
  end

  for col = 1, columns do
    for row = 1, rows - 1 do
      local boardCopy = {}
      for i = 1, rows do
        boardCopy[i] = {}
        for j = 1, columns do
          boardCopy[i][j] = board[i][j]
        end
      end

      boardCopy[row][col], boardCopy[row + 1][col] = boardCopy[row + 1][col], boardCopy[row][col]

      if #checkMatches(boardCopy) > 0 then
        count = count + 1
      else
        boardCopy[row][col], boardCopy[row + 1][col] = boardCopy[row + 1][col], boardCopy[row][col]
      end
    end
  end

  return count
end


function promptGet()
  io.write("userInput: ")
  local userInput = io.read()
  return userInput
end

function afterMatchAnimationLoop()
  local doLoop = checkForEmptyItems()
  while doLoop do
    dump()
    delay()
    moveItemsDown()
    addItems()
    delay()
    doLoop = checkForEmptyItems()
    if doLoop == false then
      dump()
    end
  end
end

function animationLoop(initialMatches)
  local matches = initialMatches
  local doAnimation = true

  while doAnimation do
    removeMatches(matches)
    afterMatchAnimationLoop()

    matches = checkMatches()

    if #matches <= 0 then
      doAnimation = false
    end
  end
end

function loop()
  while true do
    local userInput = promptGet()
    if userInput == "" then
      print("Game is canceled: no input")
      return
    end

    if userInput == "q" then
      print("Game is canceled")
      return
    end

    handleUserInput(userInput)
    local matches = checkMatches()

    if #matches > 0 then
      animationLoop(matches)

      local moves = countPossibleMoves(Field)
      if moves == 0 then
        init()
        mix()
        dump()
      end
    else
      dump()
      delay()
      undoLastMove()
      dump()
      delay()
    end
  end
end

clearConsole()
init()
mix()
dump()
loop()
