--[[
    ============================================================
    dadadovich HVH SUITE v1.0  (separate script)
    team: dadka | created: 14.07.2026
    target: Delta Executor (PC / Android / iOS) — Roblox
    type: Hack-vs-Hack combat module
    note: HVH = Anti-Aim + Silent Aim + Rapid + Hitbox + ESP
    ============================================================
]]

print("=== [dadadovich HVH] start ===")

--=========================================================
-- SERVICES
--=========================================================
local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local UserInputService    = game:GetService("UserInputService")
local CoreGui             = game:GetService("CoreGui")
local Workspace           = game:GetService("Workspace")
local StarterGui          = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

local function safeSet(obj, prop, val)
    local ok, err = pcall(function() obj[prop] = val end)
    if not ok then warn("[HVH] safeSet:", prop, err) end
end

--=========================================================
-- GUI PARENT
--=========================================================
local guiParent = CoreGui
do
    local ok = pcall(function()
        local t = Instance.new("Folder"); t.Parent = CoreGui; t:Destroy()
    end)
    if not ok then guiParent = LocalPlayer:WaitForChild("PlayerGui", 10) end
end

--=========================================================
-- PLATFORM
--=========================================================
local Platform = {}
Platform.isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
Platform.isPC     = UserInputService.KeyboardEnabled and UserInputService.MouseEnabled
if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then Platform.isMobile = true end

local viewport = Camera.ViewportSize

--=========================================================
-- CONFIG
--=========================================================
local Config = {
    Enabled = true,
    Profile = "HVH",

    AntiAim = {
        Enabled  = false,
        Mode     = "Jitter",   -- Jitter / Spin / Random / Down / Static
        Speed    = 0.05,
        Angle    = 180,
        Pitch    = 0,
    },

    SilentAim = {
        Enabled   = false,
        FOV       = 250,
        Smooth    = 0.15,
        HitPart   = "Head",  -- Head / HumanoidRootPart / Random
        VisibleChk = false,
    },

    RapidFire = {
        Enabled = false,
        Delay   = 0.02,
    },

    Hitbox = {
        Enabled = false,
        Size    = 10,
    },

    AutoPeek = {
        Enabled = false,
        Side    = "Right",   -- Left / Right / Random
        Delay   = 0.3,
    },

    KillAura = {
        Enabled = false,
        Range   = 6,
        Delay   = 0.1,
    },

    ESP = {
        Enabled      = true,
        HVHHighlight = true,   -- подсветка подозрительных (Rapid>10/сек)
        EnemiesRed   = true,
        ShowDist     = true,
        ShowName     = true,
        ShowWeapon   = true,
    },

    Rage = {
        Enabled = false,
    },
}

--=========================================================
-- SCREEN
--=========================================================
local screen = Instance.new("ScreenGui")
safeSet(screen, "Name",           "hvh_"..tostring(math.random(1e6,9e6)))
safeSet(screen, "ResetOnSpawn",   false)
safeSet(screen, "IgnoreGuiInset", true)
safeSet(screen, "ZIndexBehavior", Enum.ZIndexBehavior.Sibling)
safeSet(screen, "DisplayOrder",   998)
screen.Parent = guiParent

local function corner(parent, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 10); c.Parent = parent
    return c
end
local function stroke(parent, col, t)
    local s = Instance.new("UIStroke")
    s.Color = col or Color3.fromRGB(255, 60, 80)
    s.Thickness = 1; s.Transparency = t or 0.5
    s.Parent = parent
    return s
end

--=========================================================
-- MAIN WINDOW
--=========================================================
local WINDOW_W = math.min(viewport.X - 20, Platform.isMobile and 380 or 520)
local WINDOW_H = math.min(viewport.Y - 60, Platform.isMobile and 480 or 400)

