# ZenNoLagFps
-- ===================================================================
-- ZENOPTIMA PRO V3 - ONE-CLICK ALL BOOST & PURGE
-- ===================================================================

local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Mencegah duplikasi GUI
if CoreGui:FindFirstChild("ZenOptimaOneClickGUI") then
    CoreGui.ZenOptimaOneClickGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZenOptimaOneClickGUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Bingkai Utama (Kecil, Rapi, & Pas di Layar HP)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 115)
MainFrame.Position = UDim2.new(1, -240, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Header Panel
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 36)
Header.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "⚡ ZEN OPTIMA • ALL BOOST"
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

-- Tombol Minimize
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 26, 0, 26)
MinimizeBtn.Position = UDim2.new(1, -30, 0, 5)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(160, 160, 170)
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MinimizeBtn.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

-- Tombol Aktivasi Tunggal (One-Click)
local BoostBtn = Instance.new("TextButton")
BoostBtn.Name = "BoostBtn"
BoostBtn.Size = UDim2.new(1, -20, 0, 55)
BoostBtn.Position = UDim2.new(0, 10, 0, 48)
BoostBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
BoostBtn.BorderSizePixel = 0
BoostBtn.Text = "🚀 AKTIFKAN NO LAG PAKET"
BoostBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
BoostBtn.TextSize = 12
BoostBtn.Font = Enum.Font.GothamBold
BoostBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = BoostBtn

-- Efek Suara Tombol
local function playSound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://6895079853"
    sound.Volume = 0.5
    sound.Parent = CoreGui
    sound:Play()
    task.delay(1, function() sound:Destroy() end)
end

-- STATUS GLOBAL PAKET
local isAllBoostActive = false

-- FUNGSI PAKET GABUNGAN SELURUH OPTIMASI
local function applyAllOptimizations(state)
    if state then
        -- 1. Extreme FPS & Lighting Settings
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 2
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)

        -- 2. Unlock Max FPS
        if setfpscap then setfpscap(999) end

        -- 3. Hapus Efek Pencahayaan & Kamera
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") then
                effect.Enabled = false
            end
        end

        -- 4. Sapu Bersih Seluruh Objek, Dekorasi, Decal, & Efek di Workspace
        for _, v in ipairs(Workspace:GetDescendants()) do
            -- Partikel & Efek Visual
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Explosion") or v:IsA("Highlight") then
                v.Enabled = false
            -- Material dasar & Bayangan
            elseif v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.CastShadow = false
                v.Reflectance = 0
                -- Hapus objek kecil & debris tak berfaedah
                if not v.Anchored and not v.Parent:FindFirstChild("Humanoid") and v.Size.Magnitude < 3 then
                    v:Destroy()
                end
            -- Hapus Tekstur / Stiker
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            -- Ultra Purge Dekorasi Map Besar (Pohon, Batu, Semak, Properti Dekoratif)
            elseif v:IsA("Model") then
                local name = v.Name:lower()
                if name:find("tree") or name:find("rock") or name:find("bush") or name:find("prop") or name:find("decoration") or name:find("cloud") or name:find("plant") or name:find("debris") or name:find("trash") or name:find("grass") then
                    v:Destroy()
                end
            end
        end
    else
        -- Kembalikan Pencahayaan Standar
        Lighting.GlobalShadows = true
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end)
        if setfpscap then setfpscap(60) end
    end
end

-- LOGIKA KLIK TOMBOL UTAMA
BoostBtn.MouseButton1Click:Connect(function()
    playSound()
    isAllBoostActive = not isAllBoostActive
    if isAllBoostActive then
        BoostBtn.Text = "✅ NO LAG PAKET: AKTIF"
        BoostBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 80)
        BoostBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        applyAllOptimizations(true)
    else
        BoostBtn.Text = "🚀 AKTIFKAN NO LAG PAKET"
        BoostBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
        BoostBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
        applyAllOptimizations(false)
    end
end)

-- SISTEM OTOMASI RESPAWN (Tetap Aktif Saat Karakter Mati)
if LocalPlayer then
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if isAllBoostActive then
            applyAllOptimizations(true)
        end
    end)
end

-- LOGIKA MINIMIZE PANEL
local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    playSound()
    minimized = not minimized
    if minimized then
        BoostBtn.Visible = false
        MainFrame.Size = UDim2.new(0, 220, 0, 36)
        MinimizeBtn.Text = "+"
    else
        BoostBtn.Visible = true
        MainFrame.Size = UDim2.new(0, 220, 0, 115)
        MinimizeBtn.Text = "-"
    end
end)

print("ZenOptima One-Click All Boost Berhasil Dimuat!")
