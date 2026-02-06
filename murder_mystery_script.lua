-- Roblox Murder Mystery Script - Rayfield UI Version
print("[jassy's mm2] boot")

local function _showInjectedPing()
    pcall(function()
        local Players = game:GetService("Players")
        local lp = Players.LocalPlayer
        if not lp then return end

        local pg = lp:WaitForChild("PlayerGui")
        local sg = pg:FindFirstChild("JassyMM2_Ping")
        if not sg then
            sg = Instance.new("ScreenGui")
            sg.Name = "JassyMM2_Ping"
            sg.ResetOnSpawn = false
            sg.Parent = pg
        end

        if sg:FindFirstChild("Label") then
            return
        end

        local lbl = Instance.new("TextLabel")
        lbl.Name = "Label"
        lbl.BackgroundTransparency = 0.35
        lbl.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
        lbl.BorderSizePixel = 0
        lbl.Size = UDim2.new(0, 220, 0, 26)
        lbl.Position = UDim2.new(0, 12, 0, 12)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.Text = "♡ jassy's mm2 injected ♡"
        lbl.Parent = sg

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 10)
        c.Parent = lbl
    end)
end

_showInjectedPing()

local function _showError(title, msg)
    pcall(function()
        local Players = game:GetService("Players")
        local lp = Players.LocalPlayer
        local parent = game:GetService("CoreGui")
        if lp then
            local pg = lp:FindFirstChild("PlayerGui")
            if pg then
                parent = pg
            end
        end

        local sg = Instance.new("ScreenGui")
        sg.Name = "JassyMM2_Error"
        sg.ResetOnSpawn = false
        sg.Parent = parent

        local f = Instance.new("Frame")
        f.Size = UDim2.new(0, 420, 0, 140)
        f.Position = UDim2.new(0.5, -210, 0.2, 0)
        f.BackgroundColor3 = Color3.fromRGB(30, 10, 20)
        f.BorderSizePixel = 0
        f.Parent = sg

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 12)
        c.Parent = f

        local s = Instance.new("UIStroke")
        s.Thickness = 1
        s.Transparency = 0.4
        s.Color = Color3.fromRGB(255, 105, 180)
        s.Parent = f

        local t = Instance.new("TextLabel")
        t.BackgroundTransparency = 1
        t.Size = UDim2.new(1, -20, 0, 28)
        t.Position = UDim2.new(0, 10, 0, 8)
        t.Font = Enum.Font.GothamBold
        t.TextSize = 18
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.TextColor3 = Color3.fromRGB(255, 255, 255)
        t.Text = tostring(title or "Error")
        t.Parent = f

        local b = Instance.new("TextLabel")
        b.BackgroundTransparency = 1
        b.Size = UDim2.new(1, -20, 1, -46)
        b.Position = UDim2.new(0, 10, 0, 40)
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.TextYAlignment = Enum.TextYAlignment.Top
        b.TextWrapped = true
        b.TextColor3 = Color3.fromRGB(255, 220, 235)
        b.Text = tostring(msg or "")
        b.Parent = f
    end)
end

local Rayfield
do
    local ok, res = pcall(function()
        local src
        if typeof(game) == "Instance" and typeof(game.HttpGet) == "function" then
            src = game:HttpGet("https://sirius.menu/rayfield")
        elseif typeof(game) == "Instance" and typeof(game.HttpGetAsync) == "function" then
            src = game:HttpGetAsync("https://sirius.menu/rayfield")
        else
            error("HttpGet/HttpGetAsync not available")
        end

        local fn = loadstring(src)
        if typeof(fn) ~= "function" then
            error("loadstring failed")
        end
        return fn()
    end)

    if not ok or not res then
        warn("[jassy's mm2] Rayfield failed to load:", res)
        _showError("jassy's mm2", "Rayfield failed to load.\n\n" .. tostring(res))
        return
    end
    Rayfield = res
end

-- Play opening sound effect
local SoundService = game:GetService("SoundService")
local OpeningSound = Instance.new("Sound")
OpeningSound.SoundId = "rbxassetid://132529299748496" -- Your opening sound effect
OpeningSound.Volume = 0.5
OpeningSound.Parent = SoundService
pcall(function()
    OpeningSound:Play()
end)

local Window
do
    local ok, err = pcall(function()
        Window = Rayfield:CreateWindow({
           Name = "MM2 Script",
           LoadingTitle = "nucax",
           LoadingSubtitle = "https://github.com/nucax",
           ConfigurationSaving = {
              Enabled = false,
           },
           Background = "rbxassetid://75487938851287" -- Your custom background image
        })
    end)
    if not ok or not Window then
        _showError("jassy's mm2", "Rayfield window failed to create.\n\n" .. tostring(err))
        return
    end