local main = Instance.new("Frame")
main.Size = UDim2.new(0, WINDOW_W, 0, WINDOW_H)
main.Position = UDim2.new(0.5, -WINDOW_W/2, 0.5, -WINDOW_H/2)
main.BackgroundColor3 = Color3.fromRGB(22, 10, 16)
main.BackgroundTransparency = 0.2
main.BorderSizePixel = 0
main.Active = true
main.Visible = false
main.Parent = screen
corner(main, 14)
stroke(main, Color3.fromRGB(255, 60, 80), 0.35)

-- Toggle button (красный, чтобы отличать)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, Platform.isMobile and 56 or 46, 0, Platform.isMobile and 56 or 46)
toggleBtn.Position = Platform.isMobile
    and UDim2.new(0, 12, 0.5, 46)
    or  UDim2.new(0, 20, 0.5, 30)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 10, 20)
toggleBtn.BackgroundTransparency = 0.15
toggleBtn.Text = "H"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = Platform.isMobile and 24 or 20
toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 120)
toggleBtn.BorderSizePixel = 0
toggleBtn.Active = true
toggleBtn.Parent = screen
corner(toggleBtn, 12)
stroke(toggleBtn, Color3.fromRGB(255, 60, 80), 0.3)
toggleBtn.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 40)
title.Position = UDim2.new(0, 14, 0, 8)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = Platform.isMobile and 16 or 18
title.TextColor3 = Color3.fromRGB(255, 180, 200)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "dadadovich  •  HVH  •  dadka"
title.Active = true
title.Parent = main

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, Platform.isMobile and 40 or 30, 0, Platform.isMobile and 40 or 30)
closeBtn.Position = UDim2.new(1, -(Platform.isMobile and 50 or 40), 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(70, 20, 30)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = Platform.isMobile and 18 or 14
closeBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
closeBtn.BorderSizePixel = 0
closeBtn.Parent = main
corner(closeBtn, 8)
closeBtn.MouseButton1Click:Connect(function() main.Visible = false end)

--=========================================================
-- TABS
--=========================================================
local isPortrait = viewport.Y >= viewport.X
local useHorizontalTabs = Platform.isMobile and isPortrait

local tabs = Instance.new("Frame")
tabs.BackgroundColor3 = Color3.fromRGB(35, 15, 22)
tabs.BackgroundTransparency = 0.35
tabs.BorderSizePixel = 0
tabs.ClipsDescendants = true
tabs.Parent = main
corner(tabs, 10)

local content = Instance.new("Frame")
content.BackgroundColor3 = Color3.fromRGB(35, 15, 22)
content.BackgroundTransparency = 0.35
content.BorderSizePixel = 0
content.ClipsDescendants = true
content.Parent = main
corner(content, 10)

if useHorizontalTabs then
    tabs.Size = UDim2.new(1, -24, 0, 52)
    tabs.Position = UDim2.new(0, 12, 0, 52)
    content.Size = UDim2.new(1, -24, 1, -116)
    content.Position = UDim2.new(0, 12, 0, 110)
else
    tabs.Size = UDim2.new(0, 130, 1, -60)
    tabs.Position = UDim2.new(0, 12, 0, 52)
    content.Size = UDim2.new(1, -158, 1, -60)
    content.Position = UDim2.new(0, 150, 0, 52)
end

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, 0)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = content

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 10); pad.PaddingLeft = UDim.new(0, 10)
pad.PaddingRight = UDim.new(0, 10); pad.PaddingBottom = UDim.new(0, 10)
pad.Parent = scroll

--=========================================================
-- HELPERS
--=========================================================
local BTN_H = Platform.isMobile and 42 or 32

local function makeButton(text, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, BTN_H)
    b.BackgroundColor3 = Color3.fromRGB(55, 20, 30)
    b.BackgroundTransparency = 0.15
    b.BorderSizePixel = 0
    b.Font = Enum.Font.Gotham
    b.TextSize = Platform.isMobile and 15 or 14
    b.TextColor3 = Color3.fromRGB(255, 220, 230)
    b.Text = text
    b.Active = true
    b.Selectable = false
    b.Parent = scroll
    corner(b, 8)
    stroke(b, Color3.fromRGB(180, 50, 70), 0.7)
    b.MouseButton1Click:Connect(function()
        local ok, err = pcall(cb)
        if not ok then warn("[HVH] button err:", err) end
    end)
    return b
