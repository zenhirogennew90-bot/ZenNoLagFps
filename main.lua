-- ============================================
-- FULL ESP - MINIMAL DARK + SCALE SLIDER
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ============================================
-- KONFIGURASI
-- ============================================
local Config = {
    ESPUsername = false,
    ESPHighlight = false,
    ESPLine = false,
    ESPTitikKepala = false,
    ESPJarak = false,
    TeamCheck = false,
    MaxDistance = 1000,
    ESPColor = Color3.fromRGB(0, 220, 120),
    ESPVisualScale = 1.0,   -- slider global
    NameOffset = 2.5,       -- offset tinggi nama di atas kepala
}

local ESPObjects, Highlights = {}, {}
local switches, swatchStrokes = {}, {}

-- base sizes (dipakai * scale)
local BASE = {
    UserSize = 18,
    JarakSize = 14,
    DotRadius = 6,
    LineThick = 1,
}

-- ============================================
-- HELPER
-- ============================================
local function newDrawing(class)
    local ok, obj = pcall(function() return Drawing.new(class) end)
    if ok then return obj end
end

local function getCharacterData(plr)
    if plr == LocalPlayer then return nil end
    local char = plr.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not head or not humanoid or humanoid.Health <= 0 then return nil end
    if Config.TeamCheck and plr.Team == LocalPlayer.Team then return nil end
    if (Camera.CFrame.Position - hrp.Position).Magnitude > Config.MaxDistance then return nil end
    return hrp, head, humanoid
end

local function worldToViewport(pos)
    local sp, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), onScreen
end

local function scaled(n)
    return math.floor(n * Config.ESPVisualScale + 0.5)
end

-- ============================================
-- APPLY SCALE KE SEMUA ESP
-- ============================================
local function applyVisualScale()
    for _, esp in pairs(ESPObjects) do
        if esp.Username then esp.Username.Size = math.max(8, scaled(BASE.UserSize)) end
        if esp.Jarak then esp.Jarak.Size = math.max(8, scaled(BASE.JarakSize)) end
        if esp.HeadDot then esp.HeadDot.Radius = math.max(2, scaled(BASE.DotRadius)) end
        if esp.Line then esp.Line.Thickness = math.max(1, scaled(BASE.LineThick)) end
    end
end

-- ============================================
-- ESP OBJECTS
-- ============================================
local function createESP(plr)
    if ESPObjects[plr] then return end
    local esp = {
        Username = newDrawing("Text"),
        Jarak    = newDrawing("Text"),
        HeadDot  = newDrawing("Circle"),
        Line     = newDrawing("Line"),
    }
    if esp.Username then
        esp.Username.Center = true
        esp.Username.Outline = true
        esp.Username.Size = math.max(8, scaled(BASE.UserSize))
        esp.Username.Font = 2
        esp.Username.Color = Config.ESPColor
        esp.Username.Visible = false
    end
    if esp.Jarak then
        esp.Jarak.Center = true
        esp.Jarak.Outline = true
        esp.Jarak.Size = math.max(8, scaled(BASE.JarakSize))
        esp.Jarak.Font = 2
        esp.Jarak.Color = Config.ESPColor
        esp.Jarak.Visible = false
    end
    if esp.HeadDot then
        esp.HeadDot.Thickness = 2
        esp.HeadDot.NumSides = 20
        esp.HeadDot.Filled = true
        esp.HeadDot.Color = Config.ESPColor
        esp.HeadDot.Radius = math.max(2, scaled(BASE.DotRadius))
        esp.HeadDot.Visible = false
    end
    if esp.Line then
        esp.Line.Thickness = math.max(1, scaled(BASE.LineThick))
        esp.Line.Color = Config.ESPColor
        esp.Line.Visible = false
    end
    ESPObjects[plr] = esp

    local hl = Instance.new("Highlight")
    hl.Adornee = plr.Character
    hl.FillColor = Config.ESPColor
    hl.OutlineColor = Config.ESPColor
    hl.FillTransparency = 0.55
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = false
    hl.Parent = plr.Character
    Highlights[plr] = hl
