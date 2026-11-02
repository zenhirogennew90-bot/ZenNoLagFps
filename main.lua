
-- [[ Ashish Hub 👑: Ultimate Performance & Graphic Shaders Engine ]] --

local Rayfield = loadstring(game:HttpGet(
    "https://sirius.menu/rayfield"
))()

local Lighting = game:GetService("Lighting")

-- ====================================================
--                    MAIN WINDOW
-- ====================================================

local Window = Rayfield:CreateWindow({
    Name = "Ashish Hub 👑 | Performance & Graphics",
    LoadingTitle = "Booting Ashish Hub 👑...",
    LoadingSubtitle = "By AshishFromRoblox on YT",

    ConfigurationSaving = {
        Enabled = false
    },

    Discord = {
        Enabled = false
    }
})

-- ====================================================
--                      TABS
-- ====================================================

local LagTab = Window:CreateTab("Lag Optimizer", 4483362458)
local ShaderTab = Window:CreateTab("Beautiful Shaders", 4483362458)

-- ====================================================
--                    VARIABLES
-- ====================================================

local UltraLoop = nil
local HubDestroyed = false

-- ====================================================
--                  NOTIFICATION
-- ====================================================

local function Notify(title, content, duration)
    pcall(function()
        Rayfield:Notify({
            Title = title,
            Content = content,
            Duration = duration or 3
        })
    end)
end

-- ====================================================
--                 CLEAR ALL SHADERS
-- ====================================================

local function ClearAllShaders()

    if UltraLoop then
        UltraLoop:Disconnect()
        UltraLoop = nil
    end

    for _, shader in pairs(Lighting:GetChildren()) do

        if shader:IsA("PostEffect")
            or shader:IsA("Atmosphere") then

            shader:Destroy()
        end

    end
end

-- ====================================================
--             SECTION 1: ANTI-LAG PROFILES
-- ====================================================

-- NORMAL ANTI LAG

local function NormalAntiLag()

    ClearAllShaders()

    Lighting.GlobalShadows = false

    settings().Rendering.QualityLevel =
        Enum.QualityLevel.Level05

    for _, obj in pairs(game:GetDescendants()) do

        if obj:IsA("ParticleEmitter")
            or obj:IsA("Sparkles") then

            obj.Enabled = false
        end

    end
end

-- MEDIUM ANTI LAG

local function MediumAntiLag()

    ClearAllShaders()

    settings().Rendering.QualityLevel =
        Enum.QualityLevel.Level03

    Lighting.GlobalShadows = false

    local Terrain = workspace:FindFirstChildOfClass("Terrain")

    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
    end

    for _, obj in pairs(game:GetDescendants()) do

        if obj:IsA("ParticleEmitter")
            or obj:IsA("Trail")
            or obj:IsA("Smoke")
            or obj:IsA("Sparkles") then

            obj.Enabled = false
        end

    end
end

-- SUPER ANTI LAG

local function SuperAntiLag()

    ClearAllShaders()

    settings().Rendering.QualityLevel =
        Enum.QualityLevel.Level01

    Lighting.GlobalShadows = false

    local Terrain = workspace:FindFirstChildOfClass("Terrain")

    if Terrain then

        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterDetailSize = 0

    end

    for _, obj in pairs(game:GetDescendants()) do

        if obj:IsA("BasePart") or obj:IsA("MeshPart") then

            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
            obj.CastShadow = false

        elseif obj:IsA("Texture") or obj:IsA("Decal") then

            obj:Destroy()

        elseif obj:IsA("ParticleEmitter")
            or obj:IsA("Trail")
            or obj:IsA("Smoke")
            or obj:IsA("Sparkles")
            or obj:IsA("Fire") then

            obj.Enabled = false
        end

    end
end

-- ULTRA ANTI LAG

local function UltraAntiLag()

    SuperAntiLag()

    pcall(function()
        Lighting.Technology = Enum.Technology.Compatibility
    end)

    local function AbsolutePotato(obj)

        if obj:IsA("BasePart") or obj:IsA("MeshPart") then

            obj.Material = Enum.Material.SmoothPlastic
            obj.CastShadow = false

        elseif obj:IsA("Texture")
            or obj:IsA("Decal")
            or obj:IsA("Clothing") then

            obj:Destroy()

        elseif obj:IsA("ParticleEmitter")
            or obj:IsA("Trail")
            or obj:IsA("Smoke")
            or obj:IsA("Sparkles")
            or obj:IsA("Fire") then

            obj.Enabled = false
        end

    end

    UltraLoop = game.DescendantAdded:Connect(function(newObj)

        pcall(function()
            AbsolutePotato(newObj)
        end)

    end)
end

-- ====================================================
--             SECTION 2: REALISTIC SHADERS
-- ====================================================

-- REALISTIC SHADER

local function ApplyRealistic()

    ClearAllShaders()

    pcall(function()
        Lighting.Technology = Enum.Technology.Future
    end)

    Lighting.GlobalShadows = true
    Lighting.Brightness = 2
    Lighting.Ambient = Color3.fromRGB(40, 40, 50)

    local Bloom = Instance.new("BloomEffect", Lighting)

    Bloom.Intensity = 0.4
    Bloom.Size = 12
    Bloom.Threshold = 0.9

    local ColorCorr = Instance.new("ColorCorrectionEffect", Lighting)

    ColorCorr.Contrast = 0.1
    ColorCorr.Saturation = 0.15
