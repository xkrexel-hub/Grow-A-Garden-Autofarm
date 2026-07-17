-- =============================================================================
-- AUTOMATION FRAMEWORK: GROW A GARDEN 2 (V2.0 - MODULAR TABS)
-- FEATURES: Auto Collect, Auto Sell, Smart Buy, Minimize/Exit, Plant Config Tab
-- =============================================================================

-- -----------------------------------------------------------------------------
-- [1] DATA CROP WIKI INTEGRATION
-- -----------------------------------------------------------------------------
local CropData = {
    ["Carrot"] = { Price = 5, MultiHarvest = false, SeedName = "CarrotSeed" },
    ["Blueberry"] = { Price = 5, MultiHarvest = true, SeedName = "BlueberrySeed" },
    ["Strawberry"] = { Price = 3, MultiHarvest = true, SeedName = "StrawberrySeed" },
    ["Apple"] = { Price = 12, MultiHarvest = true, SeedName = "AppleSeed" },
    ["Tomato"] = { Price = 9, MultiHarvest = true, SeedName = "TomatoSeed" },
    ["Tulip"] = { Price = 60, MultiHarvest = false, SeedName = "TulipSeed" },
    ["Baby Cactus"] = { Price = 70, MultiHarvest = true, SeedName = "BabyCactusSeed" },
    ["Cactus"] = { Price = 40, MultiHarvest = true, SeedName = "CactusSeed" },
    ["Corn"] = { Price = 34, MultiHarvest = true, SeedName = "CornSeed" },
    ["Horned Melon"] = { Price = 200, MultiHarvest = true, SeedName = "HornedMelonSeed" },
    ["Pineapple"] = { Price = 30, MultiHarvest = true, SeedName = "PineappleSeed" },
    ["Bamboo"] = { Price = 800, MultiHarvest = false, SeedName = "BambooSeed" },
    ["Banana"] = { Price = 35, MultiHarvest = true, SeedName = "BananaSeed" },
    ["Coconut"] = { Price = 60, MultiHarvest = true, SeedName = "CoconutSeed" },
    ["Glow Mushroom"] = { Price = 700, MultiHarvest = true, SeedName = "GlowMushroomSeed" },
    ["Grape"] = { Price = 45, MultiHarvest = true, SeedName = "GrapeSeed" },
    ["Green Bean"] = { Price = 10, MultiHarvest = true, SeedName = "GreenBeanSeed" },
    ["Mango"] = { Price = 90, MultiHarvest = true, SeedName = "MangoSeed" },
    ["Mushroom"] = { Price = 13000, MultiHarvest = false, SeedName = "MushroomSeed" },
    ["Acorn"] = { Price = 200, MultiHarvest = true, SeedName = "AcornSeed" },
    ["Cherry"] = { Price = 350, MultiHarvest = true, SeedName = "CherrySeed" },
    ["Dragon Fruit"] = { Price = 150, MultiHarvest = true, SeedName = "DragonFruitSeed" },
    ["Fire Fern"] = { Price = 900, MultiHarvest = true, SeedName = "FireFernSeed" },
    ["Poison Ivy"] = { Price = 1700, MultiHarvest = true, SeedName = "PoisonIvySeed" },
    ["Sunflower"] = { Price = 1750, MultiHarvest = true, SeedName = "SunflowerSeed" },
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
    TargetSeed = "TomatoSeed", 
    MaxInventory = 50          
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
            local cropName = fruit.Name:gsub("Produce", ""):gsub("Crop", "")
            
            hrp.CFrame = fruit.CFrame
            task.wait(0.1) 

            local cropInfo = CropData[cropName]
            if cropInfo and not cropInfo.MultiHarvest and Config.AutoBuySeeds then
                GameFunctions.BuySeed(cropInfo.SeedName, 1)
            end
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
-- [4] CORE ENGINE: TASK SCHEDULER
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

            if Config.AutoSell and fruitsTrack and fruitsTrack.Value >= Config.MaxInventory then
                TaskScheduler.CurrentState = "Selling"
                GameFunctions.SellFruit()
                task.wait(1)
            elseif Config.AutoBuySeeds and seedsTrack and seedsTrack.Value == 0 then
                TaskScheduler.CurrentState = "Buying Seeds"
                GameFunctions.BuySeed(Config.TargetSeed, 10)
                task.wait(0.5)
            elseif Config.AutoCollect then
                TaskScheduler.CurrentState = "Harvesting"
                GameFunctions.CollectFruit()
            else
                TaskScheduler.CurrentState = "Idle"
            end
            task.wait(0.3)
        end
    end)
end

function TaskScheduler.Stop()
    TaskScheduler.Running = false
    TaskScheduler.CurrentState = "Idle"
end

-- -----------------------------------------------------------------------------
-- [5] MODULAR GUI INTERFACE (WITH WINDOW CONTROLS & TABS)
-- -----------------------------------------------------------------------------
local Interface = {}