end

local function removeESP(plr)
    local esp = ESPObjects[plr]
    if esp then
        for _, obj in pairs(esp) do
            if obj then pcall(function() obj:Remove() end) end
        end
        ESPObjects[plr] = nil
    end
    local hl = Highlights[plr]
    if hl then
        pcall(function() hl:Destroy() end)
        Highlights[plr] = nil
    end
end

-- ============================================
-- UPDATE ESP
-- ============================================
local function updateESP()
    for plr, esp in pairs(ESPObjects) do
        local hrp, head, humanoid = getCharacterData(plr)

        if not hrp then
            for _, obj in pairs(esp) do
                if obj then obj.Visible = false end
            end
            local hl = Highlights[plr]
            if hl then hl.Enabled = false end
        else
            local headCenter, headOnScreen = worldToViewport(head.Position)
            local rootPos, rootOnScreen = worldToViewport(hrp.Position)
            local distStuds = (Camera.CFrame.Position - hrp.Position).Magnitude
            local distMeters = math.floor(distStuds / 3.5 + 0.5)

            -- Username (Kapital Semua + Configurable Offset Tinggi)
            if esp.Username then
                local show = Config.ESPUsername and headOnScreen
                esp.Username.Visible = show
                if show then
                    local headTop = head.Position + Vector3.new(0, head.Size.Y * 0.5 + Config.NameOffset, 0)
                    local np, on = worldToViewport(headTop)
                    if on then
                        esp.Username.Text = string.upper(plr.Name)
                        esp.Username.Position = np
                    else
                        esp.Username.Visible = false
                    end
                end
            end

            -- Jarak
            if esp.Jarak then
                local show = Config.ESPJarak and headOnScreen
                esp.Jarak.Visible = show
                if show then
                    local jarakPos = head.Position + Vector3.new(0, head.Size.Y * 0.5 + 1.2, 0)
                    local jp, on = worldToViewport(jarakPos)
                    if on then
                        esp.Jarak.Text = "[ " .. distMeters .. " m ]"
                        esp.Jarak.Position = jp
                    else
                        esp.Jarak.Visible = false
                    end
                end
            end

            -- Highlight
            local hl = Highlights[plr]
            if hl then
                hl.Enabled = Config.ESPHighlight
                if hl.Adornee ~= plr.Character then hl.Adornee = plr.Character end
            end

            -- Line
            if esp.Line then
                local show = Config.ESPLine and rootOnScreen
                esp.Line.Visible = show
                if show then
                    esp.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    esp.Line.To = rootPos
                end
            end

            -- Titik Kepala
            if esp.HeadDot then
                esp.HeadDot.Visible = Config.ESPTitikKepala and headOnScreen
                if esp.HeadDot.Visible then
                    esp.HeadDot.Position = headCenter
                end
            end
        end
    end
end

local renderConn = RunService.RenderStepped:Connect(updateESP)

-- ============================================
-- PLAYER HANDLING
-- ============================================
local function onPlayerAdded(plr)
    if plr == LocalPlayer then return end
    createESP(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.5)
        removeESP(plr)
        createESP(plr)
    end)
end
for _, plr in ipairs(Players:GetPlayers()) do onPlayerAdded(plr) end
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(removeESP)

-- ============================================
-- COLOR SYSTEM
-- ============================================
local PALETTE = {
    { name = "Merah",  color = Color3.fromRGB(255, 75, 75) },
    { name = "Kuning", color = Color3.fromRGB(255, 205, 60) },
    { name = "Biru",   color = Color3.fromRGB(70, 140, 255) },
    { name = "Hijau",  color = Color3.fromRGB(0, 220, 120) },
    { name = "Putih",  color = Color3.fromRGB(240, 240, 245) },
    { name = "Cyan",   color = Color3.fromRGB(0, 220, 220) },
}
local activeColorIdx = 4

local SliderFillRef, SliderKnobRef   

