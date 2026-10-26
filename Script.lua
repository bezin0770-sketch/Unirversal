-- UNIVERSAL FPS v14 - RAGE LOCK PRO (Melhorado)
if getgenv().UniversalV14 then 
    pcall(function() game:GetService("CoreGui").UniversalUI_V14:Destroy() end)
end
getgenv().UniversalV14 = true
getgenv().Bypass = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VU = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Config = {
    Aimbot = false,
    AutoShoot = false,
    FOV = 200,
    Smooth = 0.35,
    ESP = false,
    ESP_Box = true, ESP_Name = true, ESP_Health = true, ESP_Dist = true,
    Speed = false, SpeedValue = 50,
    InfJump = false, Noclip = false,
}

local function getChar(plr)
    local c = plr.Character
    if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    local r = c:FindFirstChild("HumanoidRootPart")
    if h and r and h.Health > 0 then return c, h, r end
end

local function getHead(char)
    local head = char:FindFirstChild("Head")
    if head then return head end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") and string.find(string.lower(v.Name), "head") then return v end
    end
    return nil
end

local function w2s(p)
    local v, on = Camera:WorldToViewportPoint(p)
    if v.Z <= 0 then return Vector2.new(0,0), false end
    return Vector2.new(v.X, v.Y), on
end

-- VERIFICAÇÃO DE PAREDE
local function isVisible(targetPart, targetChar)
    if not targetPart then return false end
    local ray = RaycastParams.new()
    ray.FilterDescendantsInstances = {LP.Character, Camera}
    ray.FilterType = Enum.RaycastFilterType.Exclude
    local res = Workspace:Raycast(Camera.CFrame.Position, targetPart.Position - Camera.CFrame.Position, ray)
    if res then return res.Instance:IsDescendantOf(targetChar) end
    return true
end

-- ==================== UI PREMIUM ====================
local UI = Instance.new("ScreenGui")
UI.Name = "UniversalUI_V14"
UI.ResetOnSpawn = false
UI.IgnoreGuiInset = true
UI.DisplayOrder = 999
pcall(function() UI.Parent = game:GetService("CoreGui") end)
if not UI.Parent then UI.Parent = LP:WaitForChild("PlayerGui") end

local FOVFrame = Instance.new("Frame", UI)
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Visible = false
Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", FOVFrame)
fovStroke.Color = Color3.fromRGB(170, 0, 255)
fovStroke.Thickness = 1.5
fovStroke.Transparency = 0.3

local FloatBtn = Instance.new("TextButton", UI)
FloatBtn.Size = UDim2.new(0, 45, 0, 45)
FloatBtn.Position = UDim2.new(0, 15, 0, 100)
FloatBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
FloatBtn.TextColor3 = Color3.fromRGB(170, 0, 255)
FloatBtn.Text = "Ω"
FloatBtn.Font = Enum.Font.GothamBlack
FloatBtn.TextSize = 24
FloatBtn.BorderSizePixel = 0
FloatBtn.Visible = false
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(0, 10)

local Main = Instance.new("Frame", UI)
Main.Size = UDim2.new(0, 340, 0, 400)
Main.Position = UDim2.new(0.5, -170, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
Main.BorderSizePixel = 0
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Thickness = 2
local gradient = Instance.new("UIGradient", mainStroke)
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255))
})

local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
TopBar.BorderSizePixel = 0
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = "☠️ RAGE LOCK PRO"

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -32, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 95, 1, -45)
Sidebar.Position = UDim2.new(0, 0, 0, 45)
Sidebar.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
Sidebar.BorderSizePixel = 0

local Pages = {}
local TabBtns = {}
local CurrentTab = nil

local function CreateTab(name, yPos)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    btn.TextColor3 = Color3.fromRGB(140, 140, 150)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.Text = name
    btn.BorderSizePixel = 0
    
    local page = Instance.new("ScrollingFrame", Main)
    page.Size = UDim2.new(1, -105, 1, -55)
    page.Position = UDim2.new(0, 100, 0, 50)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(170, 0, 255)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    
    local layout = Instance.new("UIListLayout", page)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    
    Pages[name] = page
    TabBtns[name] = btn
    
    btn.MouseButton1Click:Connect(function()
        for n, p in pairs(Pages) do p.Visible = false end
        for n, b in pairs(TabBtns) do 
            b.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
            b.TextColor3 = Color3.fromRGB(140, 140, 150)
        end
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        btn.TextColor3 = Color3.fromRGB(170, 0, 255)
        CurrentTab = name
    end)
    
    if not CurrentTab then
        CurrentTab = name
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        btn.TextColor3 = Color3.fromRGB(170, 0, 255)
    end
