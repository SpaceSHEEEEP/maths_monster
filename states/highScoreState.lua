highScoreState = {}

function highScoreState:enter()
    stateMachine.gameState = "highScore"
end

function highScoreState:keypressed(key)
    if key == "escape" then
        stateMachine:change("start")
    end
end

function highScoreState:render()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.title2)
    love.graphics.printf("This is the High Score page", 0, 100, VIRTUAL_WIDTH, "center")

    love.graphics.setFont(fonts.scores)
    for i = 1, 10 do
        love.graphics.printf(stateMachine.highScores[i].name, 400, 200 + i * 75, VIRTUAL_WIDTH - 800, "left")
        love.graphics.printf(stateMachine.highScores[i].score, 400, 200 + i * 75, VIRTUAL_WIDTH - 800, "right")
    end

end