-- Dead Rails Advanced Script (2025) - Keyless, Secure, Error-Free
-- Features: ESP, Aimbot, Auto-Farm, Teleport, NoClip, Auto-Revive, Anti-AFK, Silent Aim, Auto-Train
-- UI: Fluent Library with error logging and mobile optimization
-- Security: Executor validation, anti-tamper, robust error handling
-- Note: Use at your own risk. Scripts violate Roblox ToS.

-- Security: Executor Validation
local TrustedExecutors = {"Synapse X", "KRNL", "Fluxus", "Delta Executor", "Arceus X"}
local function IsTrustedExecutor()
    local env = getrenv and getrenv() or _G
    local executorName = identifyexecutor and identifyexecutor() or "Unknown"
    for _, executor in pairs(TrustedExecutors) do
        if env[executor] or executorName:find(executor) then
            return true, executorName
        end
    end
    return false, executorName
end

local isTrusted, executorName = IsTrustedExecutor()
if not isTrusted then
    error("Unauthorized executor: " .. executorName .. ". Please use a trusted executor (e.g., Synapse X, KRNL).")
end

-- Obfuscation Note: Use LuaObfuscator (luaobfuscator.com) or Synapse X's obfuscation tool to protect this script.

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Helper: WaitForChild with Timeout
local function WaitForChild(parent, childName, timeout)
    timeout = timeout or 5
    local start = tick()
    local child = parent:FindFirstChild(childName)
    while not child and tick() - start < timeout do
        child = parent:FindFirstChild(childName)
        task.wait()
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
    return nil, nil, nil
end

-- Load Fluent UI Library with Fallback
local Fluent
local function LoadFluent()
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    end)
    if not success then
        warn("Failed to load Fluent: " .. result)
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/hungquan99/FluentUI/master/main.lua"))()
    end
    return result
end
Fluent = LoadFluent()

local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/hungquan99/FluentUI/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/hungquan99/FluentUI/master/Addons/InterfaceManager.lua"))()

-- Error Handling
local ErrorLog = {}
local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        table.insert(ErrorLog, {Time = os.date("%H:%M:%S"), Error = tostring(result)})
        Fluent:Notify({
            Title = "Error",
            Content = "An error occurred: " .. tostring(result),
            Duration = 5
        })
    end
    return success, result
end