end

local function makeToggle(label, initial, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, BTN_H)
    b.BackgroundColor3 = Color3.fromRGB(50, 18, 26)
    b.BackgroundTransparency = 0.15
    b.BorderSizePixel = 0
    b.Font = Enum.Font.Gotham
    b.TextSize = Platform.isMobile and 14 or 13
    b.TextColor3 = Color3.fromRGB(255, 220, 230)
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Text = "  "..label.." : "..(initial and "ON" or "OFF")
    b.Active = true
    b.Selectable = false
    b.Parent = scroll
    corner(b, 8)
    local state = initial
    b.MouseButton1Click:Connect(function()
        state = not state
        b.Text = "  "..label.." : "..(state and "ON" or "OFF")
        pcall(cb, state)
    end)
    return b
end

local function makeSlider(label, minV, maxV, initial, cb)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, Platform.isMobile and 56 or 42)
    holder.BackgroundTransparency = 1
    holder.Parent = scroll

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = Platform.isMobile and 14 or 13
    lbl.TextColor3 = Color3.fromRGB(240, 200, 210)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = label.."  ["..tostring(initial).."]"
    lbl.Parent = holder

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, Platform.isMobile and 14 or 8)
    bar.Position = UDim2.new(0, 0, 0, Platform.isMobile and 30 or 24)
    bar.BackgroundColor3 = Color3.fromRGB(70, 30, 45)
    bar.BorderSizePixel = 0
    bar.Active = true
    bar.Parent = holder
    corner(bar, 4)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((initial - minV)/(maxV - minV), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 80, 100)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    corner(fill, 4)

    local knobSize = Platform.isMobile and 22 or 16
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, knobSize, 0, knobSize)
    knob.Position = UDim2.new((initial - minV)/(maxV - minV), 0, 0.5, 0)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.BackgroundColor3 = Color3.fromRGB(255, 180, 200)
    knob.BorderSizePixel = 0
    knob.Parent = bar
    corner(knob, 100)

    local dragging = false
    local function setFromX(absX)
        local rel = math.clamp((absX - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local v = minV + rel * (maxV - minV)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, 0)
        lbl.Text = label.."  ["..string.format("%.2f", v).."]"
        pcall(cb, v)
    end

    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; setFromX(i.Position.X)
        end
    end)
    bar.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then setFromX(i.Position.X) end
    end)
    bar.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseMovement) then setFromX(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    return holder
end

--=========================================================
-- WINDOW DRAG
--=========================================================
do
    local dragging, dragStart, startPos
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            local vX = Camera.ViewportSize.X
            local vY = Camera.ViewportSize.Y
            local newX = math.clamp(startPos.X.Offset + delta.X, -WINDOW_W/2, vX - WINDOW_W/2)
            local newY = math.clamp(startPos.Y.Offset + delta.Y, -WINDOW_H/2, vY - WINDOW_H/2)
            main.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

--=========================================================
-- ANTI-AIM MODULE
--=========================================================
local AntiAim = {}
local origHRPCFrame = nil

local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

AntiAim.currentAngle = 0
AntiAim.currentPitch = 0

RunService.RenderStepped:Connect(function(dt)
    if not Config.AntiAim.Enabled then return end
    local hrp = getHRP()
    if not hrp then return end

    local mode = Config.AntiAim.Mode
    local speed = Config.AntiAim.Speed

    if mode == "Spin" then
        AntiAim.currentAngle = (AntiAim.currentAngle + speed * 360 * dt * 10) % 360
        AntiAim.currentPitch = 0
    elseif mode == "Jitter" then
        AntiAim.currentAngle = (AntiAim.currentAngle + ((math.random() > 0.5) and 1 or -1) * 180) % 360
    elseif mode == "Random" then
        if math.random() < 0.15 then
            AntiAim.currentAngle = math.random(0, 360)
            AntiAim.currentPitch = math.random(-85, 85)
        end
    elseif mode == "Down" then
        AntiAim.currentAngle = 0
        AntiAim.currentPitch = 89
    elseif mode == "Static" then
        AntiAim.currentAngle = Config.AntiAim.Angle
        AntiAim.currentPitch = Config.AntiAim.Pitch
    end

    -- применить CFrame (только yaw+pitch, без изменения позиции)
    local pos = hrp.Position
    local newCF = CFrame.new(pos)
        * CFrame.Angles(0, math.rad(AntiAim.currentAngle), 0)
        * CFrame.Angles(math.rad(AntiAim.currentPitch), 0, 0)
    hrp.CFrame = newCF
end)

--=========================================================
-- SILENT AIM MODULE
--=========================================================
local Silent = {}

function Silent.getTarget()
    local best, bestDist = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and head and humanoid and humanoid.Health > 0 then
                local part
                if Config.SilentAim.HitPart == "Head" then part = head
                elseif Config.SilentAim.HitPart == "HumanoidRootPart" then part = hrp
                else part = (math.random() > 0.5) and head or hrp end

                local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dx = sp.X - mousePos.X
                    local dy = sp.Y - mousePos.Y
                    local screenDist = math.sqrt(dx*dx + dy*dy)
                    if screenDist <= Config.SilentAim.FOV and screenDist < bestDist then
                        bestDist = screenDist
                        best = { plr = plr, part = part }
                    end
                end
            end
        end
    end
    return best
end

do
    local mt = getrawmetatable and getrawmetatable(game)
    if mt then
        local canReadonly = type(setreadonly) == "function"
        if canReadonly then pcall(setreadonly, mt, false) end
        local oldIndex = mt.__index
        pcall(function()
            mt.__index = newcclosure(function(self, key)
                if Config.SilentAim.Enabled then
                    if key == "Hit" and self == Workspace then
                        local t = Silent.getTarget()
                        if t and t.part then return t.part.CFrame end
                    end
                    if key == "Target" and self == Workspace then
                        local t = Silent.getTarget()
                        if t and t.part then return t.part end
                    end
                end
                return oldIndex(self, key)
            end)
        end)
        if canReadonly then pcall(setreadonly, mt, true) end
    end
end

--=========================================================
-- RAPID FIRE
--=========================================================
task.spawn(function()
    while Config.Enabled do
        task.wait(Config.RapidFire.Delay)
        if Config.RapidFire.Enabled then
            local t = Silent.getTarget()
            if t then
                pcall(function()
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end)
            end
        end
    end
end)

--=========================================================
-- HITBOX EXPANDER
--=========================================================
local origSizes = {}

local function updateHitbox()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                if not origSizes[hrp] then origSizes[hrp] = hrp.Size end
                if Config.Hitbox.Enabled then
                    hrp.Size = Vector3.new(Config.Hitbox.Size, Config.Hitbox.Size, Config.Hitbox.Size)
                    hrp.Transparency = 0.7
                    hrp.CanCollide = false
                else
                    hrp.Size = origSizes[hrp]
                    hrp.Transparency = 1
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if Config.Hitbox.Enabled then updateHitbox() end
end)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function() task.wait(0.5); updateHitbox() end)
end)

