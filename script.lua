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
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- ESP Variables
local ESPEnabled = false
local ESPHighlights = {}

-- Auto Block Variables
local AutoBlockEnabled = false

-- Killer attack animation IDs
local ATTACK_ANIMATIONS = {
    "rbxassetid://116050994905421",
    "rbxassetid://126830014841198"
}

-- Track which animations we've already blocked
local blockedAnimations = {}

-- Function to block by pressing F
local function blockAttack()
    print("BLOCKING - Pressing F key")
    local UserInputService = game:GetService("UserInputService")
    
    -- Simulate F key press
    UserInputService:SendKeyEvent(true, Enum.KeyCode.F, false)
    task.wait(0.05)
    UserInputService:SendKeyEvent(false, Enum.KeyCode.F, false)
end

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

-- Auto Block Toggle
PlayerTab:CreateToggle({
   Name = "Auto Block (Before Attack)",
   CurrentValue = false,
   Flag = "Toggle3",
   Callback = function(Value)
        AutoBlockEnabled = Value
        blockedAnimations = {} -- Reset when toggling
   end,
})

-- Watch each killer for attack animations
local function watchKiller(player)
    if player == LocalPlayer then return end
    if not player.Character then return end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    spawn(function()
        while player and player.Character and humanoid do
            if AutoBlockEnabled then
                for _, animTrack in pairs(humanoid:GetPlayingAnimationTracks()) do
                    for _, attackAnim in pairs(ATTACK_ANIMATIONS) do
                        if animTrack.Animation.AnimationId == attackAnim then
                            -- Create unique key for this animation instance
                            local animKey = player.UserId .. "_" .. animTrack.Animation.AnimationId
                            
                            -- Only block once per animation play
                            if not blockedAnimations[animKey] then
                                blockAttack()
                                blockedAnimations[animKey] = true
                            end
                        end
                    end
                end
            end
            task.wait(0.1) -- Check less frequently
        end
    end)
end

-- Watch all current killers
for _, player in pairs(Players:GetPlayers()) do
    watchKiller(player)
end

-- Watch new players
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        watchKiller(player)
    end)
end)

-- Auto Generator Variables
local AutoGenEnabled = false

-- Auto Complete Generators
local function completeGenerators()
    if not AutoGenEnabled then return end
    
    local workspace = game:GetService("Workspace")
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("generator") or obj.Name:lower():find("gen") or obj.Name:lower():find("machine") then
            if obj:FindFirstChild("ClickDetector") then
                fireclickdetector(obj.ClickDetector)
            end
            
            if obj:FindFirstChild("Progress") then
                obj.Progress.Value = 100
            end
            
            if obj.Parent:FindFirstChild("ClickDetector") then
                fireclickdetector(obj.Parent.ClickDetector)
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
        task.wait(3)
        completeGenerators()
    end
end)

-- Handle players leaving
Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

Rayfield:Notify({
   Title = "Forsaken Hub Loaded!",
   Content = "Auto-block ready! Presses F to block.",
   Duration = 3,
   Image = 4483362458,
})