end

CreateTab("Aimbot", 0)
CreateTab("ESP", 45)
CreateTab("Player", 90)

local function AddToggle(parent, text, configKey, default)
    local f = Instance.new("TextButton", parent) 
    f.Size = UDim2.new(1, 0, 0, 35)
    f.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    f.BorderSizePixel = 0
    f.Text = ""
    f.AutoButtonColor = false
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -50, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(220, 220, 220)
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = text
    
    local bg = Instance.new("Frame", f)
    bg.Size = UDim2.new(0, 36, 0, 18)
    bg.Position = UDim2.new(1, -46, 0.5, -9)
    bg.BackgroundColor3 = default and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(15, 15, 20)
    bg.BorderSizePixel = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame", bg)
    circle.Size = UDim2.new(0, 14, 0, 14)
    circle.Position = default and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2)
    circle.BackgroundColor3 = Color3.new(1,1,1)
    circle.BorderSizePixel = 0
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    local clicked = false
    f.MouseButton1Click:Connect(function()
        if clicked then return end
        clicked = true
        Config[configKey] = not Config[configKey]
        local tColor = Config[configKey] and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(15, 15, 20)
        local tPos = Config[configKey] and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2)
        TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = tColor}):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = tPos}):Play()
        task.wait(0.15); clicked = false
    end)
end

local function AddSlider(parent, text, configKey, min, max, default)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 50)
    f.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -20, 0, 20)
    l.Position = UDim2.new(0, 12, 0, 2)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(220, 220, 220)
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = text .. ": " .. Config[configKey]
    
    local bar = Instance.new("Frame", f)
    bar.Size = UDim2.new(1, -24, 0, 6)
    bar.Position = UDim2.new(0, 12, 0, 25)
    bar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((Config[configKey]-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local btn = Instance.new("TextButton", bar)
    btn.Size = UDim2.new(1, 10, 1, 20)
    btn.Position = UDim2.new(0, -5, 0.5, -10)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    
    local dragging = false
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            local val = math.floor(min + ((max - min) * pos))
            l.Text = text .. ": " .. val
            Config[configKey] = val
        end
    end)
end

AddToggle(Pages["Aimbot"], "Aimbot Silent (Solta a Tela)", "Aimbot", false)
AddToggle(Pages["Aimbot"], "Auto Tiro (3 Métodos)", "AutoShoot", false)
AddSlider(Pages["Aimbot"], "FOV", "FOV", 50, 500, Config.FOV)
AddSlider(Pages["Aimbot"], "Smooth", "Smooth", 1, 100, Config.Smooth * 100)

AddToggle(Pages["ESP"], "Ligar ESP 3D", "ESP", false)
AddToggle(Pages["ESP"], "Caixa (Box)", "ESP_Box", true)
AddToggle(Pages["ESP"], "Nome", "ESP_Name", true)
AddToggle(Pages["ESP"], "Vida", "ESP_Health", true)
AddToggle(Pages["ESP"], "Distância", "ESP_Dist", true)

AddToggle(Pages["Player"], "Speed Hack", "Speed", false)
AddSlider(Pages["Player"], "Velocidade", "SpeedValue", 16, 200, 50)
AddToggle(Pages["Player"], "Pulo Infinito", "InfJump", false)
AddToggle(Pages["Player"], "Noclip", "Noclip", false)

local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = Main.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false; FloatBtn.Visible = true end)
FloatBtn.MouseButton1Click:Connect(function() Main.Visible = true; FloatBtn.Visible = false end)

