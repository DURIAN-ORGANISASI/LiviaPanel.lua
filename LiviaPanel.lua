--[[
    Livia Panel v2.2
    Speed | Jump | Fly | Fullbright | Flashlight | ESP Player | ESP Monster | No Clip
    Universal humanoid-based local ESP; touch-first UI.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

if _G.LiviaCleanup then pcall(_G.LiviaCleanup) end
if CoreGui:FindFirstChild("LiviaPanel") then CoreGui.LiviaPanel:Destroy() end

-- ==========================================
-- STATE
-- ==========================================
local S = {
    Speed = false, Jump = false, Fly = false,
    Fullbright = false, Flashlight = false,
    PlayerESP = false, MonsterESP = false, NoClip = false,
}
local V = {
    Speed = 50, Jump = 100, Fly = 60,
    Fullbright = 5,
    FlashlightBrightness = 5,
    PlayerESPDistance = 500,
    MonsterESPDistance = 500,
}

local T = {
    BG = Color3.fromRGB(13, 16, 27),
    Panel = Color3.fromRGB(21, 25, 40),
    Card = Color3.fromRGB(27, 33, 51),
    Input = Color3.fromRGB(35, 43, 65),
    Stroke = Color3.fromRGB(48, 59, 84),
    Accent = Color3.fromRGB(111, 116, 255),
    Text = Color3.fromRGB(243, 245, 255),
    Muted = Color3.fromRGB(155, 164, 189),
    Off = Color3.fromRGB(55, 64, 86),
    On = Color3.fromRGB(46, 204, 133),
    Red = Color3.fromRGB(244, 87, 109),
}

local function corner(o, r) local c = Instance.new("UICorner", o) c.CornerRadius = UDim.new(0, r or 10) return c end
local function stroke(o) local s = Instance.new("UIStroke", o) s.Color = T.Stroke s.Thickness = 1 return s end

-- ==========================================
-- FEATURE LOGIC
-- ==========================================
local conns = {}
local bv, bg
local noclipCache = setmetatable({}, {__mode = "k"})
local flashlight
local fullbrightOriginal
local espObjects = {}
local espScanElapsed = 0
local espFolder = Instance.new("Folder")
espFolder.Name = "LiviaESP"
espFolder.Parent = CoreGui


local function clearESP(model)
    local entry = espObjects[model]
    if not entry then return end
    if entry.highlight then entry.highlight:Destroy() end
    if entry.billboard then entry.billboard:Destroy() end
    espObjects[model] = nil
end

local function refreshESP()
    local active = S.PlayerESP or S.MonsterESP
    if not active then
        for model in pairs(espObjects) do clearESP(model) end
        return
    end

    local found = {}
    local _, _, localRoot = getChar()
    if not localRoot then return end
    local playerCharacters = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then playerCharacters[player.Character] = true end
    end

    for _, model in ipairs(workspace:GetDescendants()) do
        if model:IsA("Model") then
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head") or model.PrimaryPart
            if humanoid and humanoid.Health > 0 and root and model ~= LP.Character then
                local isPlayer = playerCharacters[model] == true
                local maxDistance = isPlayer and V.PlayerESPDistance or V.MonsterESPDistance
                local distance = (root.Position - localRoot.Position).Magnitude
                local shouldShow = ((isPlayer and S.PlayerESP) or (not isPlayer and S.MonsterESP))
                    and distance <= maxDistance
                if shouldShow then
                    found[model] = true
                    local color = isPlayer and Color3.fromRGB(65, 190, 255) or Color3.fromRGB(255, 75, 90)
                    local label = isPlayer and model.Name or (model.Name ~= "" and model.Name or "MONSTER")
                    local entry = espObjects[model]
                    if not entry then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "LiviaESPHighlight"
                        highlight.Adornee = model
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.FillTransparency = 0.78
                        highlight.OutlineTransparency = 0
                        highlight.Parent = espFolder

                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "LiviaESPLabel"
                        billboard.Adornee = root
                        billboard.Size = UDim2.fromOffset(150, 28)
                        billboard.StudsOffset = Vector3.new(0, 3, 0)
                        billboard.AlwaysOnTop = true
                        billboard.Parent = espFolder

                        local text = Instance.new("TextLabel")
                        text.Size = UDim2.fromScale(1, 1)
                        text.BackgroundTransparency = 1
                        text.Font = Enum.Font.GothamBold
                        text.TextSize = 12
                        text.TextStrokeTransparency = 0.25
                        text.Parent = billboard
                        entry = {highlight = highlight, billboard = billboard, text = text}
                        espObjects[model] = entry
                    end
                    entry.highlight.FillColor = color
                    entry.highlight.OutlineColor = color
                    entry.billboard.Adornee = root
                    entry.text.Text = label
                    entry.text.TextColor3 = color
                end
            end
        end
    end

    for model in pairs(espObjects) do
        if not found[model] or not model.Parent then clearESP(model) end
    end
end

local function getChar()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    return char, hum, hrp
end

local function stopFly()
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
    local _, hum = getChar()
    if hum then hum.PlatformStand = false end
end

local function restoreNoClip()
    for part, original in pairs(noclipCache) do
        if part and part.Parent then part.CanCollide = original end
    end
    noclipCache = setmetatable({}, {__mode = "k"})
end

local function setFlashlight(state)
    if not state then
        if flashlight then flashlight:Destroy() flashlight = nil end
        return
    end

    local char = LP.Character
    local target = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
    if not target then return end

    if flashlight and flashlight.Parent ~= target then
        flashlight:Destroy()
        flashlight = nil
    end
    if not flashlight then
        flashlight = Instance.new("SpotLight")
        flashlight.Name = "LiviaFlashlight"
        flashlight.Color = Color3.fromRGB(255, 244, 220)
        flashlight.Shadows = false
        flashlight.Face = Enum.NormalId.Front
        flashlight.Parent = target
    end

    flashlight.Brightness = V.FlashlightBrightness
    flashlight.Range = 48
    flashlight.Angle = 75
end

local function setFullbright(state)
    if not state then
        if fullbrightOriginal then
            for property, value in pairs(fullbrightOriginal) do
                Lighting[property] = value
            end
            fullbrightOriginal = nil
        end
        return
    end

    if not fullbrightOriginal then
        fullbrightOriginal = {
            Brightness = Lighting.Brightness,
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            GlobalShadows = Lighting.GlobalShadows,
            ExposureCompensation = Lighting.ExposureCompensation,
            FogStart = Lighting.FogStart,
            FogEnd = Lighting.FogEnd,
        }
    end

    local level = math.clamp(V.Fullbright, 1, 10)
    local intensity = 1 + (level - 1) * 0.8
    local ambient = math.clamp(0.25 + level / 13, 0.35, 1)
    Lighting.Brightness = intensity
    Lighting.Ambient = Color3.new(ambient, ambient, ambient)
    Lighting.OutdoorAmbient = Color3.new(ambient, ambient, ambient)
    Lighting.GlobalShadows = false
    Lighting.ExposureCompensation = math.clamp((level - 3) * 0.12, 0, 1)
    Lighting.FogStart = 0
    Lighting.FogEnd = 100000
end

local function updateFlashlight()
    if S.Flashlight then setFlashlight(true) end
end

local function applyChange(key, state)
    local _, hum, hrp = getChar()
    if key == "Speed" and not state and hum then hum.WalkSpeed = 16 end
    if key == "Jump" and not state and hum then hum.UseJumpPower = true hum.JumpPower = 50 end
    if key == "Fly" and not state then stopFly() end
    if key == "NoClip" and not state then restoreNoClip() end
    if key == "Fullbright" then setFullbright(state) end
    if key == "Flashlight" then setFlashlight(state) end
    if key == "PlayerESP" or key == "MonsterESP" then refreshESP() end
end

conns[#conns + 1] = RunService.Heartbeat:Connect(function(dt)
    espScanElapsed = espScanElapsed + dt
    if espScanElapsed >= 0.75 then
        espScanElapsed = 0
        refreshESP()
    end

    local _, hum, hrp = getChar()
    if not hum or not hrp then return end

    if S.Speed then hum.WalkSpeed = V.Speed end
    if S.Jump then hum.UseJumpPower = true hum.JumpPower = V.Jump end

    if S.Fly then
        local cam = workspace.CurrentCamera
        if not bv or bv.Parent ~= hrp then
            stopFly()
            bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp
            bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.P = 9e4
            bg.Parent = hrp
        end
        hum.PlatformStand = true
        local look = cam.CFrame.LookVector
        local flat = Vector3.new(look.X, 0, look.Z)
        if flat.Magnitude > 0 then
            flat = flat.Unit
            bg.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + flat)
        end
        local dir = hum.MoveDirection
        local vel = dir * V.Fly
        if dir.Magnitude > 0 and flat.Magnitude > 0 then
            local forward = dir:Dot(flat)
            vel = vel + Vector3.new(0, look.Y * forward * V.Fly, 0)
        end
        bv.Velocity = vel
    end

    if S.Flashlight then setFlashlight(true) end
end)

conns[#conns + 1] = RunService.Stepped:Connect(function()
    if not S.NoClip then return end
    local char = LP.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if noclipCache[part] == nil then noclipCache[part] = part.CanCollide end
            part.CanCollide = false
        end
    end
end)

conns[#conns + 1] = LP.CharacterAdded:Connect(function()
    noclipCache = setmetatable({}, {__mode = "k"})
end)

-- ==========================================
-- TAP vs DRAG SYSTEM
-- Geser > 10 px = memindahkan panel (tombol TIDAK aktif)
-- Sentuh singkat  = dianggap tap (tombol aktif)
-- ==========================================
local DRAG_THRESHOLD = 10
local drag = {active = false}

local function isPress(i)
    return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end

local function bindDrag(obj, target, onTap)
    obj.InputBegan:Connect(function(i)
        if not isPress(i) then return end
        if drag.active then
            if drag.input == i and onTap and not drag.onTap then drag.onTap = onTap end
            return
        end
        drag = {
            active = true, input = i, startPos = i.Position,
            target = target, origin = target.Position,
            moved = false, onTap = onTap,
        }
    end)
end

conns[#conns + 1] = UIS.InputChanged:Connect(function(i)
    if not drag.active then return end
    local valid = (i == drag.input) or (i.UserInputType == Enum.UserInputType.MouseMovement and drag.input.UserInputType == Enum.UserInputType.MouseButton1)
    if not valid then return end
    local d = i.Position - drag.startPos
    if not drag.moved and Vector2.new(d.X, d.Y).Magnitude > DRAG_THRESHOLD then drag.moved = true end
    if drag.moved then
        local o = drag.origin
        drag.target.Position = UDim2.new(o.X.Scale, o.X.Offset + d.X, o.Y.Scale, o.Y.Offset + d.Y)
    end
end)

conns[#conns + 1] = UIS.InputEnded:Connect(function(i)
    if not drag.active then return end
    if i == drag.input or (isPress(i) and i.UserInputType == drag.input.UserInputType) then
        local tap = (not drag.moved) and drag.onTap
        drag = {active = false}
        if tap then tap() end
    end
end)

-- ==========================================
-- UI
-- ==========================================
local cleanup

local sg = Instance.new("ScreenGui", CoreGui)
sg.Name = "LiviaPanel"
sg.ResetOnSpawn = false

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 280, 0, 340)
Main.Position = UDim2.new(0.5, -140, 0.5, -170)
Main.BackgroundColor3 = T.BG
Main.BorderSizePixel = 0
corner(Main, 14)
stroke(Main)

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 46)
Header.BackgroundColor3 = T.Panel
Header.BorderSizePixel = 0
corner(Header, 14)
bindDrag(Header, Main)

