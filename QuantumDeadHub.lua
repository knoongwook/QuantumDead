-- Dead Rails Advanced Script (2025) - Keyless, Debugged, Simplified
-- Features: ESP, Aimbot, Auto-Farm, Teleport, NoClip, Auto-Revive, Anti-AFK
-- UI: Kavo Library (lightweight, compatible) with debug tab
-- Security: Minimal executor validation, robust error handling
-- Note: Use at your own risk. Scripts violate Roblox ToS.

-- Debug Logging
local DebugLog = {}
local function Log(message)
    table.insert(DebugLog, {Time = os.date("%H:%M:%S"), Message = tostring(message)})
    print("[DeadRailsScript] " .. message)
end

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Executor Detection
local ExecutorName = identifyexecutor and identifyexecutor() or "Unknown"
Log("Executor: " .. ExecutorName)

-- Helper: WaitForChild with Timeout
local function WaitForChild(parent, childName, timeout)
    timeout = timeout or 5
    local start = tick()
    local child = parent:FindFirstChild(childName)
    while not child and tick() - start < timeout do
        child = parent:FindFirstChild(childName)
        task.wait()
    end
    if not child then
        Log("WaitForChild timeout: " .. childName)
    end
    return child
end

-- Helper: Get Character Safely
local function GetCharacter()
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    local character = WaitForChild(LocalPlayer, "Character", 5)
    if character then
        local hrp = WaitForChild(character, "HumanoidRootPart", 2)
        local humanoid = WaitForChild(character, "Humanoid", 2)
        return character, hrp, humanoid
    end
    Log("Failed to get character")
    return nil, nil, nil
end

-- Load Kavo UI Library
local Library
local success, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
end)
if success then
    Library = result
    Log("Kavo UI loaded successfully")
else
    Log("Failed to load Kavo UI: " .. tostring(result))
    -- Fallback: Minimal UI
    Library = {
        CreateLib = function(title)
            local ui = {}
            local ScreenGui = Instance.new("ScreenGui")
            ScreenGui.Parent = game:GetService("CoreGui")
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(0, 400, 0, 300)
            Frame.Position = UDim2.new(0.5, -200, 0.5, -150)
            Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Frame.Parent = ScreenGui
            local Tabs = {}
            function ui:CreateTab(name)
                local tab = {Name = name, Elements = {}}
                table.insert(Tabs, tab)
                return {
                    CreateToggle = function(data)
                        local toggle = {Value = data.Default or false, Callback = data.Callback}
                        table.insert(tab.Elements, {Type = "Toggle", Text = data.Text, Toggle = toggle})
                        return toggle
                    end,
                    CreateButton = function(data)
                        table.insert(tab.Elements, {Type = "Button", Text = data.Text, Callback = data.Callback})
                    end,
                    CreateSlider = function(data)
                        local slider = {Value = data.Default or data.Min, Min = data.Min, Max = data.Max, Callback = data.Callback}
                        table.insert(tab.Elements, {Type = "Slider", Text = data.Text, Slider = slider})
                        return slider
                    end,
                    CreateDropdown = function(data)
                        local dropdown = {Value = data.Default, Options = data.Values, Callback = data.Callback}
                        table.insert(tab.Elements, {Type = "Dropdown", Text = data.Text, Dropdown = dropdown})
                        return dropdown
                    end,
                    CreateLabel = function(data)
                        table.insert(tab.Elements, {Type = "Label", Text = data.Text})
                    end
                }
            end
            function ui:Notify(data)
                print("[Notify] " .. data.Title .. ": " .. data.Content)
            end
            return ui
        end
    }
end

-- Initialize UI
local Window = Library.CreateLib("Dead Rails Script | 2025")
local Tabs = {
    Main = Window:CreateTab("Main"),
    Combat = Window:CreateTab("Combat"),
    Farming = Window:CreateTab("Farming"),
    Mobility = Window:CreateTab("Mobility"),
    Visuals = Window:CreateTab("Visuals"),
    Debug = Window:CreateTab("Debug")
}

-- Notification System
local function Notify(title, content, duration)
    pcall(function()
        Window:Notify({
            Title = title,
            Content = content,
            Duration = duration or 5
        })
    end)
end

-- Debug Tab
Tabs.Debug:CreateLabel({Text = "Executor: " .. ExecutorName})
local DebugLabel = Tabs.Debug:CreateLabel({Text = "Debug Log: Loading..."})
local function UpdateDebugLog()
    local logText = "Debug Log:\n"
    for _, log in pairs(DebugLog) do
        logText = logText .. "[" .. log.Time .. "] " .. log.Message .. "\n"
    end
    DebugLabel.Text = logText