--=========================================================
-- AUTO-PEEK
--=========================================================
task.spawn(function()
    while Config.Enabled do
        task.wait(0.1)
        if Config.AutoPeek.Enabled then
            local hrp = getHRP()
            if hrp then
                local side = Config.AutoPeek.Side
                if side == "Random" then side = (math.random() > 0.5) and "Left" or "Right" end
                local offset = (side == "Left") and Vector3.new(-4, 0, 0) or Vector3.new(4, 0, 0)
                local oldPos = hrp.Position
                hrp.CFrame = hrp.CFrame + offset
                task.wait(Config.AutoPeek.Delay)
                hrp.CFrame = CFrame.new(oldPos) * (hrp.CFrame - hrp.CFrame.Position)
            end
        end
    end
end)

--=========================================================
-- KILL AURA (ближний бой)
--=========================================================
task.spawn(function()
    while Config.Enabled do
        task.wait(Config.KillAura.Delay)
        if Config.KillAura.Enabled then
            local char = LocalPlayer.Character
            local myHRP = char and char:FindFirstChild("HumanoidRootPart")
            if myHRP then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                        if hrp and hum and hum.Health > 0 then
                            if (hrp.Position - myHRP.Position).Magnitude <= Config.KillAura.Range then
                                -- авто-удар инструментом
                                local tool = char:FindFirstChildOfClass("Tool")
                                if tool then pcall(function() tool:Activate() end) end
                            end
                        end
                    end
                end
            end
        end
    end
end)