function Interface.BuildMenu()
    local existingUI = game:GetService("CoreGui"):FindFirstChild("GrowAGarden2AutoUI")
    if existingUI then existingUI:Destroy() end

    -- Base Screen GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GrowAGarden2AutoUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")

    -- Main Container Window
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 240)
    MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    -- Header Bar
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    HeaderCorner.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.6, 0, 1, 0)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.Text = "Grow a Garden 2 Framework"
    Title.TextColor3 = Color3.fromRGB(240, 240, 240)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    -- Window Controls (Minimize & Exit)
    local ExitButton = Instance.new("TextButton")
    ExitButton.Size = UDim2.new(0, 25, 0, 25)
    ExitButton.Position = UDim2.new(1, -30, 0, 5)
    ExitButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    ExitButton.Text = "X"
    ExitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExitButton.Font = Enum.Font.SourceSansBold
    ExitButton.TextSize = 12
    ExitButton.Parent = Header

    local ExitCorner = Instance.new("UICorner")
    ExitCorner.CornerRadius = UDim.new(0, 4)
    ExitCorner.Parent = ExitButton

    local MiniButton = Instance.new("TextButton")
    MiniButton.Size = UDim2.new(0, 25, 0, 25)
    MiniButton.Position = UDim2.new(1, -60, 0, 5)
    MiniButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    MiniButton.Text = "-"
    MiniButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MiniButton.Font = Enum.Font.SourceSansBold
    MiniButton.TextSize = 14
    MiniButton.Parent = Header

    local MiniCorner = Instance.new("UICorner")
    MiniCorner.CornerRadius = UDim.new(0, 4)
    MiniCorner.Parent = MiniButton

    -- Tab Selection Bar
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, 0, 0, 30)
    TabBar.Position = UDim2.new(0, 0, 0, 35)
    TabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabBar.BorderSizePixel = 0
    TabBar.Parent = MainFrame

    local HomeTabBtn = Instance.new("TextButton")
    HomeTabBtn.Size = UDim2.new(0.5, 0, 1, 0)
    HomeTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    HomeTabBtn.Text = "Main Status"
    HomeTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    HomeTabBtn.Font = Enum.Font.SourceSansBold
    HomeTabBtn.TextSize = 13
    HomeTabBtn.BorderSizePixel = 0
    HomeTabBtn.Parent = TabBar

    local PlantTabBtn = Instance.new("TextButton")
    PlantTabBtn.Size = UDim2.new(0.5, 0, 1, 0)
    PlantTabBtn.Position = UDim2.new(0.5, 0, 0, 0)
    PlantTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    PlantTabBtn.Text = "Plant Settings"
    PlantTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    PlantTabBtn.Font = Enum.Font.SourceSansBold
    PlantTabBtn.TextSize = 13
    PlantTabBtn.BorderSizePixel = 0
    PlantTabBtn.Parent = TabBar

    -- Pages Container
    local HomePanel = Instance.new("Frame")
    HomePanel.Size = UDim2.new(1, 0, 1, -65)
    HomePanel.Position = UDim2.new(0, 0, 0, 65)
    HomePanel.BackgroundTransparency = 1
    HomePanel.Visible = true
    HomePanel.Parent = MainFrame

    local PlantPanel = Instance.new("Frame")
    PlantPanel.Size = UDim2.new(1, 0, 1, -65)
    PlantPanel.Position = UDim2.new(0, 0, 0, 65)
    PlantPanel.BackgroundTransparency = 1
    PlantPanel.Visible = false
    PlantPanel.Parent = MainFrame

    -- [PAGE 1: HOME PANEL CONTENT]
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 0, 30)
    StatusLabel.Position = UDim2.new(0, 0, 0, 15)
    StatusLabel.Text = "Status: Idle"
    StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Font = Enum.Font.SourceSansItalic
    StatusLabel.TextSize = 14
    StatusLabel.Parent = HomePanel

    local MainButton = Instance.new("TextButton")
    MainButton.Size = UDim2.new(0, 240, 0, 45)
    MainButton.Position = UDim2.new(0, 30, 0, 55)
    MainButton.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    MainButton.Text = "RUN AUTOMATION"
    MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainButton.Font = Enum.Font.SourceSansBold
    MainButton.TextSize = 14
    MainButton.Parent = HomePanel

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = MainButton

    -- [PAGE 2: PLANT PANEL CONTENT - COLLECT & SELL]
    local function CreateToggle(parent, text, position, configKey)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, -40, 0, 40)
        ToggleFrame.Position = position
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Parent = parent

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(220, 220, 220)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.SourceSansSemibold
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame

        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0, 60, 0, 28)
        Button.Position = UDim2.new(1, -60, 0, 6)
        Button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 150, 70) or Color3.fromRGB(70, 70, 70)
        Button.Text = Config[configKey] and "ON" or "OFF"
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.Font = Enum.Font.SourceSansBold
        Button.TextSize = 12
        Button.Parent = ToggleFrame

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 4)
        BtnCorner.Parent = Button

        Button.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            Button.Text = Config[configKey] and "ON" or "OFF"
            Button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 150, 70) or Color3.fromRGB(70, 70, 70)
        end)
    end

    CreateToggle(PlantPanel, "Auto Collect Fruits", UDim2.new(0, 20, 0, 15), "AutoCollect")
    CreateToggle(PlantPanel, "Auto Sell / Deposit Tas", UDim2.new(0, 20, 0, 60), "AutoSell")

    -- Window Controls Logic
    local minimized = false
    MiniButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            MainFrame:TweenSize(UDim2.new(0, 300, 0, 35), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
            MiniButton.Text = "+"
        else
            MainFrame:TweenSize(UDim2.new(0, 300, 0, 240), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
            MiniButton.Text = "-"
        end
    end)

    ExitButton.MouseButton1Click:Connect(function()
        TaskScheduler.Stop()
        ScreenGui:Destroy()
        print("[Framework] Script terminated safely.")
    end)

    -- Tab Switching Logic
    HomeTabBtn.MouseButton1Click:Connect(function()
        HomePanel.Visible = true
        PlantPanel.Visible = false
        HomeTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        HomeTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        PlantTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        PlantTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    end)

    PlantTabBtn.MouseButton1Click:Connect(function()
        HomePanel.Visible = false
        PlantPanel.Visible = true
        PlantTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        PlantTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        HomeTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        HomeTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    end)

    -- Main Bot Start Trigger
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

    -- Thread Loop for Live System Status Update
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
print("[Framework V2.0] Modular Interface and Core Loaded Successfully.")