end
RunService.Heartbeat:Connect(UpdateDebugLog)

-- Status Label
local StatusLabel = Tabs.Main:CreateLabel({Text = "Status: Initializing..."})
local function UpdateStatus()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local serverTime = os.date("%H:%M:%S", os.time())
    local activeFeatures = {}
    if ESP.Enabled then table.insert(activeFeatures, "ESP") end
    if Aimbot.Enabled then table.insert(activeFeatures, "Aimbot") end
    if AutoFarm.Enabled then table.insert(activeFeatures, "Auto-Farm") end
    if NoClip.Enabled then table.insert(activeFeatures, "NoClip") end
    if Fly.Enabled then table.insert(activeFeatures, "Fly") end
    StatusLabel.Text = "FPS: " .. fps .. " | Server Time: " .. serverTime .. " | Active: " .. (#activeFeatures > 0 and table.concat(activeFeatures, ", ") or "None")
end
RunService.Heartbeat:Connect(UpdateStatus)

-- ESP Function
local ESP = {Enabled = false, Players = false, Items = false}
local ESPInstances = {}
local function CreateESP(instance, color, name)
    local Highlight = Instance.new("Highlight")
    Highlight.Adornee = instance
    Highlight.FillColor = color
    Highlight.OutlineColor = color
    Highlight.FillTransparency = 0.5
    Highlight.Parent = instance
    return Highlight
end

local function UpdateESP()
    for _, esp in pairs(ESPInstances) do
        esp:Destroy()
    end
    ESPInstances = {}
    if ESP.Enabled then
        local character, hrp = GetCharacter()
        if not hrp then return end
        if ESP.Players then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    ESPInstances[player] = CreateESP(player.Character, Color3.fromRGB(0, 255, 0), player.Name)
                end
            end
        end
        if ESP.Items then
            local runtimeItems = WaitForChild(Workspace, "RuntimeItems", 2)
            if runtimeItems then
                for _, item in pairs(runtimeItems:GetChildren()) do
                    if item and item.PrimaryPart and item.Parent == runtimeItems then
                        ESPInstances[item] = CreateESP(item, Color3.fromRGB(255, 255, 0), item.Name)
                    end
                end
            end
        end
    end
end

-- Aimbot Function
local Aimbot = {Enabled = false, FOV = 100, Smoothness = 0.1, TargetPart = "Head"}
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = Aimbot.FOV
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Thickness = 2
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

local function GetClosestPlayer()
    local character, hrp = GetCharacter()
    if not hrp then return nil end
    local closest, distance = nil, Aimbot.FOV
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Aimbot.TargetPart) then
            local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character[Aimbot.TargetPart].Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                if dist < distance then
                    closest = player
                    distance = dist
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(Aimbot.TargetPart) then
            local screenPos = Camera:WorldToViewportPoint(target.Character[Aimbot.TargetPart].Position)
            local mousePos = UserInputService:GetMouseLocation()
            if mousemoverel then
                mousemoverel((screenPos.X - mousePos.X) * Aimbot.Smoothness, (screenPos.Y - mousePos.Y) * Aimbot.Smoothness)
            else
                Log("Aimbot: mousemoverel not supported")
            end
        end
    end
end)

-- Auto-Farm Function
local AutoFarm = {Enabled = false, Items = false, AutoRevive = false}
local function AutoCollectItems()
    if AutoFarm.Items then
        local character, hrp = GetCharacter()
        if not hrp then return end
        local runtimeItems = WaitForChild(Workspace, "RuntimeItems", 2)
        if not runtimeItems then return end
        for _, item in pairs(runtimeItems:GetChildren()) do
            if item and item.PrimaryPart and item.Parent == runtimeItems then
                pcall(function()
                    hrp.CFrame = item.PrimaryPart.CFrame
                    local dragRemote = WaitForChild(ReplicatedStorage.Shared.Remotes, "Drag", 2)
                    if dragRemote then
                        dragRemote.RequestStartDrag:FireServer(item)
                        Notify("Auto-Farm", "Collected item: " .. item.Name, 3)
                    end
                    task.wait(0.1)
                end)
            end
        end
    end
end

