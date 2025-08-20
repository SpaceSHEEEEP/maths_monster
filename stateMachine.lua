stateMachine = {
    gameState = "start"
}

function stateMachine:load()
    require "startState"
    startState:enter()

    self.highScores = self:loadHighScores()
    self.unlocks = self:loadPics()
    self.money = self:loadMoney()

    self.now = 0
    self.mins = 0
end

function stateMachine:change(nextState, param1)
    love.audio.stop()

    params1 = params1 or nil
    if nextState == "start" then
        require "startState"
        sounds.select:play()
        startState:enter()
    elseif nextState == "play" then
        require "playState"
        sounds.select:play()
        playState:enter(param1, START_TIMER, ADD_MAX_TIME, 0, ADD_SCORE)
    elseif nextState == "gameOver" then
        require "gameOverState"
        sounds.gameOver:play()
        gameOverState:enter(param1)
    elseif nextState == "highScore" then
        require "highScoreState"
            sounds.select:play()
        highScoreState:enter()
    elseif nextState == "unlockables" then
        require "unlockablesState"
        sounds.select:play()
        unlockablesState:enter()
    end
end

function stateMachine:loadHighScores()
    -- I copied all this from CS50 2D

    if not love.filesystem.getInfo("highscores.lst") then
        local scores = ""
        for i = 10, 1, -1 do
            scores = scores .. "MIK\n"
            scores = scores .. tostring(i * 10) .. '\n' -- 100
        end
        love.filesystem.write("highscores.lst", scores)
    end

    -- flag for whether we're reading a name or not
    local lineIsName = true
    local currentName = nil
    local counter = 1

    local scores = {}

    for i = 1, 10 do
        -- blank table, each holds a name and a score
        scores[i] = {
            name = nil,
            score = nil
        }
    end

    for line in love.filesystem.lines("highscores.lst") do
        if lineIsName then
            scores[counter].name = string.sub(line, 1, 3)
        else
            scores[counter].score = tonumber(line)
            counter = counter + 1
        end

        lineIsName = not lineIsName
    end

    return scores
end

function stateMachine:loadPics()
    -- if unlocks.txt does not exist
    if not love.filesystem.getInfo("unlocks.txt") then
        local string = ""
        local imageNames = love.filesystem.getDirectoryItems("pics")
        for _, filename in pairs(imageNames) do
            if math.random(1, #imageNames) < 5 then
                string = string .. filename .. '\n'
            end
        end
        love.filesystem.write("unlocks.txt", string) 
    end

    -- if unlocks.txt does exist but has been modified
    local allImages = love.filesystem.getDirectoryItems("pics")
    local lostImages = {}
    local unlocks = {}
    local rewriteNeeded = false

    for line in love.filesystem.lines("unlocks.txt") do
        table.insert(unlocks, line)

        if not inTable(line, allImages) then
            table.insert(lostImages, line)
            rewriteNeeded = true
        end
    end

    if rewriteNeeded then
        local string2 = ""
        local modifiedUnlocks = {}
        for _, filename in pairs(allImages) do
            if inTable(filename, unlocks) and not inTable(filename, lostImages) then
                table.insert(modifiedUnlocks, filename)
                string2 = string2 .. filename .. '\n'
            end
        end

        love.filesystem.write("unlocks.txt", string2)
        return modifiedUnlocks

    else
        -- if its ok
        return unlocks
    end
end

function stateMachine:unlockPic()
    local imageNames = love.filesystem.getDirectoryItems("pics")
    local newImage = ""

    -- maybe put new image at front so more incentive to look at new pic
    for _, filename in pairs(imageNames) do
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
    for _, filename in pairs(stateMachine.unlocks) do 
        newTxt = newTxt .. filename .. '\n'
    end
    

    love.filesystem.write("unlocks.txt", newTxt) 
    self.unlocks = self.loadPics()
    -- if new pics, return true
    return true
end

function stateMachine:loadMoney()
    if not love.filesystem.getInfo("money.txt") then
        love.filesystem.write("money.txt", "0") 
    end

    local money 
    for line in love.filesystem.lines("money.txt") do
        money = tonumber(line)
    end

    return money
end

function stateMachine:updateMoney(newMoney)
    love.filesystem.write("money.txt", tostring(newMoney))
    self.money = self.loadMoney()
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