local headerGradient = Instance.new("UIGradient")
headerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, T.Panel),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 32, 58)),
})
headerGradient.Parent = Header

local hc = Instance.new("Frame", Header)
hc.Size = UDim2.new(1, 0, 0, 14)
hc.Position = UDim2.new(0, 0, 1, -14)
hc.BackgroundColor3 = T.Panel
hc.BorderSizePixel = 0

local line = Instance.new("Frame", Header)
line.Size = UDim2.new(1, 0, 0, 2)
line.Position = UDim2.new(0, 0, 1, -2)
line.BackgroundColor3 = T.Accent
line.BorderSizePixel = 0

local Logo = Instance.new("Frame", Header)
Logo.Size = UDim2.new(0, 28, 0, 28)
Logo.Position = UDim2.new(0, 9, 0, 9)
Logo.BackgroundColor3 = T.Accent
Logo.BorderSizePixel = 0
corner(Logo, 11)
local logoGradient = Instance.new("UIGradient")
logoGradient.Color = ColorSequence.new(T.Accent, Color3.fromRGB(65, 198, 255))
logoGradient.Rotation = 35
logoGradient.Parent = Logo
local LogoText = Instance.new("TextLabel", Logo)
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "L"
LogoText.Font = Enum.Font.GothamBlack
LogoText.TextSize = 21
LogoText.TextColor3 = T.Text

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0, 150, 0, 22)
Title.Position = UDim2.new(0, 44, 0, 2)
Title.BackgroundTransparency = 1
Title.Text = "LIVIA PANEL"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = T.Text
Title.TextXAlignment = Enum.TextXAlignment.Left