end

local Tab = Window:CreateTab("Main", 4483362458)

Tab:CreateLabel("MM2 Script")
Tab:CreateLabel("This is the classic Rayfield UI loader.")

Tab:CreateButton({
    Name = "Close UI",
    Callback = function()
        pcall(function()
            Rayfield:Destroy()
        end)
    end,
})

return

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Variables
local LockedTarget = nil
local ESP_Objects = {}
local IsLocked = false

-- ESP Folder
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "MM2_ESP_Highlights"
ESPFolder.Parent = game.CoreGui

-- Utility Functions
local function GetDistance(Position)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return math.huge end
    return (LocalPlayer.Character.HumanoidRootPart.Position - Position).Magnitude
end

local function GetClosestPlayer()
    local ClosestPlayer = nil
    local ClosestDistance = getgenv().LockOnFOV
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.Humanoid.Health > 0 then
            local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Player.Character.HumanoidRootPart.Position)
            if OnScreen then
                local Distance = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if Distance < ClosestDistance then
                    ClosestDistance = Distance
                    ClosestPlayer = Player
                end
            end
        end
    end
    
    return ClosestPlayer
end

-- ESP Functions
local function CreateESP(Player)
    if ESP_Objects[Player] then return end
    
    local Character = Player.Character
    if not Character then return end
    
    local ESP = {}
    
    -- Highlight
    local Highlight = Instance.new("Highlight")
    Highlight.Name = Player.Name .. "_ESP"
    Highlight.FillTransparency = 0.5
    Highlight.OutlineTransparency = 0
    Highlight.FillColor = getgenv().ESPColor
    Highlight.Parent = ESPFolder
    
    -- Billboard for info
    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "ESP_Billboard"
    Billboard.Size = UDim2.new(0, 200, 0, 100)
    Billboard.StudsOffset = Vector3.new(0, 3, 0)
    Billboard.AlwaysOnTop = true
    Billboard.Parent = Character:FindFirstChild("Head") or Character:FindFirstChild("HumanoidRootPart")
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundTransparency = 1
    Frame.Parent = Billboard
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Name = "NameLabel"
    NameLabel.Size = UDim2.new(1, 0, 0, 20)
    NameLabel.Position = UDim2.new(0, 0, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = Player.Name
    NameLabel.TextColor3 = getgenv().ESPColor
    NameLabel.TextStrokeTransparency = 0.5
    NameLabel.TextScaled = true
    NameLabel.Font = Enum.Font.SourceSansBold
    NameLabel.Parent = Frame
    
    local DistanceLabel = Instance.new("TextLabel")
    DistanceLabel.Name = "DistanceLabel"
    DistanceLabel.Size = UDim2.new(1, 0, 0, 15)
    DistanceLabel.Position = UDim2.new(0, 0, 0, 20)
    DistanceLabel.BackgroundTransparency = 1
    DistanceLabel.Text = ""
    DistanceLabel.TextColor3 = getgenv().ESPColor
    DistanceLabel.TextStrokeTransparency = 0.5
    DistanceLabel.TextScaled = true
    DistanceLabel.Font = Enum.Font.SourceSans
    DistanceLabel.Parent = Frame
    
    local HealthLabel = Instance.new("TextLabel")
    HealthLabel.Name = "HealthLabel"
    HealthLabel.Size = UDim2.new(1, 0, 0, 15)
    HealthLabel.Position = UDim2.new(0, 0, 0, 35)
    HealthLabel.BackgroundTransparency = 1
    HealthLabel.Text = ""
    HealthLabel.TextColor3 = getgenv().ESPColor
    HealthLabel.TextStrokeTransparency = 0.5
    HealthLabel.TextScaled = true
    HealthLabel.Font = Enum.Font.SourceSans
    HealthLabel.Parent = Frame
    
    ESP.Highlight = Highlight
    ESP.Billboard = Billboard
    ESP.NameLabel = NameLabel
    ESP.DistanceLabel = DistanceLabel
    ESP.HealthLabel = HealthLabel
    
    ESP_Objects[Player] = ESP
end

local function UpdateESP(Player)
    local ESP = ESP_Objects[Player]
    if not ESP then return end
    
    local Character = Player.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then
        RemoveESP(Player)
        return
    end
    
    -- Update highlight
    if ESP.Highlight then
        ESP.Highlight.Adornee = Character
        ESP.Highlight.FillColor = getgenv().ESPColor
        ESP.Highlight.Enabled = getgenv().ESPEnabled
    end
    
    -- Update name
    if ESP.NameLabel then
        ESP.NameLabel.Text = Player.Name
        ESP.NameLabel.TextColor3 = getgenv().ESPColor
        ESP.NameLabel.Visible = getgenv().ESPEnabled
    end
    
    -- Update distance
    if ESP.DistanceLabel then
        local Distance = GetDistance(Character.HumanoidRootPart.Position)
        ESP.DistanceLabel.Text = string.format("Distance: %.0f", Distance)
        ESP.DistanceLabel.TextColor3 = getgenv().ESPColor
        ESP.DistanceLabel.Visible = getgenv().ESPEnabled
    end
    
    -- Update health
    if ESP.HealthLabel and Character:FindFirstChild("Humanoid") then
        local Health = Character.Humanoid.Health
        local MaxHealth = Character.Humanoid.MaxHealth
        ESP.HealthLabel.Text = string.format("Health: %.0f/%.0f", Health, MaxHealth)
        ESP.HealthLabel.TextColor3 = getgenv().ESPColor
        ESP.HealthLabel.Visible = getgenv().ESPEnabled
    end
    
    -- Update billboard
    if ESP.Billboard then
        ESP.Billboard.Enabled = getgenv().ESPEnabled
    end
end

local function RemoveESP(Player)
    local ESP = ESP_Objects[Player]
    if ESP then
        if ESP.Highlight then ESP.Highlight:Destroy() end
        if ESP.Billboard then ESP.Billboard:Destroy() end
        ESP_Objects[Player] = nil
    end
end

-- Lock-On Functions
local function LockOn(Player)
    if not Player or not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    LockedTarget = Player
    IsLocked = true
end

local function Unlock()
    LockedTarget = nil
    IsLocked = false
end

local function UpdateLockOn()
    if not getgenv().LockOnEnabled then
        Unlock()
        return
    end
    
    if LockedTarget and LockedTarget.Character and LockedTarget.Character:FindFirstChild("HumanoidRootPart") then
        if LockedTarget.Character:FindFirstChild("Humanoid").Health <= 0 then
            Unlock()
            return
        end
        
        local TargetPosition = LockedTarget.Character.HumanoidRootPart.Position
        local CurrentCFrame = Camera.CFrame
        local LookAt = CFrame.new(CurrentCFrame.Position, TargetPosition)
        Camera.CFrame = CurrentCFrame:Lerp(LookAt, getgenv().LockOnSmoothness)
    else
        Unlock()
    end
end

-- Input Handling
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    
    if Input.KeyCode == Enum.KeyCode.Q and getgenv().LockOnEnabled then
        if IsLocked then
            Unlock()
        else
            local Target = GetClosestPlayer()
            if Target then
                LockOn(Target)
            end
        end
    end
    
    -- K key to toggle GUI
    if Input.KeyCode == Enum.KeyCode.K then
        if Window then
            Window:Toggle()
        end
    end
end)

