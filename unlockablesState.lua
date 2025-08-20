unlockablesState = {
    slideshow = false,
    timer = 0
}

function unlockablesState:enter()
    stateMachine.gameState = "unlockables"
    
    self.cursor = 1
    self.actual = 1
    self.startNum = 1
    self.endNum = LOAD_PICS

    self.images = loadImagesFromDirectory(self.startNum, self.endNum)
end

function unlockablesState:update(dt)
    if self.slideshow then
        self.timer = self.timer + dt
    end

    if self.timer > SLIDESHOW then
        self:next()
        self.timer = 0
    end
end

function loadImagesFromDirectory(startNum, endNum)

    -- this function is from google's chat gpt ai thing
    directoryPath = "pics"
    local imageNames = love.filesystem.getDirectoryItems(directoryPath)
    local images = {}
    local counter = 1

    for _, filename in pairs(stateMachine.unlocks) do
                if counter >= startNum then
                    local path = directoryPath .. "/" .. filename
                    -- Load the image and add it to the table
                    table.insert(images, love.graphics.newImage(path))
                end

                if counter == endNum then
                    return images
                end
                counter = counter + 1
    end
end

function unlockablesState:keypressed(key)
    if key == "escape" then
        stateMachine:change("start")
    end

    if key == "right" then
        sounds.select:play()
        self.slideshow = false
        self.timer = 0
        unlockablesState:next()
    elseif key == "left" then
        sounds.select:play()
        self.slideshow = false
        self.timer = 0
        unlockablesState:prev()
    end

    if key == "space" then
        sounds.select:play()
        self.slideshow = not self.slideshow
        self.timer = 0
    end
end

function unlockablesState:next()
    if self.cursor < #self.images then
        self.cursor = self.cursor + 1
    elseif self.cursor == #self.images and self.endNum < #stateMachine.unlocks then
        self.cursor = 1

        self.startNum = self.startNum + LOAD_PICS
        if self.endNum + LOAD_PICS > #stateMachine.unlocks then
            self.endNum = #stateMachine.unlocks
        else
            self.endNum = LOAD_PICS + self.endNum
        end

        self.images = loadImagesFromDirectory(self.startNum, self.endNum)

    end
    self.actual = self.startNum + self.cursor - 1
end

function unlockablesState:prev()
    if self.cursor > 1 then
        self.cursor = self.cursor - 1
    elseif self.cursor == 1 and self.startNum > 1 then 
        if self.startNum < LOAD_PICS then
            self.startNum = 1
        else 
            self.startNum = self.startNum - LOAD_PICS
        end
        self.endNum = self.startNum + LOAD_PICS - 1

        self.cursor = LOAD_PICS
        self.images = loadImagesFromDirectory(self.startNum, self.endNum)
    end

    self.actual = self.startNum + self.cursor - 1
end

function unlockablesState:render()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.title2)
    love.graphics.printf("This is the Unlockables page", 0, 100, VIRTUAL_WIDTH, "center")

    local width = self.images[self.cursor]:getWidth()
    local height = self.images[self.cursor]:getHeight()

    -- always a bit lower than "this is unlockables..."
    local yPos = 170
    -- height is always 900
    local scale = 900 / height

    local virtualWidth = 900 * width / height
    local xPos = (VIRTUAL_WIDTH - virtualWidth) / 2

    love.graphics.draw(self.images[self.cursor], xPos, yPos, 0, scale, scale)

    love.graphics.setFont(fonts.stats)
    -- love.graphics.print(tostring(self.cursor + self.startNum - 1) .. "/" .. tostring(#stateMachine.unlocks), 1800, 10)
    love.graphics.print(tostring(self.actual) .. "/" .. tostring(#stateMachine.unlocks), 1800, 10)

    if self.slideshow then
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("fill", 50, 50, 50)
        love.graphics.push()
        love.graphics.setColor(0, 0, 0)
        love.graphics.translate(50, 50)
        love.graphics.scale(1, -1)
        love.graphics.rotate(-self.timer * 2 * math.pi / SLIDESHOW )
        love.graphics.rectangle("fill", 0, 0, 2, 40)
        love.graphics.pop()
    end
end