--=========================================================
-- HVH ESP (подсветка читеров + врагов)
--=========================================================
local HVHESP = { cache = {} }
local hvhFolder = Instance.new("Folder")
hvhFolder.Name = "hvh_"..tostring(math.random(1e6,9e6))
hvhFolder.Parent = guiParent

-- эвристика: считаем выстрелы врага за 1 секунду
local shotCounters = {}  -- [plr] = {count, lastCheck}

local function isSuspicious(plr)
    local c = shotCounters[plr]
    if not c then return false end
    local now = tick()
    if now - c.lastCheck > 1 then
        c.lastCheck = now
        if c.count > 10 then
            c.count = 0
            return true
        end
        c.count = 0
    end
    return false
end

-- следим за активацией Tool у врагов
local function watchTools(plr)
    if plr == LocalPlayer then return end
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                shotCounters[plr] = shotCounters[plr] or { count = 0, lastCheck = tick() }
                tool.Activated:Connect(function()
                    local c = shotCounters[plr]
                    if c then c.count = c.count + 1 end
                end)
            end
        end
    end)
end
for _, plr in ipairs(Players:GetPlayers()) do watchTools(plr) end
Players.PlayerAdded:Connect(watchTools)

local function createHVHESP(plr)
    if HVHESP.cache[plr] then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "h_"..tostring(math.random(1e6,9e6))
    bb.Size = UDim2.new(0, 200, 0, 90)
    bb.StudsOffset = Vector3.new(0, 3.6, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 2000
    bb.Parent = hvhFolder

    local fill = Instance.new("BoxHandleAdornment")
    fill.Size = Vector3.new(2, 2, 1)
    fill.Transparency = 0.4
    fill.Color3 = Color3.fromRGB(255, 50, 50)
    fill.AlwaysOnTop = true
    fill.ZIndex = 5
    fill.Parent = hvhFolder

    local nameLbl = Instance.new("TextLabel")
    nameLbl.BackgroundTransparency = 1
    nameLbl.Size = UDim2.new(1, 0, 0, 20)
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 16
    nameLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
    nameLbl.TextStrokeTransparency = 0
    nameLbl.Text = plr.Name
    nameLbl.Parent = bb

    local distLbl = Instance.new("TextLabel")
    distLbl.BackgroundTransparency = 1
    distLbl.Size = UDim2.new(1, 0, 0, 20)
    distLbl.Position = UDim2.new(0, 0, 1, -22)
    distLbl.Font = Enum.Font.Code
    distLbl.TextSize = 14
    distLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    distLbl.TextStrokeTransparency = 0
    distLbl.Text = "[0 studs]"
    distLbl.Parent = bb

    local tagLbl = Instance.new("TextLabel")
    tagLbl.BackgroundTransparency = 1
    tagLbl.Size = UDim2.new(1, 0, 0, 18)
    tagLbl.Position = UDim2.new(0, 0, 0, 20)
    tagLbl.Font = Enum.Font.Code
    tagLbl.TextSize = 13
    tagLbl.TextColor3 = Color3.fromRGB(255, 200, 50)
    tagLbl.TextStrokeTransparency = 0
    tagLbl.Text = ""
    tagLbl.Parent = bb

    HVHESP.cache[plr] = { bb = bb, fill = fill, nameLbl = nameLbl, distLbl = distLbl, tagLbl = tagLbl }
end

local function removeHVHESP(plr)
    local d = HVHESP.cache[plr]
    if not d then return end
    for _, o in pairs(d) do if typeof(o) == "Instance" then o:Destroy() end end
    HVHESP.cache[plr] = nil
end

RunService.RenderStepped:Connect(function()
    if not Config.ESP.Enabled then
        for _, d in pairs(HVHESP.cache) do d.bb.Adornee = nil; d.fill.Adornee = nil end
        return
    end
    for plr, d in pairs(HVHESP.cache) do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        if hrp and plr ~= LocalPlayer then
            d.bb.Adornee = head or hrp
            d.fill.Adornee = hrp
            d.fill.Size = hrp.Size + Vector3.new(0.3,0.3,0.3)
            local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
            d.distLbl.Text = "["..dist.." studs]"
            d.nameLbl.Text = plr.Name

            if Config.ESP.HVHHighlight and isSuspicious(plr) then
                d.fill.Color3 = Color3.fromRGB(255, 200, 0)
                d.nameLbl.TextColor3 = Color3.fromRGB(255, 220, 50)
                d.tagLbl.Text = "[ HVH ]"
            elseif Config.ESP.EnemiesRed then
                d.fill.Color3 = Color3.fromRGB(255, 50, 50)
                d.nameLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
                d.tagLbl.Text = ""
            end
        else
            d.bb.Adornee = nil
            d.fill.Adornee = nil
        end
    end
end)

local function hookESP(plr)
    if plr ~= LocalPlayer then createHVHESP(plr) end
    plr.CharacterAdded:Connect(function() if plr ~= LocalPlayer then createHVHESP(plr) end end)
    plr.CharacterRemoving:Connect(function() removeHVHESP(plr) end)
end
for _, plr in ipairs(Players:GetPlayers()) do hookESP(plr) end
Players.PlayerAdded:Connect(hookESP)
Players.PlayerRemoving:Connect(removeHVHESP)

--=========================================================
-- TAB BUILDERS
--=========================================================
local tabButtons = {}

local function clearContent()
    for _, c in ipairs(scroll:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end
end

local function buildAntiAim()
    clearContent()
    makeToggle("Anti-Aim Enabled", Config.AntiAim.Enabled, function(v) Config.AntiAim.Enabled = v end)

    makeButton("Режим: Jitter", function()
        Config.AntiAim.Mode = "Jitter"
    end)
    makeButton("Режим: Spin", function()
        Config.AntiAim.Mode = "Spin"
    end)
    makeButton("Режим: Random", function()
        Config.AntiAim.Mode = "Random"
    end)
    makeButton("Режим: Down (смотрит вниз)", function()
        Config.AntiAim.Mode = "Down"
    end)
    makeButton("Режим: Static", function()
        Config.AntiAim.Mode = "Static"
    end)

    makeSlider("Скорость", 0.01, 0.5, Config.AntiAim.Speed, function(v) Config.AntiAim.Speed = v end)
    makeSlider("Static Angle", 0, 360, Config.AntiAim.Angle, function(v) Config.AntiAim.Angle = v end)
    makeSlider("Static Pitch", -89, 89, Config.AntiAim.Pitch, function(v) Config.AntiAim.Pitch = v end)
end

local function buildCombat()
    clearContent()

    makeToggle("Silent Aim", Config.SilentAim.Enabled, function(v) Config.SilentAim.Enabled = v end)
    makeSlider("Silent FOV", 10, 500, Config.SilentAim.FOV, function(v) Config.SilentAim.FOV = v end)
    makeSlider("Silent Smooth", 0, 1, Config.SilentAim.Smooth, function(v) Config.SilentAim.Smooth = v end)
    makeButton("Hit Part: Head", function() Config.SilentAim.HitPart = "Head" end)
    makeButton("Hit Part: HRP", function() Config.SilentAim.HitPart = "HumanoidRootPart" end)
    makeButton("Hit Part: Random", function() Config.SilentAim.HitPart = "Random" end)

    makeToggle("Rapid Fire", Config.RapidFire.Enabled, function(v) Config.RapidFire.Enabled = v end)
    makeSlider("Rapid Delay", 0.01, 0.5, Config.RapidFire.Delay, function(v) Config.RapidFire.Delay = v end)

    makeToggle("Hitbox Expander", Config.Hitbox.Enabled, function(v)
        Config.Hitbox.Enabled = v; updateHitbox()
    end)
    makeSlider("Hitbox Size", 2, 30, Config.Hitbox.Size, function(v)
        Config.Hitbox.Size = v; updateHitbox()
    end)

    makeToggle("Auto-Peek", Config.AutoPeek.Enabled, function(v) Config.AutoPeek.Enabled = v end)
    makeButton("Auto-Peek: Left",   function() Config.AutoPeek.Side = "Left" end)
    makeButton("Auto-Peek: Right",  function() Config.AutoPeek.Side = "Right" end)
    makeButton("Auto-Peek: Random", function() Config.AutoPeek.Side = "Random" end)

    makeToggle("Kill Aura (ближний бой)", Config.KillAura.Enabled, function(v) Config.KillAura.Enabled = v end)
    makeSlider("Kill Aura Range", 3, 20, Config.KillAura.Range, function(v) Config.KillAura.Range = v end)
end

local function buildESP()
    clearContent()
    makeToggle("HVH ESP", Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end)
    makeToggle("Подсветка HVH (подозрительные)", Config.ESP.HVHHighlight, function(v) Config.ESP.HVHHighlight = v end)
    makeToggle("Враги красным", Config.ESP.EnemiesRed, function(v) Config.ESP.EnemiesRed = v end)
end

local function buildPresets()
    clearContent()
    makeButton("🔥 RAGE MODE (всё сразу)", function()
        Config.AntiAim.Enabled = true
        Config.AntiAim.Mode = "Spin"
        Config.SilentAim.Enabled = true
        Config.SilentAim.FOV = 500
        Config.SilentAim.HitPart = "Head"
        Config.RapidFire.Enabled = true
        Config.RapidFire.Delay = 0.01
        Config.Hitbox.Enabled = true
        Config.Hitbox.Size = 15
        Config.ESP.Enabled = true
        Config.ESP.HVHHighlight = true
        updateHitbox()
        pcall(buildPresets)
    end)

    makeButton("⚖ LEGIT MODE (тихо)", function()
        Config.AntiAim.Enabled = false
        Config.SilentAim.Enabled = false
        Config.RapidFire.Enabled = false
        Config.Hitbox.Enabled = false
        Config.AutoPeek.Enabled = false
        Config.KillAura.Enabled = false
        updateHitbox()
        pcall(buildPresets)
    end)

    makeButton("🎯 HVH SAFE (только silent + hitbox)", function()
        Config.AntiAim.Enabled = false
        Config.SilentAim.Enabled = true
        Config.SilentAim.FOV = 200
        Config.RapidFire.Enabled = false
        Config.Hitbox.Enabled = true
        Config.Hitbox.Size = 6
        updateHitbox()
        pcall(buildPresets)
    end)

    makeButton("🌀 ANTI-AIM ONLY (троллинг)", function()
        Config.AntiAim.Enabled = true
        Config.AntiAim.Mode = "Spin"
        Config.AntiAim.Speed = 0.02
        Config.SilentAim.Enabled = false
        Config.RapidFire.Enabled = false
        Config.Hitbox.Enabled = false
        updateHitbox()
        pcall(buildPresets)
    end)

    makeButton("❌ ВЫКЛЮЧИТЬ ВСЁ", function()
        Config.AntiAim.Enabled = false
        Config.SilentAim.Enabled = false
        Config.RapidFire.Enabled = false
        Config.Hitbox.Enabled = false
        Config.AutoPeek.Enabled = false
        Config.KillAura.Enabled = false
        updateHitbox()
        pcall(buildPresets)
    end)
end

--=========================================================
-- TABS INIT
--=========================================================
local tabContainer = tabs
if useHorizontalTabs then
    local ts = Instance.new("ScrollingFrame")
    ts.Size = UDim2.new(1, -16, 1, -16)
    ts.Position = UDim2.new(0, 8, 0, 8)
    ts.BackgroundTransparency = 1
    ts.BorderSizePixel = 0
    ts.ScrollBarThickness = 0
    ts.ScrollingDirection = Enum.ScrollingDirection.X
    ts.CanvasSize = UDim2.new(0, 0, 0, 0)
    ts.AutomaticCanvasSize = Enum.AutomaticSize.X
    ts.Parent = tabs
    local hL = Instance.new("UIListLayout")
    hL.FillDirection = Enum.FillDirection.Horizontal
    hL.Padding = UDim.new(0, 6)
    hL.SortOrder = Enum.SortOrder.LayoutOrder
    hL.Parent = ts
    tabContainer = ts
else
    local ts = Instance.new("ScrollingFrame")
    ts.Size = UDim2.new(1, 0, 1, 0)
    ts.BackgroundTransparency = 1
    ts.BorderSizePixel = 0
    ts.ScrollBarThickness = 3
    ts.CanvasSize = UDim2.new(0, 0, 0, 0)
    ts.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ts.Parent = tabs
    local vL = Instance.new("UIListLayout")
    vL.Padding = UDim.new(0, 6)
    vL.SortOrder = Enum.SortOrder.LayoutOrder
    vL.Parent = ts
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, 6); p.PaddingLeft = UDim.new(0, 6)
    p.PaddingRight = UDim.new(0, 6); p.PaddingBottom = UDim.new(0, 6)
    p.Parent = ts
    tabContainer = ts
end

local tabDefs = {
    {"AA",     buildAntiAim},
    {"Бой",    buildCombat},
    {"ESP",    buildESP},
    {"Режимы", buildPresets},
}

for i, def in ipairs(tabDefs) do
    local name, builder = def[1], def[2]
    local b = Instance.new("TextButton")
    if useHorizontalTabs then
        b.Size = UDim2.new(0, 90, 1, 0)
    else
        b.Size = UDim2.new(1, 0, 0, Platform.isMobile and 44 or 34)
    end
    b.BackgroundColor3 = Color3.fromRGB(50, 18, 26)
    b.BackgroundTransparency = 0.15
    b.BorderSizePixel = 0
    b.Font = Enum.Font.Gotham
    b.TextSize = Platform.isMobile and 15 or 14
    b.TextColor3 = Color3.fromRGB(255, 220, 230)
    b.Text = name
    b.Active = true
    b.Selectable = false
    b.Parent = tabContainer
    corner(b, 8)
    tabButtons[name] = b
    b.MouseButton1Click:Connect(function()
        for _, bb in pairs(tabButtons) do
            bb.BackgroundColor3 = Color3.fromRGB(50, 18, 26)
        end
        b.BackgroundColor3 = Color3.fromRGB(140, 40, 60)
        local ok, err = pcall(builder)
        if not ok then warn("[HVH] tab err:", err) end
    end)
end

tabButtons["AA"].BackgroundColor3 = Color3.fromRGB(140, 40, 60)
pcall(buildAntiAim)

print("[dadadovich HVH] ready")

--=========================================================
-- HOTKEYS
--=========================================================
if Platform.isPC then
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightAlt then
            main.Visible = not main.Visible
        elseif input.KeyCode == Enum.KeyCode.Insert then
            Config.Rage.Enabled = not Config.Rage.Enabled
        end
    end)
end

--=========================================================
-- NOTIFY
--=========================================================
task.spawn(function()
    for i = 1, 5 do
        local ok = pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "dadadovich HVH",
                Text = "loaded • Rage ready • dadka",
                Duration = 4,
            })
        end)
        if ok then break end
        task.wait(0.5)
    end
end)

print("[dadadovich HVH] loaded • team dadka • ready")