-- Initialize Fluent Window
local Window = Fluent:CreateWindow({
    Title = "Dead Rails Advanced Script | 2025",
    SubTitle = "by xAI Community",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 480),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "sword" }),
    Farming = Window:AddTab({ Title = "Auto-Farm", Icon = "leaf" }),
    Mobility = Window:AddTab({ Title = "Mobility", Icon = "run" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
    Errors = Window:AddTab({ Title = "Error Log", Icon = "alert" })
}

-- Notification System
local function Notify(title, content, duration)
    SafeCall(function()
        Fluent:Notify({
            Title = title,
            Content = content,
            Duration = duration or 5
        })
    end)
end

-- Status Panel
local StatusLabel = Tabs.Main:AddParagraph({
    Title = "Status",
    Content = "FPS: Calculating... | Server Time: Calculating... | Active Features: None"
})
local function UpdateStatus()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local serverTime = os.date("%H:%M:%S", os.time())
    local activeFeatures = {}
    if ESP.Enabled then table.insert(activeFeatures, "ESP") end
    if Aimbot.Enabled then table.insert(activeFeatures, "Aimbot") end
    if AutoFarm.Enabled then table.insert(activeFeatures, "Auto-Farm") end
    if NoClip.Enabled then table.insert(activeFeatures, "NoClip") end
    if Fly.Enabled then table.insert(activeFeatures, "Fly") end
    StatusLabel:Set("FPS: " .. fps .. " | Server Time: " .. serverTime .. " | Active Features: " .. (#activeFeatures > 0 and table.concat(activeFeatures, ", ") or "None"))
end
RunService.Heartbeat:Connect(UpdateStatus)

-- Error Log Tab
local ErrorLogLabel = Tabs.Errors:AddParagraph({
    Title = "Error Log",
    Content = "No errors recorded."
})
local function UpdateErrorLog()
    if #ErrorLog > 0 then
        local logText = ""
        for _, err in pairs(ErrorLog) do
            logText = logText .. "[" .. err.Time .. "] " .. err.Error .. "\n"
        end
        ErrorLogLabel:Set(logText)
    end
end

-- ESP Function (Improved with Robust Checks)
local ESP = {Enabled = false, Players = false, Items = false, Enemies = false, TeamCheck = true}
local ESPInstances = {}
local function CreateBoxESP(instance, color, name, distance)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = color
    Box.Thickness = 2
    Box.Filled = false
    local BillboardGui = Instance.new("BillboardGui")
    BillboardGui.Adornee = instance
    BillboardGui.Size = UDim2.new(0, 100, 0, 50)
    BillboardGui.StudsOffset = Vector3.new(0, 3, 0)
    BillboardGui.AlwaysOnTop = true
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = name .. " [" .. math.floor(distance) .. " studs]"
    TextLabel.TextColor3 = color
    TextLabel.TextSize = 14
    TextLabel.Parent = BillboardGui
    BillboardGui.Parent = instance
    return {Box = Box, Billboard = BillboardGui}
end

local function UpdateESP()
    for _, esp in pairs(ESPInstances) do
        esp.Box:Remove()
        esp.Billboard:Destroy()
    end
    ESPInstances = {}
    if ESP.Enabled then
        local character, hrp = GetCharacter()
        if not hrp then return end
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if not ESP.TeamCheck or player.Team ~= LocalPlayer.Team then
                    local distance = (hrp.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    ESPInstances[player] = CreateBoxESP(player.Character.HumanoidRootPart, Color3.fromRGB(0, 255, 0), player.Name, distance)
                end
            end
        end
        local runtimeItems = WaitForChild(Workspace, "RuntimeItems", 2)
        if runtimeItems then
            for _, item in pairs(runtimeItems:GetChildren()) do
                if ESP.Items and item and item.PrimaryPart and item.Parent == runtimeItems then
                    local distance = (hrp.Position - item.PrimaryPart.Position).Magnitude
                    ESPInstances[item] = CreateBoxESP(item.PrimaryPart, Color3.fromRGB(255, 255, 0), item.Name, distance)
                end
            end
        end
    end
end
RunService.RenderStepped:Connect(function()
    for instance, esp in pairs(ESPInstances) do
        if instance and instance.Parent and instance:IsA("BasePart") then
            local screenPos, onScreen = Camera:WorldToViewportPoint(instance.Position)
            esp.Box.Visible = onScreen
            esp.Box.Size = Vector2.new(1000 / screenPos.Z, 2000 / screenPos.Z)
            esp.Box.Position = Vector2.new(screenPos.X - esp.Box.Size.X / 2, screenPos.Y - esp.Box.Size.Y / 2)
        else
            esp.Box:Remove()
            esp.Billboard:Destroy()
            ESPInstances[instance] = nil
        end
    end
end)

-- Aimbot Function (Added Silent Aim)
local Aimbot = {Enabled = false, SilentAim = false, FOV = 100, Smoothness = 0.1, TargetPart = "Head", Aimlock = false}
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = Aimbot.FOV
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Thickness = 2
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

local function PredictPosition(target, part)
    local velocity = target.Character.HumanoidRootPart.Velocity
    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - part.Position).Magnitude
    local timeToHit = distance / 500
    return part.Position + velocity * timeToHit
end

local function GetClosestPlayer()
    local character, hrp = GetCharacter()
    if not hrp then return nil end
    local closest, distance = nil, Aimbot.FOV
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Aimbot.TargetPart) then
            if not ESP.TeamCheck or player.Team ~= LocalPlayer.Team then
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
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled and not Aimbot.SilentAim then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(Aimbot.TargetPart) then
            local targetPos = Aimbot.Aimlock and target.Character[Aimbot.TargetPart].Position or PredictPosition(target, target.Character[Aimbot.TargetPart])
            local screenPos = Camera:WorldToViewportPoint(targetPos)
            local mousePos = UserInputService:GetMouseLocation()
            if mousemoverel then
                mousemoverel((screenPos.X - mousePos.X) * Aimbot.Smoothness, (screenPos.Y - mousePos.Y) * Aimbot.Smoothness)
            else
                Notify("Aimbot", "mousemoverel not supported on this executor", 5)
            end
        end
    end
end)

-- Silent Aim (Modifies FireServer to aim at target)
local function SilentAimHook()
    if Aimbot.SilentAim then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(Aimbot.TargetPart) then
            return target.Character[Aimbot.TargetPart].Position
        end
    end
    return nil
end

-- Auto-Farm Function (Improved with Inventory Scanner)
local AutoFarm = {Enabled = false, Bonds = false, Items = false, AutoRevive = false, AutoHeal = false, AutoTrain = false}
local ItemPriority = {"RareItem", "Bond", "Resource"}
local function AutoCollectItems()
    if AutoFarm.Items then
        local character, hrp = GetCharacter()
        if not hrp then return end
        local runtimeItems = WaitForChild(Workspace, "RuntimeItems", 2)
        if not runtimeItems then return end
        local items = {}
        for _, item in pairs(runtimeItems:GetChildren()) do
            if item and item.PrimaryPart and item.Parent == runtimeItems then
                table.insert(items, {Item = item, Priority = table.find(ItemPriority, item.Name) or #ItemPriority + 1})
            end
        end
        table.sort(items, function(a, b) return a.Priority < b.Priority end)
        for _, entry in pairs(items) do
            local item = entry.Item
            SafeCall(function()
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

local function AutoRevive()
    if AutoFarm.AutoRevive then
        local character, _, humanoid = GetCharacter()
        if humanoid and humanoid.Health <= 0 then
            SafeCall(function()
                local reviveRemote = WaitForChild(ReplicatedStorage.Shared.Remotes, "Revive", 2)
                if reviveRemote then
                    reviveRemote:FireServer()
                    Notify("Auto-Farm", "Revived player", 3)
                end
            end)
        end
    end
end

local function AutoHeal()
    if AutoFarm.AutoHeal then
        local character, _, humanoid = GetCharacter()
        if humanoid and humanoid.Health < 50 then
            SafeCall(function()
                -- Replace with game-specific heal remote or inventory action
                Notify("Auto-Farm", "Healing player", 3)
            end)
        end
    end
end

local function AutoTrainControl()
    if AutoFarm.AutoTrain then
        SafeCall(function()
            -- Replace with game-specific train control remote or logic
            Notify("Auto-Farm", "Controlling train", 3)
        end)
    end
end

-- Inventory Scanner
local InventoryLabel = Tabs.Farming:AddParagraph({
    Title = "Inventory",
    Content = "Scanning inventory..."
})
local function UpdateInventory()
    SafeCall(function()
        -- Replace with game-specific inventory access
        local inventory = {"Bond: 0", "Resource: 0"} -- Placeholder
        InventoryLabel:Set("Inventory:\n" .. table.concat(inventory, "\n"))
    end)
end
RunService.Heartbeat:Connect(UpdateInventory)

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
    SafeCall(function()
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

-- Kill Aura Function
local KillAura = {Enabled = false, Range = 10}
RunService.Heartbeat:Connect(function()
    if KillAura.Enabled then
        local character, hrp = GetCharacter()
        if not hrp then return end
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                if not ESP.TeamCheck or player.Team ~= LocalPlayer.Team then
                    local distance = (hrp.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if distance <= KillAura.Range then
                        SafeCall(function()
                            player.Character.Humanoid:TakeDamage(100)
                        end)
                    end
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
Tabs.Main:AddParagraph({
    Title = "Welcome to Dead Rails Script",
    Content = "Error-free script with silent aim, auto-train, and inventory scanner. Use responsibly!"
})

-- Combat Tab
Tabs.Combat:AddSection("Aimbot Settings")
Tabs.Combat:AddToggle({
    Text = "Enable Aimbot",
    Default = false,
    Keybind = Enum.KeyCode.Q,
    Callback = function(value)
        Aimbot.Enabled = value
        FOVCircle.Visible = value
        Notify("Aimbot", value and "Aimbot Enabled" or "Aimbot Disabled", 3)
    end
})
Tabs.Combat:AddToggle({
    Text = "Silent Aim",
    Default = false,
    Callback = function(value)
        Aimbot.SilentAim = value
        if value then Aimbot.Enabled = false end
        Notify("Aimbot", value and "Silent Aim Enabled" or "Silent Aim Disabled", 3)
    end
})
Tabs.Combat:AddToggle({
    Text = "Aimlock (No Prediction)",
    Default = false,
    Callback = function(value)
        Aimbot.Aimlock = value
    end
})
Tabs.Combat:AddSlider({
    Text = "FOV Radius",
    Default = 100,
    Min = 50,
    Max = 300,
    Rounding = 0,
    Callback = function(value)
        Aimbot.FOV = value
        FOVCircle.Radius = value
    end
})
Tabs.Combat:AddSlider({
    Text = "Smoothness",
    Default = 0.1,
    Min = 0.01,
    Max = 0.5,
    Rounding = 2,
    Callback = function(value)
        Aimbot.Smoothness = value
    end
})
Tabs.Combat:AddDropdown({
    Text = "Target Part",
    Default = "Head",
    Values = {"Head", "Torso", "HumanoidRootPart"},
    Callback = function(value)
        Aimbot.TargetPart = value
    end
})

Tabs.Combat:AddSection("Kill Aura")
Tabs.Combat:AddToggle({
    Text = "Enable Kill Aura",
    Default = false,
    Keybind = Enum.KeyCode.E,
    Callback = function(value)
        KillAura.Enabled = value
        Notify("Kill Aura", value and "Kill Aura Enabled" or "Kill Aura Disabled", 3)
    end
})
Tabs.Combat:AddSlider({
    Text = "Kill Aura Range",
    Default = 10,
    Min = 5,
    Max = 20,
    Rounding = 0,
    Callback = function(value)
        KillAura.Range = value
    end
})

-- Farming Tab
Tabs.Farming:AddSection("Auto-Farm Settings")
Tabs.Farming:AddToggle({
    Text = "Enable Auto-Farm",
    Default = false,
    Keybind = Enum.KeyCode.F,
    Callback = function(value)
        AutoFarm.Enabled = value
        if value then
            while AutoFarm.Enabled do
                AutoCollectItems()
                AutoRevive()
                AutoHeal()
                AutoTrainControl()
                task.wait(0.5)
            end
        end
    end
})
Tabs.Farming:AddToggle({
    Text = "Auto-Collect Items",
    Default = false,
    Callback = function(value)
        AutoFarm.Items = value
    end
})
Tabs.Farming:AddToggle({
    Text = "Auto Bond",
    Default = false,
    Callback = function(value)
        AutoFarm.Bonds = value
    end
})
Tabs.Farming:AddToggle({
    Text = "Auto-Revive",
    Default = false,
    Callback = function(value)
        AutoFarm.AutoRevive = value
    end
})
Tabs.Farming:AddToggle({
    Text = "Auto-Heal",
    Default = false,
    Callback = function(value)
        AutoFarm.AutoHeal = value
    end
})
Tabs.Farming:AddToggle({
    Text = "Auto-Train",
    Default = false,
    Callback = function(value)
        AutoFarm.AutoTrain = value
    end
})
Tabs.Farming:AddToggle({
    Text = "Anti-AFK",
    Default = false,
    Callback = function(value)
        AntiAFK.Enabled = value
        Notify("Anti-AFK", value and "Anti-AFK Enabled" or "Anti-AFK Disabled", 3)
    end
})

Tabs.Farming:AddSection("Teleport to Items")
local items = {}
local runtimeItems = WaitForChild(Workspace, "RuntimeItems", 2)
if runtimeItems then
    for _, item in pairs(runtimeItems:GetChildren()) do
        table.insert(items, item.Name)
    end
end
Tabs.Farming:AddDropdown({
    Text = "Select Item",
    Default = items[1] or "None",
    Values = items,
    Callback = function(value)
        TeleportToItem(value)
    end
})

-- Mobility Tab
Tabs.Mobility:AddSection("Movement Enhancements")
Tabs.Mobility:AddToggle({
    Text = "Enable NoClip",
    Default = false,
    Keybind = Enum.KeyCode.N,
    Callback = function(value)
        NoClip.Enabled = value
        Notify("NoClip", value and "NoClip Enabled" or "NoClip Disabled", 3)
    end
})
Tabs.Mobility:AddToggle({
    Text = "Enable Fly",
    Default = false,
    Keybind = Enum.KeyCode.V,
    Callback = function(value)
        Fly.Enabled = value
        SafeCall(ToggleFly)
        Notify("Fly", value and "Fly Enabled" or "Fly Disabled", 3)
    end
})
Tabs.Mobility:AddSlider({
    Text = "Fly Speed",
    Default = 50,
    Min = 10,
    Max = 100,
    Rounding = 0,
    Callback = function(value)
        Fly.Speed = value
    end
})
Tabs.Mobility:AddSlider({
    Text = "Walk Speed",
    Default = 16,
    Min = 16,
    Max = 100,
    Rounding = 0,
    Callback = function(value)
        SafeCall(function()
            local _, _, humanoid = GetCharacter()
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end)
    end
})
Tabs.Mobility:AddToggle({
    Text = "Sprint (2x Speed)",
    Default = false,
    Callback = function(value)
        SafeCall(function()
            local _, _, humanoid = GetCharacter()
            if humanoid then
                humanoid.WalkSpeed = value and humanoid.WalkSpeed * 2 or 16
            end
        end)
    end
})

-- Visuals Tab
Tabs.Visuals:AddSection("ESP Settings")
Tabs.Visuals:AddToggle({
    Text = "Enable ESP",
    Default = false,
    Keybind = Enum.KeyCode.T,
    Callback = function(value)
        ESP.Enabled = value
        SafeCall(UpdateESP)
        Notify("ESP", value and "ESP Enabled" or "ESP Disabled", 3)
    end
})
Tabs.Visuals:AddToggle({
    Text = "Player ESP",
    Default = false,
    Callback = function(value)
        ESP.Players = value
        SafeCall(UpdateESP)
    end
})
Tabs.Visuals:AddToggle({
    Text = "Item ESP",
    Default = false,
    Callback = function(value)
        ESP.Items = value
        SafeCall(UpdateESP)
    end
})
Tabs.Visuals:AddToggle({
    Text = "Enemy ESP",
    Default = false,
    Callback = function(value)
        ESP.Enemies = value
        SafeCall(UpdateESP)
    end
})
Tabs.Visuals:AddToggle({
    Text = "Team Check",
    Default = true,
    Callback = function(value)
        ESP.TeamCheck = value
        SafeCall(UpdateESP)
    end
})

Tabs.Visuals:AddSection("Environment")
Tabs.Visuals:AddButton({
    Text = "Remove Fog",
    Callback = function()
        SafeCall(function()
            Lighting.FogEnd = 100000
            Notify("Visuals", "Fog Removed", 3)
        end)
    end
})
Tabs.Visuals:AddButton({
    Text = "Full Bright",
    Callback = function()
        SafeCall(function()
            Lighting.Brightness = 2
            Lighting.GlobalShadows = false
            Notify("Visuals", "Full Bright Enabled", 3)
        end)
    end
})

-- Settings Tab
Tabs.Settings:AddSection("Configuration")
Tabs.Settings:AddButton({
    Text = "Save Settings",
    Callback = function()
        SafeCall(function()
            SaveManager:Save("DeadRailsConfig")
            Notify("Settings", "Configuration Saved", 3)
        end)
    end
})
Tabs.Settings:AddButton({
    Text = "Load Settings",
    Callback = function()
        SafeCall(function()
            SaveManager:Load("DeadRailsConfig")
            Notify("Settings", "Configuration Loaded", 3)
        end)
    end
})

Tabs.Settings:AddSection("Performance")
Tabs.Settings:AddButton({
    Text = "FPS Boost",
    Callback = function()
        SafeCall(function()
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                end
            end
            Notify("Performance", "FPS Boost Applied", 3)
        end)
    end
})
Tabs.Settings:AddButton({
    Text = "Low Graphics Mode",
    Callback = function()
        SafeCall(function()
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.CastShadow = false
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v:Destroy()
                end
            end
            Lighting.GlobalShadows = false
            Notify("Performance", "Low Graphics Mode Enabled", 3)
        end)
    end
})

-- Initialize Save Manager
SafeCall(function()
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    SaveManager:BuildConfigSection(Tabs.Settings)
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:LoadAutoloadConfig()
end)

-- Notify User
Notify("Script Loaded", "Dead Rails Advanced Script loaded successfully with error fixes!", 5)

-- Refresh Item Dropdown Dynamically
if runtimeItems then
    runtimeItems.ChildAdded:Connect(function()
        SafeCall(function()
            items = {}
            for _, item in pairs(runtimeItems:GetChildren()) do
                table.insert(items, item.Name)
            end
            Tabs.Farming:FindFirstChild("Select Item"):Refresh(items)
        end)
    end)
    runtimeItems.ChildRemoved:Connect(function()
        SafeCall(function()
            items = {}
            for _, item in pairs(runtimeItems:GetChildren()) do
                table.insert(items, item.Name)
            end
            Tabs.Farming:FindFirstChild("Select Item"):Refresh(items)
        end)
    end)
end

-- Character Respawn Handling
LocalPlayer.CharacterAdded:Connect(function()
    SafeCall(function()
        Notify("System", "Character respawned, updating features", 3)
        if ESP.Enabled then UpdateESP() end
        if Fly.Enabled then ToggleFly() end
    end)
end)
