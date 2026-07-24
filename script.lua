local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- ESP for Killers and Survivors
local function addESP(player)
    if not player.Character then return end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoidRootPart then return end
    
    -- Remove existing ESP if it exists
    if humanoidRootPart:FindFirstChild("ESP") then
        humanoidRootPart:FindFirstChild("ESP"):Destroy()
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP"
    highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Red for killer/survivor
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
end

-- Add ESP to all players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        addESP(player)
    end
end

-- Add ESP to new players joining
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(0.5)
        addESP(player)
    end)
end)

-- Auto Complete Generators
local function completeGenerators()
    local workspace = game:GetService("Workspace")
    
    -- Find all generators in the workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("generator") or obj.Name:lower():find("gen") then
            if obj:FindFirstChild("Humanoid") then
                obj.Humanoid.Health = 0
            end
            -- Try to activate/complete the generator
            if obj:FindFirstChild("ClickDetector") then
                fireclickdetector(obj.ClickDetector)
            end
        end
    end
end

-- Run generator completion periodically
spawn(function()
    while true do
        wait(5)
        completeGenerators()
    end
end)

-- Auto Block Feature (Press F)
local UserInputService = game:GetService("UserInputService")
local isBlocking = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        isBlocking = true
        print("Blocking activated!")
        
        -- Send blocking to server
        local remoteEvent = workspace:FindFirstChild("BlockRemote") or game.ReplicatedStorage:FindFirstChild("BlockRemote")
        if remoteEvent then
            remoteEvent:FireServer(true)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        isBlocking = false
        print("Blocking deactivated!")
        
        local remoteEvent = workspace:FindFirstChild("BlockRemote") or game.ReplicatedStorage:FindFirstChild("BlockRemote")
        if remoteEvent then
            remoteEvent:FireServer(false)
        end
    end
end)

print("Forsaken Hub loaded!")