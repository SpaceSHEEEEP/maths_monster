playState = {}

stats = false

function playState:enter(score, timer, addTime, killstreak, addBonusScore)
    stateMachine.gameState = "play"
    self.score = score or 0
    self.addScore = ADD_SCORE
    self.addBonusScore = addBonusScore
    self.text = ""
    self.myAns = ""

    self.oneSecond = 0
    self.timer = timer

    self.addTime = addTime
    self.addTimer = FADE 
    self.addTimeStart = false
    self.killstreak = killstreak or 0

    self.paused = false

    self.qnString, self.ans, self.qnType = generateQn(self.score)

end

function generateQn(score)
    local qnType = 0
    if score <= 1000 then
        qnType = math.random(1,2)
    elseif score > 1000 and score <= 2000 then
        qnType = math.random(1,3)
    else 
        qnType = math.random(1,4)
    end

    local largestNum = math.floor(score / 40) + 9
    local num1 = math.random(1,largestNum)
    local num2 = math.random(1,largestNum)
    local ans = 0
    local operator = ""

    if qnType == 1 then
        ans = num1 + num2
        operator = " + "
    elseif qnType == 2 then
        if num1 < num2 then
            local temp = num1
            num1 = num2
            num2 = temp
        end
        ans = num1 - num2
        operator = " - "
    else 
        largestNum = math.floor(score / 1000) + 10
        num1 = math.random(1,largestNum)
        num2 = math.random(2,largestNum)

        if qnType == 3 then
            ans = num1 * num2
            operator = " X "
        elseif qnType == 4 then
            ans = math.random(2, largestNum)
            num1 = num2 * ans
            operator = " / "
        end
    end
    


    local qnString = tostring(num1) .. operator .. tostring(num2) .. " = "

    return qnString, ans, qnType
end

function playState:keypressed(key)
    if not self.paused then
        for i, nums in pairs(NUMBERS) do
            if key == nums then
                self.text = self.text .. key
            end
        end

        if key == "backspace" then
            self.text = string.sub(self.text, 1, #self.text - 1)
        end

        if key == "return" and #self.text > 0 then
            self.myAns = tonumber(self.text)

            self:checkAns()
        end

        if key == '.' then
            stats = not stats
        end

        if key == "escape" then
            love.audio.stop()
            sounds.select:play()
            self.paused = true
        end
    else
        if key == "escape" then
            stateMachine:updateMoney(self.score / 100 + stateMachine.money)
            stateMachine:change("start", 0)
        end
        if key == "return" or key == "kpenter" then
            love.audio.stop()
            sounds.select:play()
            self.paused = false
        end
    end
end

function playState:checkAns()
    if self.myAns == self.ans then
        love.audio.stop()
        sounds.correct:play()
    
        self.killstreak = self.killstreak + 1
        if self.killstreak % 5 == 0 then
            self.addBonusScore = self.addBonusScore + self.killstreak
            self.score = self.score + self.addBonusScore
        else
            self.score = self.score + self.addScore
        end

        if self.timer + ADD_MAX_TIME < MAX_TIME then
            self.addTime = ADD_MAX_TIME
            self.timer = self.timer + self.addTime
        else
            self.addTime = MAX_TIME - self.timer
            self.timer = MAX_TIME
        end

        self:enter(self.score, self.timer, self.addTime, self.killstreak, self.addBonusScore)
        self.addTimeStart = true 

    else
        love.audio.stop()
        sounds.wrong:play()

        self.killstreak = 0
    end
end

function playState:update(dt)
    if not self.paused then
        self.oneSecond = self.oneSecond + dt
        if self.oneSecond > 1 then
            self.timer = self.timer - 1
            self.oneSecond = 0
        end
        
        if self.timer < 0 then
            stateMachine:change("gameOver", self.score)
        end

        -- countdown
        if self.addTimeStart then
            if self.addTimer > 0 then
                self.addTimer = self.addTimer - dt
            else
                self.addTimeStart = false
                self.addTimer = FADE
            end
        end 
    end
end

function playState:render() 
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.question)
    
    if not self.paused then
        love.graphics.print(self.qnString .. tostring(playState.text), 300, 400)
    else
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", VIRTUAL_WIDTH/2 - 120, VIRTUAL_HEIGHT/2 - 200, 60, 400)
        love.graphics.rectangle("fill", VIRTUAL_WIDTH/2 + 60, VIRTUAL_HEIGHT/2 - 200, 60, 400)
        love.graphics.setFont(fonts.normal)
        love.graphics.printf("Press Enter to resume", 0, VIRTUAL_HEIGHT/2 + 300, VIRTUAL_WIDTH, "center")
        love.graphics.printf("Press Esc to exit", 0, VIRTUAL_HEIGHT/2 + 350, VIRTUAL_WIDTH, "center")
    end

    if stats then
        love.graphics.setFont(fonts.stats)
        love.graphics.print("Killstreak: " .. tostring(self.killstreak), 10, 10)
    end

    love.graphics.setFont(fonts.normal)
    if self.addTimeStart then
        love.graphics.setColor(1, 1, 1, self.addTimer / FADE)
        love.graphics.print("+" .. self.addTime, 1370, 40)

        if self.killstreak % 5 == 0 then
            love.graphics.print("+" .. self.addBonusScore, 1800, 40)
        else
            love.graphics.print("+" .. self.addScore, 1800, 40)
        end
        love.graphics.setColor(1, 1, 1)
    end

    love.graphics.print("Time left: " .. tostring(self.timer), 800, 10)
    love.graphics.print("Score: " .. tostring(self.score), 1400, 10)

    --[[ 
    if self.paused then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 0, 0, 1920, 1080)
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", 0, 400, 1920, 680)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", VIRTUAL_WIDTH/2 - 120, VIRTUAL_HEIGHT/2 - 200, 60, 400)
        love.graphics.rectangle("fill", VIRTUAL_WIDTH/2 + 60, VIRTUAL_HEIGHT/2 - 200, 60, 400)
        love.graphics.printf("Press Enter to reanse", 0, VIRTUAL_HEIGHT/2 + 300, VIRTUAL_WIDTH, "center")
        love.graphics.printf("Press Esc to exit", 0, VIRTUAL_HEIGHT/2 + 350, VIRTUAL_WIDTH, "center")
    end    
    ]]

end