local function AutoRevive()
    if AutoFarm.AutoRevive then
        local character, _, humanoid = GetCharacter()
        if humanoid and humanoid.Health <= 0 then
            pcall(function()
                local reviveRemote = WaitForChild(ReplicatedStorage.Shared.Remotes, "Revive", 2)
                if reviveRemote then
                    reviveRemote:FireServer()
                    Notify("Auto-Farm", "Revived player", 3)
                end
            end)
        end
    end
end

-- Anti-AFK Function
local AntiAFK = {Enabled = false}
RunService.Heartbeat:Connect(function()
    if AntiAFK.Enabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Teleport Function
local function TeleportToItem(itemName)
    pcall(function()
        local runtimeItems = WaitForChild(Workspace, "RuntimeItems", 2)
        if not runtimeItems then return end
        local item = runtimeItems:FindFirstChild(itemName)
        if item and item.PrimaryPart then
            local character, hrp = GetCharacter()
            if hrp then
                hrp.CFrame = item.PrimaryPart.CFrame
                Notify("Teleport", "Teleported to: " .. itemName, 3)
            end
        else
            Notify("Teleport", "Item not found: " .. itemName, 3)
        end
    end)
end

-- NoClip Function
local NoClip = {Enabled = false}
RunService.Stepped:Connect(function()
    if NoClip.Enabled then
        local character = GetCharacter()
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Fly Function
local Fly = {Enabled = false, Speed = 50}
local function ToggleFly()
    local character, hrp = GetCharacter()
    if not hrp then return end
    if Fly.Enabled then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = hrp
        while Fly.Enabled and hrp.Parent do
            local moveDirection = Vector3.new(
                UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0,
                UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and -1 or 0,
                UserInputService:IsKeyDown(Enum.KeyCode.W) and -1 or UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0
            ).Unit * Fly.Speed
            bodyVelocity.Velocity = Camera.CFrame:VectorToWorldSpace(moveDirection)
            task.wait()
        end
        bodyVelocity:Destroy()
    end
end

-- UI Elements
-- Main Tab
Tabs.Main:CreateLabel({Text = "Welcome to Dead Rails Script!"})

-- Combat Tab
Tabs.Combat:CreateToggle({
    Text = "Enable Aimbot",
    Default = false,
    Callback = function(value)
        Aimbot.Enabled = value
        FOVCircle.Visible = value
        Notify("Aimbot", value and "Aimbot Enabled" or "Aimbot Disabled", 3)
        Log("Aimbot set to: " .. tostring(value))
    end
})
Tabs.Combat:CreateSlider({
    Text = "FOV Radius",
    Default = 100,
    Min = 50,
    Max = 300,
    Callback = function(value)
        Aimbot.FOV = value
        FOVCircle.Radius = value
    end
})
Tabs.Combat:CreateSlider({
    Text = "Smoothness",
    Default = 0.1,
    Min = 0.01,
    Max = 0.5,
    Callback = function(value)
        Aimbot.Smoothness = value
    end
})
Tabs.Combat:CreateDropdown({
    Text = "Target Part",
    Default = "Head",
    Values = {"Head", "Torso", "HumanoidRootPart"},
    Callback = function(value)
        Aimbot.TargetPart = value
    end
})

-- Farming Tab
Tabs.Farming:CreateToggle({
    Text = "Enable Auto-Farm",
    Default = false,
    Callback = function(value)
        AutoFarm.Enabled = value
        if value then
            while AutoFarm.Enabled do
                AutoCollectItems()
                AutoRevive()
                task.wait(0.5)
            end
        end
        Log("Auto-Farm set to: " .. tostring(value))
    end
})
Tabs.Farming:CreateToggle({
    Text = "Auto-Collect Items",
    Default = false,
    Callback = function(value)
        AutoFarm.Items = value
    end
})
Tabs.Farming:CreateToggle({
    Text = "Auto-Revive",
    Default = false,
    Callback = function(value)
        AutoFarm.AutoRevive = value
    end
})
Tabs.Farming:CreateToggle({
    Text = "Anti-AFK",
    Default = false,
    Callback = function(value)
        AntiAFK.Enabled = value
        Notify("Anti-AFK", value and "Anti-AFK Enabled" or "Anti-AFK Disabled", 3)
    end
})

local items = {}
local runtimeItems = WaitForChild(Workspace, "RuntimeItems", 2)
if runtimeItems then
    for _, item in pairs(runtimeItems:GetChildren()) do
        table.insert(items, item.Name)
    end
end
Tabs.Farming:CreateDropdown({
    Text = "Teleport to Item",
    Default = items[1] or "None",
    Values = items,
    Callback = function(value)
        TeleportToItem(value)
    end
})

-- Mobility Tab
Tabs.Mobility:CreateToggle({
    Text = "Enable NoClip",
    Default = false,
    Callback = function(value)
        NoClip.Enabled = value
        Notify("NoClip", value and "NoClip Enabled" or "NoClip Disabled", 3)
        Log("NoClip set to: " .. tostring(value))
    end
})
Tabs.Mobility:CreateToggle({
    Text = "Enable Fly",
    Default = false,
    Callback = function(value)
        Fly.Enabled = value
        pcall(ToggleFly)
        Notify("Fly", value and "Fly Enabled" or "Fly Disabled", 3)
        Log("Fly set to: " .. tostring(value))
    end
})
Tabs.Mobility:CreateSlider({
    Text = "Fly Speed",
    Default = 50,
    Min = 10,
    Max = 100,
    Callback = function(value)
        Fly.Speed = value
    end
})
Tabs.Mobility:CreateSlider({
    Text = "Walk Speed",
    Default = 16,
    Min = 16,
    Max = 100,
    Callback = function(value)
        pcall(function()
            local _, _, humanoid = GetCharacter()
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end)
    end
})

-- Visuals Tab
Tabs.Visuals:CreateToggle({
    Text = "Enable ESP",
    Default = false,
    Callback = function(value)
        ESP.Enabled = value
        pcall(UpdateESP)
        Notify("ESP", value and "ESP Enabled" or "ESP Disabled", 3)
        Log("ESP set to: " .. tostring(value))
    end
})
Tabs.Visuals:CreateToggle({
    Text = "Player ESP",
    Default = false,
    Callback = function(value)
        ESP.Players = value
        pcall(UpdateESP)
    end
})
Tabs.Visuals:CreateToggle({
    Text = "Item ESP",
    Default = false,
    Callback = function(value)
        ESP.Items = value
        pcall(UpdateESP)
    end
})
Tabs.Visuals:CreateButton({
    Text = "Remove Fog",
    Callback = function()
        pcall(function()
            Lighting.FogEnd = 100000
            Notify("Visuals", "Fog Removed", 3)
        end)
    end
})
Tabs.Visuals:CreateButton({
    Text = "Full Bright",
    Callback = function()
        pcall(function()
            Lighting.Brightness = 2
            Lighting.GlobalShadows = false
            Notify("Visuals", "Full Bright Enabled", 3)
        end)
    end
})

-- Refresh Item Dropdown
if runtimeItems then
    runtimeItems.ChildAdded:Connect(function()
        pcall(function()
            items = {}
            for _, item in pairs(runtimeItems:GetChildren()) do
                table.insert(items, item.Name)
            end
            Tabs.Farming:FindFirstChild("Teleport to Item").Dropdown.Options = items
        end)
    end)
    runtimeItems.ChildRemoved:Connect(function()
        pcall(function()
            items = {}
            for _, item in pairs(runtimeItems:GetChildren()) do
                table.insert(items, item.Name)
            end
            Tabs.Farming:FindFirstChild("Teleport to Item").Dropdown.Options = items
        end)
    end)
end

-- Character Respawn Handling
LocalPlayer.CharacterAdded:Connect(function()
    pcall(function()
        Notify("System", "Character respawned, updating features", 3)
        if ESP.Enabled then UpdateESP() end
        if Fly.Enabled then ToggleFly() end
        Log("Character respawned")
    end)
end)

-- Debug and Anti-Detect
local AntiDetect = {Enabled = false}
Tabs.Debug:CreateToggle({
    Text = "Enable Anti-Detect",
    Default = false,
    Callback = function(value)
        AntiDetect.Enabled = value
        if value then
            Aimbot.Enabled = false
            Notify("Anti-Detect", "Disabled Aimbot for safety", 3)
        end
        Notify("Anti-Detect", value and "Anti-Detect Enabled" or "Anti-Detect Disabled", 3)
        Log("Anti-Detect set to: " .. tostring(value))
    end
})

-- Performance Optimization
Tabs.Debug:CreateButton({
    Text = "FPS Boost",
    Callback = function()
        pcall(function()
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                end
            end
            Notify("Performance", "FPS Boost Applied", 3)
            Log("FPS Boost applied")
        end)
    end
})

-- Notify Initialization
Notify("System", "Script initialized successfully", 5)
Log("Script initialized")
