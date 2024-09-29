-- Load the UI Library
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wave"))()

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- Variables
local player = Players.LocalPlayer
local unanchoredParts = {}
local monitoring = false
local partProperties = {
    size = Vector3.new(2, 1, 2),
    color = BrickColor.Random(),
    positionOffset = Vector3.new(0, 5, 0)
}

-- UI Setup
local mainWindow = library:CreateWindow("Natural Disasters Script")
local featuresTab = mainWindow:CreateTab("Features")
local unanchoredTab = mainWindow:CreateTab("Unanchored Parts")
local creditsTab = mainWindow:CreateTab("Credits")

-- Notification function
local function notify(message)
    library:Notify("Notification", message)
end

-- Error Handling Wrapper
local function safeExecute(func)
    return xpcall(func, function(err)
        notify("Error: " .. tostring(err))
    end)
end

-- Check for unanchored parts
local function checkUnanchoredParts()
    unanchoredParts = {}
    for _, part in ipairs(Workspace:GetChildren()) do
        if part:IsA("BasePart") and not part.Anchored then
            table.insert(unanchoredParts, part)
        end
    end
    notify("Found " .. #unanchoredParts .. " unanchored parts.")
end

-- Function to apply random force to a part
local function applyRandomForce(part)
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(math.random(-50, 50), math.random(50, 100), math.random(-50, 50))
    bodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
    bodyVelocity.Parent = part
    Debris:AddItem(bodyVelocity, 1) -- Automatically remove after 1 second
end

-- Metatable for Part Handling
local PartHandler = {}
PartHandler.__index = PartHandler

function PartHandler:new(part)
    local obj = setmetatable({}, self)
    obj.Part = part
    return obj
end

function PartHandler:applyForce()
    applyRandomForce(self.Part)
end

function PartHandler:changeColor()
    self.Part.BrickColor = partProperties.color
end

function PartHandler:tweenToPosition(targetPosition)
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local goal = {Position = targetPosition}
    local tween = TweenService:Create(self.Part, tweenInfo, goal)
    tween:Play()
end

-- Feature: Teleport Unanchored Parts
unanchoredTab:AddToggle("Teleport Parts to Me", function(enabled)
    while enabled do
        task.wait(1)
        for _, part in ipairs(unanchoredParts) do
            if part then
                part.Position = player.Character.HumanoidRootPart.Position + partProperties.positionOffset
            end
        end
    end
end)

-- Feature: Create a Ring Effect
unanchoredTab:AddToggle("Ring Effect", function(enabled)
    while enabled do
        task.wait(0.1)
        for _, part in ipairs(unanchoredParts) do
            if part then
                local offset = Vector3.new(math.sin(tick()) * 5, 0, math.cos(tick()) * 5) -- Ring motion
                part.Position = player.Character.HumanoidRootPart.Position + offset
            end
        end
    end
end)

-- Feature: Spin Parts
unanchoredTab:AddToggle("Spin Parts", function(enabled)
    while enabled do
        task.wait(0.1)
        for _, part in ipairs(unanchoredParts) do
            if part then
                part.CFrame = part.CFrame * CFrame.Angles(0, math.rad(5), 0) -- Spin motion
            end
        end
    end
end)

-- Change Color of Parts Button
unanchoredTab:AddButton("Change Color of All Parts", function()
    for _, part in ipairs(unanchoredParts) do
        if part then
            local handler = PartHandler:new(part)
            handler:changeColor()
        end
    end
    notify("Changed colors of unanchored parts.")
end)

-- Toggle Visibility of Parts
unanchoredTab:AddToggle("Toggle Visibility", function(enabled)
    for _, part in ipairs(unanchoredParts) do
        if part then
            part.Transparency = enabled and 0 or 1
        end
    end
    notify("Set visibility of unanchored parts to " .. (enabled and "visible" or "invisible") .. ".")
end)

-- Destroy Unanchored Parts Button
unanchoredTab:AddButton("Destroy All Unanchored Parts", function()
    for _, part in ipairs(unanchoredParts) do
        if part then
            part:Destroy()
        end
    end
    notify("Destroyed all unanchored parts.")
end)

-- Monitor Unanchored Parts Toggle
unanchoredTab:AddToggle("Monitor Unanchored Parts", function(enabled)
    monitoring = enabled
    while monitoring do
        task.wait(5)
        checkUnanchoredParts()
    end
end)

-- Randomize Parts' Sizes
unanchoredTab:AddToggle("Randomize Parts' Sizes", function(enabled)
    while enabled do
        task.wait(1)
        for _, part in ipairs(unanchoredParts) do
            if part then
                local scale = math.random(1, 5) -- Random scale factor
                part.Size = part.Size * scale
            end
        end
    end
end)

-- Apply Force to All Unanchored Parts
unanchoredTab:AddButton("Apply Force to All Parts", function()
    for _, part in ipairs(unanchoredParts) do
        if part then
            local handler = PartHandler:new(part)
            handler:applyForce()
        end
    end
    notify("Applied force to all unanchored parts.")
end)

-- Tween Parts to Player
unanchoredTab:AddButton("Tween Parts to Me", function()
    for _, part in ipairs(unanchoredParts) do
        if part then
            local handler = PartHandler:new(part)
            handler:tweenToPosition(player.Character.HumanoidRootPart.Position + partProperties.positionOffset)
        end
    end
    notify("Tweened all unanchored parts to your position.")
end)

-- Create Custom Part
unanchoredTab:AddButton("Create Custom Part", function()
    local customPart = Instance.new("Part")
    customPart.Size = partProperties.size
    customPart.Position = player.Character.HumanoidRootPart.Position + partProperties.positionOffset
    customPart.Anchored = false
    customPart.BrickColor = partProperties.color
    customPart.Parent = Workspace
    notify("Custom part created.")
end)

-- Enhanced User Input Handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.E then
            checkUnanchoredParts()
        elseif input.KeyCode == Enum.KeyCode.F then
            for _, part in ipairs(unanchoredParts) do
                if part then
                    local handler = PartHandler:new(part)
                    handler:applyForce()
                end
            end
            notify("Applied force to all unanchored parts with 'F' key.")
        end
    end
end)

-- Credits Tab
creditsTab:AddLabel("Script Created By:")
creditsTab:AddLabel("KernelDeva")
creditsTab:AddLabel("Discord: kerneldeva")
creditsTab:AddLabel("Special Thanks to:")
creditsTab:AddLabel("- The Roblox Community")
creditsTab:AddLabel("- Script Libraries Used")

-- Main Execution
safeExecute(function()
    checkUnanchoredParts()
end)

notify("Natural Disasters Script Loaded with Enhanced Features.")