end

-- SUPER REALISTIC SHADER

local function ApplySuperRealistic()

    ClearAllShaders()

    pcall(function()
        Lighting.Technology = Enum.Technology.Future
    end)

    Lighting.GlobalShadows = true
    Lighting.Brightness = 2.5

    local Bloom = Instance.new("BloomEffect", Lighting)

    Bloom.Intensity = 0.6
    Bloom.Size = 24
    Bloom.Threshold = 0.85

    local SunRays = Instance.new("SunRaysEffect", Lighting)

    SunRays.Intensity = 0.25
    SunRays.Spread = 0.6

    local ColorCorr = Instance.new("ColorCorrectionEffect", Lighting)

    ColorCorr.Contrast = 0.2
    ColorCorr.Saturation = 0.3
    ColorCorr.TintColor = Color3.fromRGB(255, 245, 230)
end

-- ULTRA REALISTIC SHADER

local function ApplyUltraRealistic()

    ClearAllShaders()

    pcall(function()
        Lighting.Technology = Enum.Technology.Future
    end)

    Lighting.GlobalShadows = true
    Lighting.Brightness = 3

    local Bloom = Instance.new("BloomEffect", Lighting)

    Bloom.Intensity = 0.8
    Bloom.Size = 30
    Bloom.Threshold = 0.8

    local SunRays = Instance.new("SunRaysEffect", Lighting)

    SunRays.Intensity = 0.4
    SunRays.Spread = 0.75

    local ColorCorr = Instance.new("ColorCorrectionEffect", Lighting)

    ColorCorr.Contrast = 0.25
    ColorCorr.Saturation = 0.4

    local Atmos = Instance.new("Atmosphere", Lighting)

    Atmos.Density = 0.2
    Atmos.Glare = 0.4
    Atmos.Haze = 1.5

    Atmos.Color = Color3.fromRGB(180, 200, 220)
    Atmos.Decay = Color3.fromRGB(120, 140, 160)

    local DOF = Instance.new("DepthOfFieldEffect", Lighting)

    DOF.FarIntensity = 0.2
    DOF.FocusDistance = 20
    DOF.InFocusRadius = 40
    DOF.NearIntensity = 0.05
end

-- ====================================================
--                  SECTION 3: BUTTONS
-- ====================================================

-- NORMAL ANTI LAG

LagTab:CreateButton({
    Name = "🟢 Normal Anti-Lag",

    Callback = function()

        NormalAntiLag()

        Notify(
            "Ashish Hub 👑",
            "Basic performance tweaks applied.",
            3
        )

    end
})

-- MEDIUM ANTI LAG

LagTab:CreateButton({
    Name = "🟡 Medium Anti-Lag",

    Callback = function()

        MediumAntiLag()

        Notify(
            "Ashish Hub 👑",
            "Standard shaders disabled.",
            3
        )

    end
})

-- SUPER ANTI LAG

LagTab:CreateButton({
    Name = "🟠 Super Anti-Lag",

    Callback = function()

        SuperAntiLag()

        Notify(
            "Ashish Hub 👑",
            "Textures replaced with smooth plastic.",
            3
        )

    end
})

-- ULTRA ANTI LAG

LagTab:CreateButton({
    Name = "🔴 Ultra Anti-Lag (Potato Mode)",

    Callback = function()

        UltraAntiLag()

        Notify(
            "Ashish Hub 👑",
            "Engine forced to minimum + live object wiper active!",
            4
        )

    end
})

-- REALISTIC SHADER

ShaderTab:CreateButton({
    Name = "✨ Realistic Shader",

    Callback = function()

        ApplyRealistic()

        Notify(
            "Ashish Hub 👑",
            "Ambient colors and light contrast boosted.",
            3
        )

    end
})

-- SUPER REALISTIC SHADER

ShaderTab:CreateButton({
    Name = "🔥 Super Realistic Shader",

    Callback = function()

        ApplySuperRealistic()

        Notify(
            "Ashish Hub 👑",
            "Cinematic Sunrays and warm profile loaded!",
            3
        )

    end
})

-- ULTRA REALISTIC SHADER

ShaderTab:CreateButton({
    Name = "👑 Ultra Realistic Shader (Next-Gen)",

    Callback = function()

        ApplyUltraRealistic()

        Notify(
            "Ashish Hub 👑",
            "Next-gen Depth of Field and atmosphere activated!",
            4
        )

    end
})

-- ====================================================
--               SECTION 4: REMOVE HUB
-- ====================================================

local function RemoveHub()

    if HubDestroyed then
        return
    end

    HubDestroyed = true

    -- Stop Ultra Anti-Lag loop

    if UltraLoop then
        UltraLoop:Disconnect()
        UltraLoop = nil
    end

    -- Destroy Rayfield

    pcall(function()
        Rayfield:Destroy()
    end)

end

LagTab:CreateButton({
    Name = "❌ Close / Remove Hub",

    Callback = function()
        RemoveHub()
    end
})

-- [[ END ASHISH HUB 👑 ]]