local Subtitle = Instance.new("TextLabel", Header)
Subtitle.Size = UDim2.new(0, 150, 0, 14)
Subtitle.Position = UDim2.new(0, 45, 0, 24)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "MOBILE UTILITY  •  V2.3"
Subtitle.Font = Enum.Font.GothamMedium
Subtitle.TextSize = 9
Subtitle.TextColor3 = T.Muted
Subtitle.TextXAlignment = Enum.TextXAlignment.Left

local function headBtn(x, txt, col)
    local b = Instance.new("TextButton", Header)
    b.Size = UDim2.new(0, 30, 0, 30)
    b.Position = UDim2.new(1, x, 0.5, -15)
    b.BackgroundColor3 = col
    b.Text = txt
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.TextColor3 = T.Text
    b.AutoButtonColor = false
    corner(b, 8)
    return b
end
local CloseBtn = headBtn(-36, "X", T.Red)
local MinBtn = headBtn(-73, "-", T.Input)

local OpenBtn = Instance.new("TextButton", sg)
OpenBtn.Size = UDim2.new(0, 48, 0, 48)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -24)
OpenBtn.BackgroundColor3 = T.Accent
OpenBtn.Text = "L"
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 24
OpenBtn.TextColor3 = T.Text
OpenBtn.AutoButtonColor = false
OpenBtn.Visible = false
corner(OpenBtn, 26)