local function applyColor(color, idx)
    Config.ESPColor = color
    activeColorIdx = idx
    for _, esp in pairs(ESPObjects) do
        if esp.Username then esp.Username.Color = color end
        if esp.Jarak then esp.Jarak.Color = color end
        if esp.HeadDot then esp.HeadDot.Color = color end
        if esp.Line then esp.Line.Color = color end
    end
    for _, hl in pairs(Highlights) do
        hl.FillColor = color
        hl.OutlineColor = color
    end
    for _, sw in pairs(switches) do sw.update() end
    for i, st in ipairs(swatchStrokes) do
        TweenService:Create(st, TweenInfo.new(0.2), {Transparency = (i == idx) and 0 or 1}):Play()
    end
    if SliderFillRef then
        TweenService:Create(SliderFillRef, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
    end
end

-- ============================================
-- GUI THEME
-- ============================================
local C = {
    bg        = Color3.fromRGB(22, 22, 28),
    panel     = Color3.fromRGB(30, 30, 38),
    stroke    = Color3.fromRGB(48, 48, 58),
    text      = Color3.fromRGB(232, 232, 238),
    textDim   = Color3.fromRGB(140, 140, 152),
    switchOff = Color3.fromRGB(58, 58, 68),
    knob      = Color3.fromRGB(238, 238, 242),
    danger    = Color3.fromRGB(220, 60, 60),
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESP_Minimal"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- ============================================
-- FLOATING BUTTON
-- ============================================
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 110, 0, 34)
OpenBtn.Position = UDim2.new(0, 20, 0, 20)
OpenBtn.BackgroundColor3 = C.bg
OpenBtn.BackgroundTransparency = 0.03
OpenBtn.BorderSizePixel = 0
OpenBtn.Text = ""
OpenBtn.AutoButtonColor = false
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 10)
local openStroke = Instance.new("UIStroke", OpenBtn)
openStroke.Color = C.stroke
openStroke.Thickness = 1

local openDot = Instance.new("Frame")
openDot.Size = UDim2.new(0, 8, 0, 8)
openDot.Position = UDim2.new(0, 14, 0.5, -4)
openDot.BackgroundColor3 = Config.ESPColor
openDot.BorderSizePixel = 0
openDot.Parent = OpenBtn
Instance.new("UICorner", openDot).CornerRadius = UDim.new(1, 0)

local openLbl = Instance.new("TextLabel")
openLbl.Size = UDim2.new(1, -32, 1, 0)
openLbl.Position = UDim2.new(0, 30, 0, 0)
openLbl.BackgroundTransparency = 1
openLbl.Text = "ESP"
openLbl.TextColor3 = C.text
openLbl.Font = Enum.Font.GothamMedium
openLbl.TextSize = 13
openLbl.TextXAlignment = Enum.TextXAlignment.Left
openLbl.Parent = OpenBtn

-- ============================================
-- MAIN PANEL
-- ============================================
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 230, 0, 420)   -- Diperbesar untuk menampung tombol tambahan
Main.Position = UDim2.new(0, 20, 0, 72)
Main.BackgroundColor3 = C.bg
Main.BackgroundTransparency = 0.03
Main.BorderSizePixel = 0
Main.Visible = false
Main.ClipsDescendants = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = C.stroke
mainStroke.Thickness = 1

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -28, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ESP"
Title.TextColor3 = C.text
Title.Font = Enum.Font.GothamMedium
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(1, -20, 0, 1)
Separator.Position = UDim2.new(0, 10, 0, 40)
Separator.BackgroundColor3 = C.stroke
Separator.BackgroundTransparency = 0.4
Separator.BorderSizePixel = 0
Separator.Parent = Main

-- ============================================
-- SCROLLING AREA
-- ============================================
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 0, 196)
Scroll.Position = UDim2.new(0, 8, 0, 44)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 2
Scroll.ScrollBarImageColor3 = C.stroke
Scroll.ScrollBarImageTransparency = 0.5
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = Main

