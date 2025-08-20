require 'stateMachine'
push = require 'push'

-- size of our actual window
WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getDesktopDimensions()

-- size we're trying to emulate with push
VIRTUAL_WIDTH = 1920
VIRTUAL_HEIGHT = 1080

-- other CONSTANTS
START_TIMER = 30
ADD_SCORE = 50
ADD_MAX_TIME = 2
MAX_TIME = 90
FADE = 2

LOAD_PICS = 5
PIC_COST = 20

SLIDESHOW = 5

ALPHABETS = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 
            'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'}
NUMBERS = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 
            "kp0", "kp1", "kp2", "kp3", "kp4", "kp5", "kp6", "kp7", "kp8", "kp9"}

function love.load() 
    love.window.setTitle('Maths Monster')
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = true,
        resizable = true,
        vsync = true
    })
    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed(os.time())

    love.filesystem.setIdentity("mathsMonstersData")

    backgrounds = {
        xPos = math.random(-3000, -1000),
        image = love.graphics.newImage("backgrounds/background" .. math.random(1,7) .. ".png")
    }

    fonts = {
        title = love.graphics.newFont("PressStart.ttf", 200),
        title2 = love.graphics.newFont("PressStart.ttf", 60),
        scores = love.graphics.newFont("PressStart.ttf", 50),
        normal = love.graphics.newFont("PressStart.ttf", 40),
        question = love.graphics.newFont("PressStart.ttf", 100),
        stats = love.graphics.newFont("PressStart.ttf", 20)
    }

    sounds = {
        correct = love.audio.newSource("audio/correct.wav", "static"),
        wrong = love.audio.newSource("audio/wrong.wav", "static"),
        select = love.audio.newSource("audio/select.wav", "static"),
        gameOver = love.audio.newSource("audio/gameOver.wav", "static"),
        unlock = love.audio.newSource("audio/unlock.wav", "static")
    }

    stateMachine:load()
end

function love.keypressed(key)
    stateMachine:keypressed(key)
end

function love.update(dt)
    stateMachine:update(dt)
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.draw()
    push:start()
    stateMachine:render()
    push:finish()
end

function inTable(param, table)
    for _, thing in pairs(table) do 
        if thing == param then
            return true
        end
    end

    return false
end