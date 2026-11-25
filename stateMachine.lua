--[[
    this is required by main.lua
    
    The statemachine is just a table that holds some variables and functions

    the stateMachine has 5 possible states
    - startState
    - playState
    - gameOverState
    - highScoreState
    - unlockablesState

--]]


stateMachine = {
    gameState = "start",
    unlocks,
    money = 0,
    highScores = { -- ew
        { score = 0, name = "MIK" },
        { score = 0, name = "MIK" },
        { score = 0, name = "MIK" },
        { score = 0, name = "MIK" },
        { score = 0, name = "MIK" },
        { score = 0, name = "MIK" },
        { score = 0, name = "MIK" },
        { score = 0, name = "MIK" },
        { score = 0, name = "MIK" },
        { score = 0, name = "MIK" }
    },
    now,
    mins,
}

function stateMachine:load()
    require "states/startState"
    startState:enter()

    self.unlocks = self:loadPics()
    self:loadInfo()

    self.now = 0
    self.mins = 0
end

function stateMachine:change(nextState, param1)
    love.audio.stop()

    params1 = params1 or nil
    if nextState == "start" then
        require "states/startState"
        sounds.select:play()
        startState:enter()
    elseif nextState == "play" then
        require "states/playState"
        sounds.select:play()
        playState:enter(param1, START_TIMER, ADD_MAX_TIME, 0, ADD_SCORE)
    elseif nextState == "gameOver" then
        require "states/gameOverState"
        sounds.gameOver:play()
        gameOverState:enter(param1)
    elseif nextState == "highScore" then
        require "states/highScoreState"
        sounds.select:play()
        highScoreState:enter()
    elseif nextState == "unlockables" then
        require "states/unlockablesState"
        sounds.select:play()
        unlockablesState:enter()
    end
end

function stateMachine:loadInfo()
    -- if this is the first time launching this game, initialise money and highscores, pictures do separately
    if not love.filesystem.getInfo("data.txt") then
        -- first, init money
        local init = "0\n"

        -- then, init high scores
        for i = 10, 1, -1 do
            init = init .. "MIK\n"
            init = init .. tostring(i * 10) .. '\n' 
        end
        if not love.filesystem.write("data.txt", init) then
            print("error: can't write data.txt")
            love.event.quit()
        end
    end

    -- now that we definitely have data.txt, initialise self.money and self.highScores
    local lineNum = 1
    local counter = 0
    for line in love.filesystem.lines("data.txt") do
        if lineNum > 1 then
            if lineNum % 2 == 0 then
                counter = counter + 1
                self.highScores[counter].name = string.sub(line, 1, 3)
            else
                self.highScores[counter].score = tonumber(line)
            end     
        elseif lineNum == 1 then
            self.money = tonumber(line)
        end
        lineNum = lineNum + 1
    end
end

function stateMachine:loadPics()
    if not love.filesystem.getInfo("user_pics") then
        love.filesystem.createDirectory("user_pics")
    end

    -- if unlocks.txt does not exist, create it
    if not love.filesystem.getInfo("unlocks.txt") then
        love.filesystem.write("unlocks.txt", "")
    end

    local allImages = love.filesystem.getDirectoryItems("user_pics")
    local unlocks = {}
    local rewriteNeeded = false

    -- if unlocks.txt does exist but user_pics dir has been modified 
    -- eg, some pics were deleted but unlocks.txt still has it,
    for line in love.filesystem.lines("unlocks.txt") do
        if inTable(line, allImages) then
            table.insert(unlocks, line)
        else 
            rewriteNeeded = true
        end
    end

    if rewriteNeeded then
        local newUnlocksDotTxt = ""
        if #unlocks == 0 then 
            love.filesystem.write("unlocks.txt", "")
        else 
            for _, filename in unlocks do 
                newUnlocksDotTxt = newUnlocksDotTxt .. filename .. '\n'
            end
            love.filesystem.write("unlocks.txt", newUnlocksDotTxt)
        end
    end

    return unlocks -- can be empty
end

function stateMachine:unlockPic()
    local allImages = love.filesystem.getDirectoryItems("user_pics")
    local newImage = ""

    -- maybe put new image at front so more incentive to look at new pic
    for _, filename in pairs(allImages) do
        if not inTable(filename, stateMachine.unlocks) then
            newImage = filename
            break
        end
    end

    -- if no new pics, return false
    if newImage == "" then
        return false
    end

    local newTxt = newImage .. '\n'
    for _, filename in ipairs(stateMachine.unlocks) do 
        newTxt = newTxt .. filename .. '\n'
    end
    love.filesystem.write("unlocks.txt", newTxt) 
    self.unlocks = self.loadPics()
    -- if new pics, return true
    return true
end

function stateMachine:updateMoney(newMoney)
    local lines = {}
    for line in love.filesystem.lines("data.txt") do 
        table.insert(lines, line)
    end
    lines[1] = tostring(newMoney)
    local newText = ""
    for k,v in ipairs(lines) do 
        newText = newText .. v .. '\n'
    end
    if not love.filesystem.write("data.txt", newText) then 
        print("error: in stateMachine::updateMoney, cant rewrite data.txt")
        love.event.quit()
    end
end

function stateMachine:keypressed(key)
    if stateMachine.gameState == "start" then
        startState:keypressed(key)
    end

    if stateMachine.gameState == "play" then
        playState:keypressed(key)
    end

    if stateMachine.gameState == "gameOver" then
        gameOverState:keypressed(key)
    end

    if stateMachine.gameState == "highScore" then
        highScoreState:keypressed(key)
    end

    if stateMachine.gameState == "unlockables" then
        unlockablesState:keypressed(key)
    end
end

function stateMachine:update(dt)
    backgrounds.xPos = backgrounds.xPos - dt
    if backgrounds.xPos < 0 then
        backgrounds.xPos = 3000
    end

    if stateMachine.gameState == "start" then
        startState:update(dt)
    end

    if stateMachine.gameState == "play" then
        playState:update(dt)
    end

    if stateMachine.gameState == "unlockables" then
        unlockablesState:update(dt)
    end

    self.now = os.date('*t')
    self.mins = (self.now.hour * 60 + self.now.min) % 720
end

function stateMachine:render()
    -- background
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.draw(backgrounds.image, backgrounds.xPos - 3000, 0, 0, 4, 4)
    love.graphics.draw(backgrounds.image, backgrounds.xPos, 0, 0, 4, 4)
    love.graphics.setColor(1, 1, 1)

    -- irl clock
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", 50, 50, 50)
    love.graphics.push()
    love.graphics.setColor(0, 0, 0)
    love.graphics.translate(50, 50)
    love.graphics.scale(1, -1)
    love.graphics.rotate(-self.mins * 2 * math.pi / 720)
    love.graphics.rectangle("fill", 0, 0, 2, 40)
    love.graphics.pop()

    love.graphics.setColor(1, 1, 1)

    -- states
    if stateMachine.gameState == "start" then
        startState:render()
    elseif stateMachine.gameState == "play" then
        playState:render()
    elseif stateMachine.gameState == "gameOver" then
        gameOverState:render()
    elseif stateMachine.gameState == "highScore" then
        highScoreState:render()
    elseif stateMachine.gameState == "unlockables" then
        unlockablesState:render()
    end
end