local ScrollPad = Instance.new("UIPadding", Scroll)
ScrollPad.PaddingTop = UDim.new(0, 4)
ScrollPad.PaddingBottom = UDim.new(0, 4)
ScrollPad.PaddingRight = UDim.new(0, 4)

local ScrollList = Instance.new("UIListLayout", Scroll)
ScrollList.Padding = UDim.new(0, 2)
ScrollList.SortOrder = Enum.SortOrder.LayoutOrder

-- ============================================
-- SWITCH BUILDER
-- ============================================
local function createSwitch(order, labelText, configKey)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = C.panel
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.AutoButtonColor = false
    row.Text = ""
    row.LayoutOrder = order
    row.Parent = Scroll
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 34, 0, 20)
    track.Position = UDim2.new(1, -42, 0.5, -10)
    track.BackgroundColor3 = C.switchOff
    track.BorderSizePixel = 0
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = C.knob
    knob.BorderSizePixel = 0
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function update(animate)
        local tInfo = TweenInfo.new(animate and 0.2 or 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        if Config[configKey] then
            TweenService:Create(track, tInfo, {BackgroundColor3 = Config.ESPColor}):Play()
            TweenService:Create(knob, tInfo, {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
        else
            TweenService:Create(track, tInfo, {BackgroundColor3 = C.switchOff}):Play()
            TweenService:Create(knob, tInfo, {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
        end
    end

    row.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        update(true)
    end)
    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundTransparency = 0.85}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
    end)

    table.insert(switches, { update = update })
    update(false)
end

createSwitch(1, "Username",      "ESPUsername")
createSwitch(2, "Jarak",         "ESPJarak")
createSwitch(3, "Highlight",     "ESPHighlight")
createSwitch(4, "Line",          "ESPLine")
createSwitch(5, "Titik Kepala",  "ESPTitikKepala")

-- ============================================
-- TOMBOL/PENGATURAN TINGGI NAMA (NAME HEIGHT)
-- ============================================
local function createHeightButton(order)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = C.panel
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.AutoButtonColor = false
    row.Text = ""
    row.LayoutOrder = order
    row.Parent = Scroll
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Tinggi Nama"
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 50, 1, 0)
    valLbl.Position = UDim2.new(1, -55, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = string.format("%.1f", Config.NameOffset)
    valLbl.TextColor3 = C.textDim
    valLbl.Font = Enum.Font.GothamMedium
    valLbl.TextSize = 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = row

    row.MouseButton1Click:Connect(function()
        Config.NameOffset = Config.NameOffset + 0.5
        if Config.NameOffset > 5.0 then
            Config.NameOffset = 2.0
        end
        valLbl.Text = string.format("%.1f", Config.NameOffset)
    end)
    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundTransparency = 0.85}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
    end)
end
createHeightButton(6)

-- ============================================
-- COLOR SECTION
-- ============================================
local Sep2 = Instance.new("Frame")
Sep2.Size = UDim2.new(1, -20, 0, 1)
Sep2.Position = UDim2.new(0, 10, 0, 244)
Sep2.BackgroundColor3 = C.stroke
Sep2.BackgroundTransparency = 0.4
Sep2.BorderSizePixel = 0
Sep2.Parent = Main

local ColorLabel = Instance.new("TextLabel")
ColorLabel.Size = UDim2.new(1, -20, 0, 14)
ColorLabel.Position = UDim2.new(0, 14, 0, 252)
ColorLabel.BackgroundTransparency = 1
ColorLabel.Text = "Warna"
ColorLabel.TextColor3 = C.textDim
ColorLabel.Font = Enum.Font.Gotham
ColorLabel.TextSize = 11
ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
ColorLabel.Parent = Main

local SwatchContainer = Instance.new("Frame")
SwatchContainer.Size = UDim2.new(1, -20, 0, 26)
SwatchContainer.Position = UDim2.new(0, 10, 0, 272)
SwatchContainer.BackgroundTransparency = 1
SwatchContainer.Parent = Main