-- ==================== ESP 3D ====================
local ESP_Cache = {}
local function CreateESP(plr)
    if plr == LP then return end
    local e = {}
    e.Billboard = Instance.new("BillboardGui")
    e.Billboard.Size = UDim2.new(0, 70, 0, 80)
    e.Billboard.AlwaysOnTop = true
    e.Billboard.Enabled = false
    e.Billboard.Parent = UI

    e.Box = Instance.new("Frame", e.Billboard)
    e.Box.BackgroundTransparency = 1
    e.Box.Size = UDim2.new(1, 0, 1, 0)
    local stroke = Instance.new("UIStroke", e.Box)
    stroke.Color = Color3.fromRGB(170, 0, 255)
    stroke.Thickness = 1.5

    e.Name = Instance.new("TextLabel", e.Billboard)
    e.Name.Size = UDim2.new(1, 0, 0, 20)
    e.Name.Position = UDim2.new(0, 0, 0, -22)
    e.Name.BackgroundTransparency = 1
    e.Name.TextColor3 = Color3.new(1,1,1)
    e.Name.Font = Enum.Font.GothamBold
    e.Name.TextSize = 12
    e.Name.TextStrokeTransparency = 0
    
    e.Dist = Instance.new("TextLabel", e.Billboard)
    e.Dist.Size = UDim2.new(1, 0, 0, 20)
    e.Dist.Position = UDim2.new(0, 0, 1, 2)
    e.Dist.BackgroundTransparency = 1
    e.Dist.TextColor3 = Color3.fromRGB(200,200,200)
    e.Dist.Font = Enum.Font.Gotham
    e.Dist.TextSize = 11
    e.Dist.TextStrokeTransparency = 0
    
    e.HealthBg = Instance.new("Frame", e.Billboard)
    e.HealthBg.Size = UDim2.new(0, 3, 1, 0)
    e.HealthBg.Position = UDim2.new(0, -6, 0, 0)
    e.HealthBg.BackgroundColor3 = Color3.new(0,0,0)
    e.HealthBg.BorderSizePixel = 0
    
    e.HealthFill = Instance.new("Frame", e.HealthBg)
    e.HealthFill.Size = UDim2.new(1, 0, 1, 0)
    e.HealthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    e.HealthFill.BorderSizePixel = 0
    ESP_Cache[plr] = e
end

for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(p)
    if ESP_Cache[p] then ESP_Cache[p].Billboard:Destroy(); ESP_Cache[p] = nil end
end)

local function UpdateESP()
    for plr, e in pairs(ESP_Cache) do
        local char, hum, hrp = getChar(plr)
        if Config.ESP and hrp and hum then
            e.Billboard.Adornee = hrp
            e.Billboard.Enabled = true
            e.Box.Visible = Config.ESP_Box
            e.Name.Text = plr.Name
            e.Name.Visible = Config.ESP_Name
            
            if Config.ESP_Dist then
                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                e.Dist.Text = math.floor(dist) .. "m"
                e.Dist.Visible = true
            else e.Dist.Visible = false end

            if Config.ESP_Health then
                local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                e.HealthBg.Visible = true
                e.HealthFill.Size = UDim2.new(1, 0, pct, 0)
                e.HealthFill.Position = UDim2.new(0, 0, 1 - pct, 0)
                e.HealthFill.BackgroundColor3 = Color3.fromRGB(255*(1-pct), 255*pct, 0)
            else e.HealthBg.Visible = false end
        else e.Billboard.Enabled = false end
    end
end

-- ==================== AIMBOT SILENT ====================
local lastShot = 0
local currentTarget = nil

local function updateTarget()
    currentTarget = nil
    if not Config.Aimbot then return end
    local best, bd = nil, Config.FOV
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local char = plr.Character
            local head = char and getHead(char)
            if head then
                local s, on = w2s(head.Position)
                if on then
                    local d = (s - center).Magnitude
                    if d < bd and isVisible(head, char) then bd = d; best = head end
                end
            end
        end
    end
    currentTarget = best
end

-- FUNÇÃO SHOOT MELHORADA
local function shoot()
    local char = LP.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then pcall(function() tool:Activate() end) end
    pcall(function() VU:CaptureController(); VU:ClickButton1(Vector2.new(0,0), Camera.CFrame) end)
    pcall(function() if mouse1click then mouse1click() end end)
end

-- ==================== LOOPS ====================
RunService.RenderStepped:Connect(function()
    if Config.Aimbot then
        FOVFrame.Visible = true
        FOVFrame.Size = UDim2.fromOffset(Config.FOV, Config.FOV)
    else FOVFrame.Visible = false end
    if Config.ESP then UpdateESP() end

    if Config.Aimbot then
        updateTarget()
        if currentTarget then
            if Config.AutoShoot and tick() - lastShot > 0.15 then
                lastShot = tick()
                local oldCFrame = Camera.CFrame
                Camera.CFrame = CFrame.new(oldCFrame.Position, currentTarget.Position)
                shoot()
                Camera.CFrame = oldCFrame
            end
        end
    end
end)

RunService.Stepped:Connect(function()
    local c, h, r = getChar(LP)
    if not c or not h or not r then return end
    if Config.Speed then h.WalkSpeed = Config.SpeedValue else h.WalkSpeed = 16 end
    if Config.Noclip then
        for _, p in ipairs(c:GetChildren()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end
    end
end)

UIS.JumpRequest:Connect(function()
    if Config.InfJump then
        local c, h = getChar(LP)
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

print("[F] RAGE LOCK PRO v14 Carregado. Otimizado e com Silent Aim.")
