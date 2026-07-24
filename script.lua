local Solara = loadstring(game:HttpGet("https://raw.githubusercontent.com/solaralayouts/solara/main/init.lua"))()

local Window = Solara:CreateWindow({
    Title = "Nexora Hub",
    SubTitle = "by Nexora"
})

local PlayerTab = Window:CreateTab("Player", "🎮")

local npcFolder = workspace:WaitForChild("NPCs")

local function addHighlight(model)
    if not model:IsA("Model") then return end
    if model:FindFirstChild("Highlight") then return end

    local h = Instance.new("Highlight")
    h.FillColor = Color3.fromRGB(255, 0, 0)
    h.OutlineColor = Color3.new(1,1,1)
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = model
end

for _, npc in ipairs(npcFolder:GetChildren()) do
    addHighlight(npc)
end

npcFolder.ChildAdded:Connect(addHighlight)

local blocking = false

local function setBlocking(state)
    blocking = state
end

game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        setBlocking(true)
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        setBlocking(false)
    end
end)

for _, gen in ipairs(workspace.Generators:GetChildren()) do
    gen:SetAttribute("Progress", 100)
end