bindDrag(MinBtn, Main, function() Main.Visible = false OpenBtn.Visible = true end)
bindDrag(OpenBtn, OpenBtn, function() Main.Visible = true OpenBtn.Visible = false end)
bindDrag(CloseBtn, Main, function() cleanup() end)

local Body = Instance.new("ScrollingFrame", Main)
Body.Size = UDim2.new(1, 0, 1, -46)
Body.Position = UDim2.new(0, 0, 0, 46)
Body.BackgroundTransparency = 1
Body.BorderSizePixel = 0
Body.CanvasSize = UDim2.new(0, 0, 0, 0)
Body.AutomaticCanvasSize = Enum.AutomaticSize.Y
Body.ScrollingDirection = Enum.ScrollingDirection.Y
Body.ScrollBarThickness = 3
Body.ScrollBarImageColor3 = T.Accent
Body.Active = true
local pad = Instance.new("UIPadding", Body)
pad.PaddingTop = UDim.new(0, 6)
pad.PaddingBottom = UDim.new(0, 10)
pad.PaddingLeft = UDim.new(0, 8)
pad.PaddingRight = UDim.new(0, 8)
local list = Instance.new("UIListLayout", Body)
list.Padding = UDim.new(0, 5)
list.SortOrder = Enum.SortOrder.LayoutOrder