local SwatchList = Instance.new("UIListLayout", SwatchContainer)
SwatchList.FillDirection = Enum.FillDirection.Horizontal
SwatchList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SwatchList.VerticalAlignment = Enum.VerticalAlignment.Center
SwatchList.Padding = UDim.new(0, 6)
SwatchList.SortOrder = Enum.SortOrder.LayoutOrder

for i, entry in ipairs(PALETTE) do
    local sw = Instance.new("TextButton")
    sw.Size = UDim2.new(0, 24, 0, 24)
    sw.BackgroundColor3 = entry.color
    sw.Text = ""
    sw.AutoButtonColor = false
    sw.BorderSizePixel = 0
    sw.LayoutOrder = i
    sw.Parent = SwatchContainer

local st = Instance.new("UIStroke", sw)
    st.Color = Color3.fromRGB(245, 245, 250)
    st.Thickness = 2
    st.Transparency = 1

    sw.MouseButton1Click:Connect(function()
        applyColor(entry.color, i)
    end)
    sw.MouseEnter:Connect(function()
        if activeColorIdx ~= i then
            TweenService:Create(st, TweenInfo.new(0.15), {Transparency = 0.5}):Play()
        end
    end)
    sw.MouseLeave:Connect(function()
        if activeColorIdx ~= i then
            TweenService:Create(st, TweenInfo.new(0.15), {Transparency = 1}):Play()
        end
    end)

    table.insert(swatchStrokes, st)
end

-- ============================================
-- SCALE SLIDER SECTION
-- ============================================
local Sep3 = Instance.new("Frame")
Sep3.Size = UDim2.new(1, -20, 0, 1)
Sep3.Position = UDim2.new(0, 10, 0, 308)
Sep3.BackgroundColor3 = C.stroke
Sep3.BackgroundTransparency = 0.4
Sep3.BorderSizePixel = 0
Sep3.Parent = Main

local ScaleLabel = Instance.new("TextLabel")
ScaleLabel.Size = UDim2.new(1, -60, 0, 14)
ScaleLabel.Position = UDim2.new(0, 14, 0, 316)
ScaleLabel.BackgroundTransparency = 1
ScaleLabel.Text = "Ukuran"
ScaleLabel.TextColor3 = C.textDim
ScaleLabel.Font = Enum.Font.Gotham
ScaleLabel.TextSize = 11
ScaleLabel.TextXAlignment = Enum.TextXAlignment.Left
ScaleLabel.Parent = Main

local ScaleValue = Instance.new("TextLabel")
ScaleValue.Size = UDim2.new(0, 50, 0, 14)
ScaleValue.Position = UDim2.new(1, -64, 0, 316)
ScaleValue.BackgroundTransparency = 1
ScaleValue.Text = "1.0x"
ScaleValue.TextColor3 = C.text
ScaleValue.Font = Enum.Font.GothamMedium
ScaleValue.TextSize = 11
ScaleValue.TextXAlignment = Enum.TextXAlignment.Right
ScaleValue.Parent = Main

local SliderHit = Instance.new("Frame")
SliderHit.Size = UDim2.new(1, -20, 0, 22)
SliderHit.Position = UDim2.new(0, 10, 0, 336)
SliderHit.BackgroundTransparency = 1
SliderHit.Parent = Main

local SliderTrack = Instance.new("Frame")
SliderTrack.Size = UDim2.new(1, 0, 0, 4)
SliderTrack.Position = UDim2.new(0, 0, 0.5, -2)
SliderTrack.BackgroundColor3 = C.switchOff
SliderTrack.BorderSizePixel = 0
SliderTrack.Parent = SliderHit
Instance.new("UICorner", SliderTrack).CornerRadius = UDim.new(1, 0)

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
SliderFill.BackgroundColor3 = Config.ESPColor
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderTrack
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
SliderFillRef = SliderFill

local SliderKnob = Instance.new("Frame")
SliderKnob.Size = UDim2.new(0, 12, 0, 12)
SliderKnob.Position = UDim2.new(0.5, -6, 0.5, -6)
SliderKnob.BackgroundColor3 = C.knob
SliderKnob.BorderSizePixel = 0
SliderKnob.Parent = SliderTrack
Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(1, 0)
SliderKnobRef = SliderKnob

