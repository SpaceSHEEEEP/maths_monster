gameOverState = {}

function gameOverState:enter(score)
    stateMachine.gameState = "gameOver"
    self.score = score
    self.highScoreObtained = false
    self.text = ""
    self.picsUnlocked = 0
    self.NewPics = true

    local money = stateMachine.money

    money = money + score / 100

    -- stateMachine.money = string.format("%.2f", stateMachine.money)

    self.highScoreIndex = checkHighScore(self.score)
    if self.highScoreIndex < 11 then
        self.highScoreObtained = true
        self.newPics = stateMachine:unlockPic()
        self.picsUnlocked = self.picsUnlocked + 1
    end

    while money >= PIC_COST do
        money = money - PIC_COST
        self.newPics = stateMachine:unlockPic()      
        self.picsUnlocked = self.picsUnlocked + 1
    end

    stateMachine:updateMoney(money)
end

function checkHighScore(score)
    local index = 11
    for i = 10, 1, -1 do
        if score > tonumber(stateMachine.highScores[i].score) then
            index = i
        end
    end

    return index
end

function updateHighScore(text, score, highScoreIndex)
    -- we're gonna rewrite the file
    local updatedScores = ""

    -- copy from usual highScores thingy till our new high score
    for i = 1, (highScoreIndex - 1) do
        updatedScores = updatedScores .. stateMachine.highScores[i].name .. '\n'
        updatedScores = updatedScores .. stateMachine.highScores[i].score .. '\n'
    end

    -- add our new highscore into the list, updatedScores. take note of the space btw chars
    updatedScores = updatedScores .. string.sub(text, 1, 1) .. string.sub(text, 3, 3) .. string.sub(text, 5, 5) .. '\n'
    updatedScores = updatedScores .. score .. '\n'

    -- add the rest of the scores
    for i = highScoreIndex, 9 do 
        updatedScores = updatedScores .. stateMachine.highScores[i].name .. '\n'
        updatedScores = updatedScores .. stateMachine.highScores[i].score .. '\n'
    end

    -- finally, rewrite the file
    love.filesystem.write("highscores.lst", updatedScores)

    -- now, update stateMachine.highScores
    stateMachine.highScores = stateMachine:loadHighScores()
end

function gameOverState:keypressed(key)
    if key == "escape" then
        stateMachine:change("start")
    elseif key == "return" or key == "kpenter" then
        if not self.highScoreObtained then
            stateMachine:change("play")
        elseif self.highScoreObtained and #self.text == 5 then
            updateHighScore(self.text, self.score, self.highScoreIndex)
            stateMachine:change("highScore")
        end
    elseif key == "backspace" then
        if #self.text == 1 then
            self.text = string.sub(self.text, 1, #self.text - 1)
        else
            self.text = string.sub(self.text, 1, #self.text - 2)
        end
    end

    for i, letters in pairs(ALPHABETS) do
        if key == letters and #self.text < 5 then
            if #self.text == 0 then
                self.text = string.upper(key)
            else
                self.text = self.text .. ' ' .. string.upper(key)
            end
        end
    end

end

function gameOverState:render()
    love.graphics.setFont(fonts.title2)
    love.graphics.print("Final Score: " .. self.score, 300, 200)
    love.graphics.setFont(fonts.normal)

    if self.highScoreObtained then
        love.graphics.print("New high score!!!", 300, 270)
        if self.newPics then
            love.graphics.print(tostring(self.picsUnlocked) .. " pics unlocked!", 300, 340)
        else
            love.graphics.print("You've unlocked all available pics", 300, 340)
        end

        love.graphics.printf("Enter your initials", 0, VIRTUAL_HEIGHT/2 - 80, VIRTUAL_WIDTH, "center")
        love.graphics.print(self.text, VIRTUAL_WIDTH/2 - 100, VIRTUAL_HEIGHT/2 - 20)
        love.graphics.printf("_ _ _", 0, VIRTUAL_HEIGHT/2 - 15, VIRTUAL_WIDTH, "center")
    
        love.graphics.print("Press Enter to save your score", 300, 850)

    elseif self.picsUnlocked > 0 then
        if self.newPics then
            love.graphics.print(tostring(self.picsUnlocked) .. " pics unlocked!", 300, 270)
        else
            love.graphics.print("You've unlocked all available pics", 300, 270)
        end
        love.graphics.print("Press Enter to retry", 300, 850)
        love.graphics.print("Press Esc to quit", 300, 900)
    else
        love.graphics.print("Press Enter to retry", 300, 850)
        love.graphics.print("Press Esc to quit", 300, 900)
    end

end