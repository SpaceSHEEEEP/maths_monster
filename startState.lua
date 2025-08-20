startState = {}

function startState:enter()
    stateMachine.gameState = "start"
    
    self.timer = 0
    self.showTitle1 = false
    self.showTitle2 = false
    self.showOptions = false
    self.showCursor = false
    self.cursor = 0
end

function startState:update(dt)
    self.timer = self.timer + dt

    if self.timer > 0.5 then
        self.showTitle1 = true
    end
    if self.timer > 1.25 then
        self.showTitle2 = true
    end
    if self.timer > 2 then
        self.showOptions = true
        self.showCursor = true
    end
end

function startState:keypressed(key)
    if key == "escape" then
        -- maybe update the files?
        love.event.quit()
    end

    if (key == "return" or key == "kpenter") and self.showCursor then
        if self.cursor == 0 then
            stateMachine:change("play")
        elseif self.cursor == 1 then
            stateMachine:change("highScore")
        elseif self.cursor == 2 then
            stateMachine:change("unlockables")
        elseif self.cursor == 3 then
            love.event.quit()
        end
    end

    if self.showCursor then
        if key == "up" then
            self.cursor = (self.cursor - 1) % 4
        elseif key == "down" then
            self.cursor = (self.cursor + 1) % 4
        end
    end
end

function startState:render() 
    love.graphics.setFont(fonts.title)
    if self.showTitle1 then
        love.graphics.printf("Maths", 0, 100, VIRTUAL_WIDTH, "center")
    end
    if self.showTitle2 then
        love.graphics.printf("Monster", 0, 350, VIRTUAL_WIDTH, "center")
    end

    if self.showOptions then
        love.graphics.setFont(fonts.title2)
        love.graphics.printf("Play Game", 0, 750, VIRTUAL_WIDTH, "center")
        love.graphics.printf("High Scores", 0, 825, VIRTUAL_WIDTH, "center")
        love.graphics.printf("Unlockables", 0, 900, VIRTUAL_WIDTH, "center")
        love.graphics.printf("Exit", 0, 975, VIRTUAL_WIDTH, "center")

        if self.cursor == 0 then
            love.graphics.setColor(0.6, 0.6, 1)
            love.graphics.printf("Play Game", 0, 750, VIRTUAL_WIDTH, "center")
        elseif self.cursor == 1 then
            love.graphics.setColor(0.6, 0.6, 1)
            love.graphics.printf("High Scores", 0, 825, VIRTUAL_WIDTH, "center")
        elseif self.cursor == 2 then
            love.graphics.setColor(0.6, 0.6, 1)
            love.graphics.printf("Unlockables", 0, 900, VIRTUAL_WIDTH, "center")
        elseif self.cursor == 3 then
            love.graphics.setColor(0.6, 0.6, 1)
            love.graphics.printf("Exit", 0, 975, VIRTUAL_WIDTH, "center")
        end
    end
end