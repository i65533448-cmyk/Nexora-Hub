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

-- Function to simulate F key press using VirtualUser
local function pressF()
    local VirtualUser = game:GetService("VirtualUser")
    VirtualUser:CaptureController()
    VirtualUser:ClickButton1(Vector2.new(0, 0))
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
   end,
})

-- Auto Block Function - Detects killer running state and proximity
spawn(function()
    local myChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local myHRP = myChar:WaitForChild("HumanoidRootPart")
    
    game:GetService("RunService").Heartbeat:Connect(function()
        if not AutoBlockEnabled then return end
        
        if not myChar or not myHRP then return end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local killerHRP = player.Character:FindFirstChild("HumanoidRootPart")
                local killerHumanoid = player.Character:FindFirstChild("Humanoid")
                
                if killerHRP and killerHumanoid then
                    local distance = (killerHRP.Position - myHRP.Position).Magnitude
                    local state = killerHumanoid:GetState()
                    
                    -- If killer is running and close, block
                    if state == Enum.HumanoidStateType.Running and distance < 30 then
                        pressF()
                    end
                end
            end
        end
    end)
end)

-- Auto Generator Variables
local AutoGenEnabled = false

-- Auto Complete Generators
local function completeGenerators()
    if not AutoGenEnabled then return end
    
    local workspace = game:GetService("Workspace")
    
    -- Look for generator objects
    for _, obj in pairs(workspace:GetDescendants()) do
        -- Check various possible generator names
        if obj.Name:lower():find("generator") or obj.Name:lower():find("gen") or obj.Name:lower():find("machine") then
            -- Try clicking it
            if obj:FindFirstChild("ClickDetector") then
                fireclickdetector(obj.ClickDetector)
            end
            
            -- Try setting progress
            if obj:FindFirstChild("Progress") then
                obj.Progress.Value = 100
            end
            
            -- Try finding and clicking parent
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

-- Handle new players joining
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
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
   Content = "Auto-block will trigger when killer is running and nearby!",
   Duration = 3,
   Image = 4483362458,
})