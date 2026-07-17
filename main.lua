-- =============================================================================
-- AUTOMATION FRAMEWORK: GROW A GARDEN 2
-- FEATURES: Auto Collect (Smart Harvest), Auto Sell, Smart Auto Buy Seeds
-- =============================================================================

-- -----------------------------------------------------------------------------
-- [1] DATA CROP WIKI INTEGRATION
-- -----------------------------------------------------------------------------
local CropData = {
    -- COMMON TIER
    ["Carrot"] = { Price = 5, MultiHarvest = false, SeedName = "CarrotSeed" },
    ["Blueberry"] = { Price = 5, MultiHarvest = true, SeedName = "BlueberrySeed" },
    ["Strawberry"] = { Price = 3, MultiHarvest = true, SeedName = "StrawberrySeed" },

    -- UNCOMMON TIER
    ["Apple"] = { Price = 12, MultiHarvest = true, SeedName = "AppleSeed" },
    ["Tomato"] = { Price = 9, MultiHarvest = true, SeedName = "TomatoSeed" },
    ["Tulip"] = { Price = 60, MultiHarvest = false, SeedName = "TulipSeed" },

    -- RARE TIER
    ["Baby Cactus"] = { Price = 70, MultiHarvest = true, SeedName = "BabyCactusSeed" },
    ["Cactus"] = { Price = 40, MultiHarvest = true, SeedName = "CactusSeed" },
    ["Corn"] = { Price = 34, MultiHarvest = true, SeedName = "CornSeed" },
    ["Horned Melon"] = { Price = 200, MultiHarvest = true, SeedName = "HornedMelonSeed" },
    ["Pineapple"] = { Price = 30, MultiHarvest = true, SeedName = "PineappleSeed" },
    ["Bamboo"] = { Price = 800, MultiHarvest = false, SeedName = "BambooSeed" },

    -- EPIC TIER
    ["Banana"] = { Price = 35, MultiHarvest = true, SeedName = "BananaSeed" },
    ["Coconut"] = { Price = 60, MultiHarvest = true, SeedName = "CoconutSeed" },
    ["Glow Mushroom"] = { Price = 700, MultiHarvest = true, SeedName = "GlowMushroomSeed" },
    ["Grape"] = { Price = 45, MultiHarvest = true, SeedName = "GrapeSeed" },
    ["Green Bean"] = { Price = 10, MultiHarvest = true, SeedName = "GreenBeanSeed" },
    ["Mango"] = { Price = 90, MultiHarvest = true, SeedName = "MangoSeed" },
    ["Mushroom"] = { Price = 13000, MultiHarvest = false, SeedName = "MushroomSeed" },

    -- LEGENDARY TIER
    ["Acorn"] = { Price = 200, MultiHarvest = true, SeedName = "AcornSeed" },
    ["Cherry"] = { Price = 350, MultiHarvest = true, SeedName = "CherrySeed" },
    ["Dragon Fruit"] = { Price = 150, MultiHarvest = true, SeedName = "DragonFruitSeed" },
    ["Fire Fern"] = { Price = 900, MultiHarvest = true, SeedName = "FireFernSeed" },
    ["Poison Ivy"] = { Price = 1700, MultiHarvest = true, SeedName = "PoisonIvySeed" },
    ["Sunflower"] = { Price = 1750, MultiHarvest = true, SeedName = "SunflowerSeed" },

    -- MYTHIC & SECRET TIER
    ["Ghost Pepper"] = { Price = 2500, MultiHarvest = true, SeedName = "GhostPepperSeed" },
    ["Venus Fly Trap"] = { Price = 3000, MultiHarvest = true, SeedName = "VenusFlyTrapSeed" },
    ["Eclipse Bloom"] = { Price = 12000, MultiHarvest = true, SeedName = "EclipseBloomSeed" }
}

-- -----------------------------------------------------------------------------
-- [2] CONFIGURATION SYSTEM
-- -----------------------------------------------------------------------------
local Config = {
    AutoCollect = true,
    AutoSell = true,
    AutoBuySeeds = true,
    TargetSeed = "TomatoSeed", -- Default benih awal yang akan dibeli bot
    MaxInventory = 50          -- Batas tampung tas sebelum otomatis menjual
}

-- -----------------------------------------------------------------------------
-- [3] CORE ENGINE: GAME FUNCTIONS
-- -----------------------------------------------------------------------------
local GameFunctions = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function GameFunctions.GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

function GameFunctions.CollectFruit()
    local FruitsFolder = workspace:FindFirstChild("Fruits")
    if not FruitsFolder then return end

    local character = GameFunctions.GetCharacter()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, fruit in ipairs(FruitsFolder:GetChildren()) do
        if fruit:IsA("BasePart") then
            -- Deteksi nama tanaman untuk mencocokkan data jenis panen
            local cropName = fruit.Name:gsub("Produce", ""):gsub("Crop", "")
            
            -- Teleportasi/Melangkah ke buah untuk mengoleksi
            hrp.CFrame = fruit.CFrame
            task.wait(0.1) -- Jeda halus sinkronisasi server

            -- Logika Cerdas: Jika tanaman berjenis Single-Harvest, langsung beli benih baru saat dipanen
            local cropInfo = CropData[cropName]
            if cropInfo and not cropInfo.MultiHarvest and Config.AutoBuySeeds then
                GameFunctions.BuySeed(cropInfo.SeedName, 1)
            end
            
            -- Jika menggunakan Remote Event (opsional, sesuaikan dengan struktur game asli)
            -- game:GetService("ReplicatedStorage").Remotes.Collect:FireServer(fruit)
        end
    end
end

