--[[
    Livia Panel v2.1
    Speed | Jump | Fly | No Clip | Fullbright | Flashlight
    Adjustable global lighting and flashlight controls; touch-first UI.
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
    Speed = false, Jump = false, Fly = false, NoClip = false,
    Fullbright = false, Flashlight = false,
}
local V = {
    Speed = 50, Jump = 100, Fly = 60,
    Fullbright = 3,
    FlashlightBrightness = 3,
    FlashlightRange = 48,
    FlashlightAngle = 75,
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
    flashlight.Range = V.FlashlightRange
    flashlight.Angle = V.FlashlightAngle
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

    local intensity = math.clamp(V.Fullbright, 0.5, 5)
    local ambient = math.clamp(0.25 + intensity / 6, 0.35, 1)
    Lighting.Brightness = intensity
    Lighting.Ambient = Color3.new(ambient, ambient, ambient)
    Lighting.OutdoorAmbient = Color3.new(ambient, ambient, ambient)
    Lighting.GlobalShadows = false
    Lighting.ExposureCompensation = math.clamp((intensity - 2) * 0.3, 0, 0.9)
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
end

conns[#conns + 1] = RunService.Heartbeat:Connect(function()
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
Main.Size = UDim2.new(0, 320, 0, 410)
Main.Position = UDim2.new(0.5, -160, 0.5, -205)
Main.BackgroundColor3 = T.BG
Main.BorderSizePixel = 0
corner(Main, 14)
stroke(Main)

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 54)
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
Logo.Size = UDim2.new(0, 32, 0, 32)
Logo.Position = UDim2.new(0, 10, 0, 10)
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
Title.Position = UDim2.new(0, 49, 0, 4)
Title.BackgroundTransparency = 1
Title.Text = "LIVIA PANEL"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = T.Text
Title.TextXAlignment = Enum.TextXAlignment.Left

local Subtitle = Instance.new("TextLabel", Header)
Subtitle.Size = UDim2.new(0, 150, 0, 14)
Subtitle.Position = UDim2.new(0, 50, 0, 27)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "MOBILE UTILITY  •  V2.1"
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
Body.Size = UDim2.new(1, 0, 1, -54)
Body.Position = UDim2.new(0, 0, 0, 54)
Body.BackgroundTransparency = 1
Body.BorderSizePixel = 0
Body.CanvasSize = UDim2.new(0, 0, 0, 0)
Body.AutomaticCanvasSize = Enum.AutomaticSize.Y
Body.ScrollingDirection = Enum.ScrollingDirection.Y
Body.ScrollBarThickness = 3
Body.ScrollBarImageColor3 = T.Accent
Body.Active = true
local pad = Instance.new("UIPadding", Body)
pad.PaddingTop = UDim.new(0, 8)
pad.PaddingBottom = UDim.new(0, 10)
pad.PaddingLeft = UDim.new(0, 10)
pad.PaddingRight = UDim.new(0, 10)
local list = Instance.new("UIListLayout", Body)
list.Padding = UDim.new(0, 6)
list.SortOrder = Enum.SortOrder.LayoutOrder

local function createRow(label, key, hasValue)
    local row = Instance.new("Frame", Body)
    row.Size = UDim2.new(1, 0, 0, 42)
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
        box.Size = UDim2.new(0, 46, 0, 26)
        box.Position = UDim2.new(1, -108, 0.5, -13)
        box.BackgroundColor3 = T.Input
        box.Text = tostring(V[key])
        box.Font = Enum.Font.GothamBold
        box.TextSize = 12
        box.TextColor3 = T.Text
        box.ClearTextOnFocus = false
        corner(box, 8)
        box.FocusLost:Connect(function()
            local n = tonumber(box.Text)
            if n and n >= 0 then
                V[key] = n
            else
                box.Text = tostring(V[key])
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

local sliderDrag

local function createSliderRow(label, key, minValue, maxValue, step, hasToggle)
    local rowHeight = hasToggle and 70 or 62
    local row = Instance.new("Frame", Body)
    row.Size = UDim2.new(1, 0, 0, rowHeight)
    row.BackgroundColor3 = T.Card
    corner(row, 10)
    stroke(row)

    local lb = Instance.new("TextLabel", row)
    lb.Size = UDim2.new(1, hasToggle and -78 or -20, 0, 20)
    lb.Position = UDim2.new(0, 12, 0, 5)
    lb.BackgroundTransparency = 1
    lb.Text = label
    lb.Font = Enum.Font.GothamBold
    lb.TextSize = 10
    lb.TextColor3 = T.Text
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.TextYAlignment = Enum.TextYAlignment.Center

    if hasToggle then
        local toggle = Instance.new("TextButton", row)
        toggle.Size = UDim2.new(0, 52, 0, 26)
        toggle.Position = UDim2.new(1, -60, 0, 4)
        toggle.BackgroundColor3 = T.Off
        toggle.Text = "OFF"
        toggle.Font = Enum.Font.GothamBold
        toggle.TextSize = 10
        toggle.TextColor3 = T.Text
        toggle.AutoButtonColor = false
        corner(toggle, 8)
        bindDrag(toggle, Main, function()
            S[key] = not S[key]
            toggle.Text = S[key] and "ON" or "OFF"
            TweenService:Create(toggle, TweenInfo.new(0.15), {
                BackgroundColor3 = S[key] and T.On or T.Off
            }):Play()
            applyChange(key, S[key])
        end)
    end

    local track = Instance.new("Frame", row)
    track.Size = UDim2.new(1, -82, 0, 6)
    track.Position = UDim2.new(0, 12, 0, rowHeight - 17)
    track.BackgroundColor3 = T.Input
    track.BorderSizePixel = 0
    track.Active = true
    corner(track, 4)

    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = T.Accent
    fill.BorderSizePixel = 0
    fill.Active = false
    corner(fill, 4)

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(0, 0, 0.5, 0)
    knob.BackgroundColor3 = T.Text
    knob.BorderSizePixel = 0
    knob.Active = false
    corner(knob, 7)

    local valueLabel = Instance.new("TextLabel", row)
    valueLabel.Size = UDim2.new(0, 48, 0, 20)
    valueLabel.Position = UDim2.new(1, -58, 0, rowHeight - 25)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 10
    valueLabel.TextColor3 = T.Accent
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local function renderValue(value)
        local percent = math.clamp((value - minValue) / (maxValue - minValue), 0, 1)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, 0, 0.5, 0)
        if step < 1 then
            valueLabel.Text = string.format("%.1f", value)
        else
            valueLabel.Text = string.format("%.0f", value)
        end
    end

    local function updateFromX(x)
        local width = math.max(track.AbsoluteSize.X, 1)
        local percent = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
        local raw = minValue + (maxValue - minValue) * percent
        local value = math.clamp(math.floor(raw / step + 0.5) * step, minValue, maxValue)
        V[key] = value
        renderValue(value)

        if key == "Fullbright" and S.Fullbright then
            setFullbright(true)
        elseif key == "FlashlightBrightness" or key == "FlashlightRange" or key == "FlashlightAngle" then
            updateFlashlight()
        end
    end

    renderValue(V[key])
    track.InputBegan:Connect(function(input)
        if not isPress(input) then return end
        sliderDrag = {input = input, update = updateFromX}
        Body.ScrollingEnabled = false
        updateFromX(input.Position.X)
    end)
end

conns[#conns + 1] = UIS.InputChanged:Connect(function(input)
    if not sliderDrag then return end
    local isMouseDrag = input.UserInputType == Enum.UserInputType.MouseMovement
        and sliderDrag.input.UserInputType == Enum.UserInputType.MouseButton1
    if input == sliderDrag.input or isMouseDrag then
        sliderDrag.update(input.Position.X)
    end
end)

conns[#conns + 1] = UIS.InputEnded:Connect(function(input)
    if not sliderDrag then return end
    if input == sliderDrag.input or (isPress(input) and input.UserInputType == sliderDrag.input.UserInputType) then
        sliderDrag = nil
        Body.ScrollingEnabled = true
    end
end)

createRow("SPEED", "Speed", true)
createRow("JUMP", "Jump", true)
createRow("FLY", "Fly", true)
createRow("NO CLIP", "NoClip", false)
createSliderRow("FULLBRIGHT", "Fullbright", 0.5, 5, 0.1, true)
createRow("FLASHLIGHT", "Flashlight", false)
createSliderRow("FLASHLIGHT POWER", "FlashlightBrightness", 0.2, 10, 0.1, false)
createSliderRow("FLASHLIGHT RANGE", "FlashlightRange", 8, 120, 1, false)
createSliderRow("FLASHLIGHT ANGLE", "FlashlightAngle", 30, 120, 1, false)

-- ==========================================
-- CLEANUP
-- ==========================================
cleanup = function()
    for k in pairs(S) do
        if S[k] then S[k] = false applyChange(k, false) end
    end
    for _, c in ipairs(conns) do c:Disconnect() end
    conns = {}
    if sg then sg:Destroy() end
end
_G.LiviaCleanup = cleanup