local function updateSlider(input)
    local sizeX = SliderTrack.AbsoluteSize.X
    local posLoc = math.clamp(input.Position.X - SliderTrack.AbsolutePosition.X, 0, sizeX)
    local scale = posLoc / sizeX
    Config.ESPVisualScale = math.round((0.5 + (scale * 2.0)) * 10) / 10
    Config.ESPVisualScale = math.clamp(Config.ESPVisualScale, 0.5, 2.5)
    
    local fillPct = (Config.ESPVisualScale - 0.5) / 2.0
    SliderFill.Size = UDim2.new(fillPct, 0, 1, 0)
    SliderKnob.Position = UDim2.new(fillPct, -6, 0.5, -6)
    ScaleValue.Text = string.format("%.1fx", Config.ESPVisualScale)
    
    applyVisualScale()
end

local draggingSlider = false
SliderHit.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = true
        updateSlider(input)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = false
    end
end)
UIS.InputChanged:Connect(function(input)
    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

-- Initial slider pos
local function initSliderPos()
    local fillPct = (Config.ESPVisualScale - 0.5) / 2.0
    SliderFill.Size = UDim2.new(fillPct, 0, 1, 0)
    SliderKnob.Position = UDim2.new(fillPct, -6, 0.5, -6)
    ScaleValue.Text = string.format("%.1fx", Config.ESPVisualScale)
end
task.spawn(initSliderPos)

-- ============================================
-- TOMBOL UNLOAD / HAPUS MENU + FLOATING
-- ============================================
local Sep4 = Instance.new("Frame")
Sep4.Size = UDim2.new(1, -20, 0, 1)
Sep4.Position = UDim2.new(0, 10, 0, 366)
Sep4.BackgroundColor3 = C.stroke
Sep4.BackgroundTransparency = 0.4
Sep4.BorderSizePixel = 0
Sep4.Parent = Main

local UnloadBtn = Instance.new("TextButton")
UnloadBtn.Size = UDim2.new(1, -20, 0, 32)
UnloadBtn.Position = UDim2.new(0, 10, 0, 376)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(40, 28, 34)
UnloadBtn.BackgroundTransparency = 0.2
UnloadBtn.BorderSizePixel = 0
UnloadBtn.Text = "Hapus ESP & Menu"
UnloadBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
UnloadBtn.Font = Enum.Font.GothamMedium
UnloadBtn.TextSize = 12
UnloadBtn.AutoButtonColor = false
UnloadBtn.Parent = Main
Instance.new("UICorner", UnloadBtn).CornerRadius = UDim.new(0, 8)
local unloadStroke = Instance.new("UIStroke", UnloadBtn)
unloadStroke.Color = Color3.fromRGB(120, 45, 45)
unloadStroke.Thickness = 1

UnloadBtn.MouseButton1Click:Connect(function()
    if renderConn then
        renderConn:Disconnect()
    end
    for plr, _ in pairs(ESPObjects) do
        removeESP(plr)
    end
    if ScreenGui then
        pcall(function() ScreenGui:Destroy() end)
    end
end)

UnloadBtn.MouseEnter:Connect(function()
    TweenService:Create(UnloadBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(70, 32, 38)}):Play()
end)
UnloadBtn.MouseLeave:Connect(function()
    TweenService:Create(UnloadBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 28, 34)}):Play()
end)

-- ============================================
-- OPEN / CLOSE TOGGLE LOGIC
-- ============================================
local isOpen = false
OpenBtn.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    Main.Visible = isOpen
    TweenService:Create(OpenBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = isOpen and C.panel or C.bg
    }):Play()
end)

OpenBtn.MouseEnter:Connect(function()
    TweenService:Create(OpenBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
end)
OpenBtn.MouseLeave:Connect(function()
    TweenService:Create(OpenBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.03}):Play()
end)