function GameFunctions.SellFruit()
    local SellZone = workspace:FindFirstChild("SellZone")
    local character = GameFunctions.GetCharacter()
    local hrp = character:FindFirstChild("HumanoidRootPart")

    if SellZone and hrp then
        hrp.CFrame = SellZone.CFrame
        task.wait(0.5)
        -- game:GetService("ReplicatedStorage").Remotes.Sell:FireServer()
    end
end

function GameFunctions.BuySeed(seedName, amount)
    local ShopRemote = game:GetService("ReplicatedStorage"):FindFirstChild("BuyItem", true)
    if ShopRemote then
        for i = 1, amount do
            ShopRemote:FireServer(seedName)
            task.wait(0.05)
        end
    end
end

-- -----------------------------------------------------------------------------
-- [4] CORE ENGINE: TASK SCHEDULER (STATE MACHINE)
-- -----------------------------------------------------------------------------
local TaskScheduler = {
    Running = false,
    CurrentState = "Idle"
}

function TaskScheduler.Start()
    if TaskScheduler.Running then return end
    TaskScheduler.Running = true
    
    task.spawn(function()
        while TaskScheduler.Running do
            local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
            local fruitsTrack = leaderstats and (leaderstats:FindFirstChild("Fruits") or leaderstats:FindFirstChild("Produce"))
            local seedsTrack = leaderstats and leaderstats:FindFirstChild("Seeds")

            -- 1. Logika Auto Sell (Jika tas penuh)
            if Config.AutoSell and fruitsTrack and fruitsTrack.Value >= Config.MaxInventory then
                TaskScheduler.CurrentState = "Selling"
                GameFunctions.SellFruit()
                task.wait(1)
            
            -- 2. Logika Auto Buy Seeds (Membeli benih utama jika stok di tas 0)
            elseif Config.AutoBuySeeds and seedsTrack and seedsTrack.Value == 0 then
                TaskScheduler.CurrentState = "Buying Seeds"
                GameFunctions.BuySeed(Config.TargetSeed, 10)
                task.wait(0.5)

            -- 3. Logika Auto Collect / Harvesting
            elseif Config.AutoCollect then
                TaskScheduler.CurrentState = "Harvesting"
                GameFunctions.CollectFruit()
            else
                TaskScheduler.CurrentState = "Idle"
            end
            
            task.wait(0.3) -- Mengamankan penggunaan CPU agar framework berjalan ringan
        end
    end)
end

function TaskScheduler.Stop()
    TaskScheduler.Running = false
    TaskScheduler.CurrentState = "Idle"
end

-- -----------------------------------------------------------------------------
-- [5] MODULAR GUI INTERFACE
-- -----------------------------------------------------------------------------
local Interface = {}

function Interface.BuildMenu()
    -- Cek jika UI sudah terpasang agar tidak duplikat
    local existingUI = game:GetService("CoreGui"):FindFirstChild("GrowAGarden2AutoUI")
    if existingUI then existingUI:Destroy() end

    -- Base Screen GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GrowAGarden2AutoUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")

    -- Main Container Window
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 260, 0, 220)
    MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    -- Header Title
    local Header = Instance.new("TextLabel")
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.Text = "Grow a Garden 2 Framework"
    Header.TextColor3 = Color3.fromRGB(240, 240, 240)
    Header.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    Header.Font = Enum.Font.SourceSansBold
    Header.TextSize = 15
    Header.Parent = MainFrame
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    HeaderCorner.Parent = Header

    -- State Status Label (Menampilkan aktivitas Bot secara Real-Time)
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 0, 25)
    StatusLabel.Position = UDim2.new(0, 0, 0, 35)
    StatusLabel.Text = "Status: Idle"
    StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Font = Enum.Font.SourceSansItalic
    StatusLabel.TextSize = 13
    StatusLabel.Parent = MainFrame

    -- Tombol Pemicu Utama (START / STOP)
    local MainButton = Instance.new("TextButton")
    MainButton.Size = UDim2.new(0, 210, 0, 45)
    MainButton.Position = UDim2.new(0, 25, 0, 75)
    MainButton.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    MainButton.Text = "RUN AUTOMATION"
    MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainButton.Font = Enum.Font.SourceSansBold
    MainButton.TextSize = 14
    MainButton.Parent = MainFrame

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = MainButton

    -- Info Pengaturan Aktif di UI
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, -20, 0, 60)
    InfoLabel.Position = UDim2.new(0, 10, 0, 135)
    InfoLabel.Text = "• Smart Harvesting Active\n• Single-Harvest Auto Buy Enabled\n• Auto Deposit/Sell Stand Active"
    InfoLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Font = Enum.Font.SourceSans
    InfoLabel.TextSize = 13
    InfoLabel.Parent = MainFrame

    -- Logika Interaksi Klik Tombol
    MainButton.MouseButton1Click:Connect(function()
        if not TaskScheduler.Running then
            TaskScheduler.Start()
            MainButton.BackgroundColor3 = Color3.fromRGB(178, 34, 34)
            MainButton.Text = "STOP AUTOMATION"
        else
            TaskScheduler.Stop()
            MainButton.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
            MainButton.Text = "RUN AUTOMATION"
        end
    end)

    -- Loop UI Thread untuk memperbarui status aktivitas bot di layar
    task.spawn(function()
        while ScreenGui.Parent do
            StatusLabel.Text = "Status: " .. TaskScheduler.CurrentState
            task.wait(0.2)
        end
    end)
end

-- -----------------------------------------------------------------------------
-- [6] INITIALIZATION
-- -----------------------------------------------------------------------------
Interface.BuildMenu()
print("[Framework] Grow a Garden 2 Core System Loaded Successfully.")