local function createRow(label, key, hasValue)
    local row = Instance.new("Frame", Body)
    row.Size = UDim2.new(1, 0, 0, 38)
    row.BackgroundColor3 = T.Card
    corner(row, 10)
    stroke(row)

    local lb = Instance.new("TextLabel", row)
    lb.Size = UDim2.new(1, -125, 1, 0)
    lb.Position = UDim2.new(0, 12, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = label
    lb.Font = Enum.Font.GothamBold
    lb.TextSize = 11
    lb.TextColor3 = T.Text
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.TextYAlignment = Enum.TextYAlignment.Center

    if hasValue then
        local box = Instance.new("TextBox", row)
        box.Size = UDim2.new(0, 42, 0, 24)
        box.Position = UDim2.new(1, -104, 0.5, -12)
        box.BackgroundColor3 = T.Input
        local valueKey = key == "PlayerESP" and "PlayerESPDistance" or key == "MonsterESP" and "MonsterESPDistance" or key
        box.Text = tostring(V[valueKey])
        box.Font = Enum.Font.GothamBold
        box.TextSize = 12
        box.TextColor3 = T.Text
        box.ClearTextOnFocus = false
        corner(box, 8)
        box.FocusLost:Connect(function()
            local n = tonumber(box.Text)
            local isDistance = key == "PlayerESP" or key == "MonsterESP"
            local limited = key == "Fullbright"
            local minValue = (limited or isDistance) and 1 or 0
            local maxValue = isDistance and 500 or (limited and 10 or math.huge)
            if n and n >= minValue and n <= maxValue then
                V[key == "PlayerESP" and "PlayerESPDistance" or key == "MonsterESP" and "MonsterESPDistance" or key] = isDistance and math.floor(n) or n
                if key == "Fullbright" and S.Fullbright then setFullbright(true) end
                if isDistance then
                    box.Text = tostring(V[key == "PlayerESP" and "PlayerESPDistance" or "MonsterESPDistance"])
                    refreshESP()
                end
            else
                box.Text = tostring(isDistance and V[key == "PlayerESP" and "PlayerESPDistance" or "MonsterESPDistance"] or V[key])
            end
        end)
    end

    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(0, 52, 0, 28)
    btn.Position = UDim2.new(1, -60, 0.5, -14)
    btn.BackgroundColor3 = T.Off
    btn.Text = "OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = T.Text
    btn.AutoButtonColor = false
    corner(btn, 8)

    bindDrag(btn, Main, function()
        S[key] = not S[key]
        btn.Text = S[key] and "ON" or "OFF"
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = S[key] and T.On or T.Off}):Play()
        applyChange(key, S[key])
    end)
end

local function createValueRow(label, key)
    local row = Instance.new("Frame", Body)
    row.Size = UDim2.new(1, 0, 0, 38)
    row.BackgroundColor3 = T.Card
    corner(row, 10)
    stroke(row)
    local lb = Instance.new("TextLabel", row)
    lb.Size = UDim2.new(1, -66, 1, 0)
    lb.Position = UDim2.new(0, 12, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = label
    lb.Font = Enum.Font.GothamBold
    lb.TextSize = 10
    lb.TextColor3 = T.Text
    lb.TextXAlignment = Enum.TextXAlignment.Left
    local box = Instance.new("TextBox", row)
    box.Size = UDim2.new(0, 42, 0, 24)
    box.Position = UDim2.new(1, -54, 0.5, -12)
    box.BackgroundColor3 = T.Input
    box.Text = tostring(V[key])
    box.Font = Enum.Font.GothamBold
    box.TextSize = 12
    box.TextColor3 = T.Text
    box.ClearTextOnFocus = false
    corner(box, 8)
    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n and n >= 1 and n <= 10 then
            V[key] = math.floor(n)
            box.Text = tostring(V[key])
            if key == "FlashlightBrightness" then updateFlashlight() end
        else
            box.Text = tostring(V[key])
        end
    end)
end



createRow("SPEED", "Speed", true)
createRow("JUMP", "Jump", true)
createRow("FLY", "Fly", true)
createRow("FULLBRIGHT (1-10)", "Fullbright", true)
createRow("FLASHLIGHT", "Flashlight", false)
createValueRow("FLASHLIGHT POWER (1-10)", "FlashlightBrightness")
createRow("ESP PLAYER", "PlayerESP", true)
createRow("ESP MONSTER", "MonsterESP", true)
createRow("NO CLIP", "NoClip", false)

-- ==========================================
-- CLEANUP
-- ==========================================
cleanup = function()
    for k in pairs(S) do
        if S[k] then S[k] = false applyChange(k, false) end
    end
    for model in pairs(espObjects) do clearESP(model) end
    if espFolder then espFolder:Destroy() end
    for _, c in ipairs(conns) do c:Disconnect() end
    conns = {}
    if sg then sg:Destroy() end
end
_G.LiviaCleanup = cleanup
