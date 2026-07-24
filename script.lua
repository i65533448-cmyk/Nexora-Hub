local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Forsaken Hub",
   Icon = 0,
   LoadingTitle = "Forsaken Hub",
   LoadingSubtitle = "by Nexora",
   Theme = "Default",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
})

local PlayerTab = Window:CreateTab("Player", 4483362458)
local ESPTab = Window:CreateTab("ESP", 7743885105)
local UtilityTab = Window:CreateTab("Utility", 12073220831)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- ESP Variables
local ESPEnabled = false
local ESPHighlights = {}

-- ESP for Killers and Survivors
local function addESP(player)
    if not player.Character then return end
    if player == LocalPlayer then return end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoidRootPart then return end
    if ESPHighlights[player.UserId] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    
    ESPHighlights[player.UserId] = highlight
end

local function removeESP(player)
    if ESPHighlights[player.UserId] then
        if player.Character then
            local highlight = player.Character:FindFirstChild("Highlight")
            if highlight then
                highlight:Destroy()
            end
        end
        ESPHighlights[player.UserId] = nil
    end
end

-- ESP Toggle
ESPTab:CreateToggle({
   Name = "Enable ESP",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
        ESPEnabled = Value
        if ESPEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    addESP(player)
                end
            end
        else
            for userId, _ in pairs(ESPHighlights) do
                for _, player in pairs(Players:GetPlayers()) do
                    if player.UserId == userId and player.Character then
                        local highlight = player.Character:FindFirstChild("Highlight")
                        if highlight then highlight:Destroy() end
                    end
                end
            end
            ESPHighlights = {}
        end
   end,
})

-- Auto Generator Variable
local AutoGenEnabled = false

-- Auto Complete Generators
local function completeGenerators()
    if not AutoGenEnabled then return end
    
    local workspace = game:GetService("Workspace")
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("generator") or obj.Name:lower():find("gen") then
            if obj:FindFirstChild("ClickDetector") then
                fireclickdetector(obj.ClickDetector)
            end
            if obj:FindFirstChild("Progress") then
                obj.Progress.Value = 100
            end
        end
    end
end

-- Auto Gen Toggle
UtilityTab:CreateToggle({
   Name = "Auto Complete Generators",
   CurrentValue = false,
   Flag = "Toggle2",
   Callback = function(Value)
        AutoGenEnabled = Value
   end,
})

-- Run generator completion periodically
spawn(function()
    while true do
        wait(5)
        completeGenerators()
    end
end)

-- Auto Block Variable
local AutoBlockEnabled = false

-- Auto Block Feature (Press F)
local UserInputService = game:GetService("UserInputService")
local isBlocking = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        isBlocking = true
        Rayfield:Notify({
            Title = "Block",
            Content = "Blocking activated!",
            Duration = 1.5,
            Image = 4483362458,
        })
        
        local remoteEvent = workspace:FindFirstChild("BlockRemote") or game.ReplicatedStorage:FindFirstChild("BlockRemote")
        if remoteEvent then
            remoteEvent:FireServer(true)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        isBlocking = false
        Rayfield:Notify({
            Title = "Block",
            Content = "Blocking deactivated!",
            Duration = 1.5,
            Image = 4483362458,
        })
        
        local remoteEvent = workspace:FindFirstChild("BlockRemote") or game.ReplicatedStorage:FindFirstChild("BlockRemote")
        if remoteEvent then
            remoteEvent:FireServer(false)
        end
    end
end)

-- Auto Block Toggle
PlayerTab:CreateToggle({
   Name = "Auto Block (Press F)",
   CurrentValue = false,
   Flag = "Toggle3",
   Callback = function(Value)
        AutoBlockEnabled = Value
   end,
})

-- Handle new players joining
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(0.5)
        if ESPEnabled then
            addESP(player)
        end
    end)
end)

-- Handle players leaving
Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

Rayfield:Notify({
   Title = "Forsaken Hub Loaded!",
   Content = "All features are ready. Press K to toggle UI.",
   Duration = 3,
   Image = 4483362458,
})