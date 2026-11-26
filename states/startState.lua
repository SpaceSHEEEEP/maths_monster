startState = {}

function startState:enter()
    stateMachine.gameState = "start"
    
    self.timer = 0
    self.showTitle1 = false
    self.showTitle2 = false
    self.showOptions = false
    self.showCursor = false
    self.cursor = 0

    self.loaded = false 
    self.mouseX = 0 
    self.mouseY = 0
    self.mouseInput = false
end

function startState:update(dt)
    if not self.loaded then
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
            self.loaded = true
        end
    else
        local newX, newY = push:toGame(love.mouse.getPosition())
        if self.mouseInput then 
            self.mouseX = newX or 0
            self.mouseY = newY or 0
            -- self.mouseX, self.mouseY
            if self.mouseX > 627 and self.mouseX < 1284 then 
                if     self.mouseY > 750 and self.mouseY < 825  then self.cursor = 0
                elseif self.mouseY > 825 and self.mouseY < 900  then self.cursor = 1
                elseif self.mouseY > 900 and self.mouseY < 975  then self.cursor = 2
                elseif self.mouseY > 975 and self.mouseY < 1050 then self.cursor = 3
                end
            end

            if love.mouse.isDown(1) then
                if     self.cursor == 0 then    stateMachine:change("play")
                elseif self.cursor == 1 then    stateMachine:change("highScore")
                elseif self.cursor == 2 then    stateMachine:change("unlockables")
                elseif self.cursor == 3 then    love.event.quit()
                end
            end

        elseif  (self.mouseX ~= newX or self.mouseY ~= newY) and 
                (newX > 627 and newX < 1284 and newY > 750 and newY < 1050) then
            self.mouseInput = true
        end
    end
end

function startState:keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    if (key == "return" or key == "kpenter") and self.showCursor then
        if     self.cursor == 0 then stateMachine:change("play")
        elseif self.cursor == 1 then stateMachine:change("highScore")
        elseif self.cursor == 2 then stateMachine:change("unlockables")
        elseif self.cursor == 3 then love.event.quit()
        end
    end

    if self.showCursor then
        if key == "up" then
            self.cursor = (self.cursor - 1) % 4
            self.mouseInput = false
        elseif key == "down" then
            self.cursor = (self.cursor + 1) % 4
            self.mouseInput = false
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