-- Player Management
Players.PlayerAdded:Connect(function(Player)
    if Player ~= LocalPlayer then
        Player.CharacterAdded:Connect(function(Character)
            if getgenv().ESPEnabled then
                CreateESP(Player)
            end
        end)
        
        if getgenv().ESPEnabled then
            CreateESP(Player)
        end
    end
end)

Players.PlayerRemoving:Connect(function(Player)
    RemoveESP(Player)
    if LockedTarget == Player then
        Unlock()
    end
end)

-- Initialize ESP for existing players
for _, Player in pairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        Player.CharacterAdded:Connect(function(Character)
            if getgenv().ESPEnabled then
                CreateESP(Player)
            end
        end)
        
        if getgenv().ESPEnabled then
            CreateESP(Player)
        end
    end
end

-- Main Update Loop
RunService.Heartbeat:Connect(function()
    -- Update ESP for all players
    for Player, ESP in pairs(ESP_Objects) do
        UpdateESP(Player)
    end
    
    -- Update lock-on
    UpdateLockOn()
end)

-- Cleanup on character remove
LocalPlayer.CharacterAdded:Connect(function(Character)
    -- Reinitialize if needed
end)

print("Murder Mystery Script Loaded with Rayfield UI!")
print("Press Q to lock onto nearest player")
print("Use the Rayfield UI to toggle features")
