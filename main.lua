local GameFunctions = {}

-- Layanan utama Roblox
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Fungsi untuk mengumpulkan buah
function GameFunctions.CollectFruit()
    -- Contoh pencarian objek buah di Workspace
    local FruitsFolder = workspace:FindFirstChild("Fruits")
    if not FruitsFolder then return end

    for _, fruit in ipairs(FruitsFolder:GetChildren()) do
        if fruit:IsA("BasePart") and Character:FindFirstChild("HumanoidRootPart") then
            -- Pendekatan 1: Berjalan ke buah (Aman dari deteksi)
            Character.HumanoidRootPart.CFrame = fruit.CFrame
            task.wait(0.1) -- Delay kecil agar sinkron dengan server
            
            -- Pendekatan 2: Pemicuan Remote (Jika game menggunakan RemoteEvent)
            -- game:GetService("ReplicatedStorage").Remotes.Collect:FireServer(fruit)
        end
    end
end

-- Fungsi untuk menjual buah
function GameFunctions.SellFruit()
    local SellZone = workspace:FindFirstChild("SellZone")
    if SellZone and Character:FindFirstChild("HumanoidRootPart") then
        Character.HumanoidRootPart.CFrame = SellZone.CFrame
        -- game:GetService("ReplicatedStorage").Remotes.Sell:FireServer()
    end
end

-- Fungsi untuk membeli benih
function GameFunctions.BuySeed(seedName, amount)
    -- Biasanya menggunakan RemoteEvent ke toko
    local ShopRemote = game:GetService("ReplicatedStorage"):FindFirstChild("BuyItem", true)
    if ShopRemote then
        for i = 1, amount do
            ShopRemote:FireServer(seedName)
            task.wait(0.05)
        end
    end
end

return GameFunctions

local TaskScheduler = {
    Running = false,
    CurrentState = "Idle" -- Idle, Collecting, Selling, Buying
}

local GameFunctions = require(path.to.GameFunctions) -- Sesuaikan path jika digabung

function TaskScheduler.Start(config)
    TaskScheduler.Running = true
    
    task.spawn(function()
        while TaskScheduler.Running do
            -- 1. Cek Inventaris (Contoh logika jika tas penuh)
            local inventory = LocalPlayer:FindFirstChild("Leaderstats") and LocalPlayer.Leaderstats:FindFirstChild("Fruits")
            local maxInventory = 50 -- Batas contoh
            
            if inventory and inventory.Value >= maxInventory then
                TaskScheduler.CurrentState = "Selling"
                GameFunctions.SellFruit()
                task.wait(1)
            else
                -- 2. Jalankan Otomasi Koleksi jika diaktifkan di Config
                if config.AutoCollect then
                    TaskScheduler.CurrentState = "Collecting"
                    GameFunctions.CollectFruit()
                end
            end
            
            -- 3. Otomasi Beli Benih jika habis
            if config.AutoBuySeeds then
                local seeds = LocalPlayer:FindFirstChild("Leaderstats") and LocalPlayer.Leaderstats:FindFirstChild("Seeds")
                if seeds and seeds.Value == 0 then
                    TaskScheduler.CurrentState = "Buying"
                    GameFunctions.BuySeed("TomatoSeed", 10)
                end
            end
            
            task.wait(0.5) -- Mencegah crash/high CPU usage
        end
    end)
end

function TaskScheduler.Stop()
    TaskScheduler.Running = false
    TaskScheduler.CurrentState = "Idle"
end

return TaskScheduler

local Interface = {}

function Interface.CreateMenu(config, startCallback, stopCallback)
    -- Pembuatan ScreenGui Utama
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AutomationFrameworkUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui") -- Menghindari kebersihan reset karakter

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 250, 0, 300)
    MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true -- Membuat UI bisa digeser
    MainFrame.Parent = ScreenGui

    -- UI Corner (Memperhalus sudut)
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    -- Judul Menu
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = "Grow a Garden Automation"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 16
    Title.Parent = MainFrame

    -- Tombol Toggle Start/Stop
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 200, 0, 40)
    ToggleButton.Position = UDim2.new(0, 25, 0, 60)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
    ToggleButton.Text = "START BOT"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Font = Enum.Font.SourceSansBold
    ToggleButton.TextSize = 14
    ToggleButton.Parent = MainFrame

    local isBotRunning = false
    ToggleButton.MouseButton1Click:Connect(function()
        isBotRunning = not isBotRunning
        if isBotRunning then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            ToggleButton.Text = "STOP BOT"
            startCallback()
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
            ToggleButton.Text = "START BOT"
            stopCallback()
        end
    end)
    
    return ScreenGui
end

return Interface

local Config = {
    AutoCollect = true,
    AutoBuySeeds = true,
    AutoSell = true
}

-- Integrasi modul
local UI = require(path.to.Interface)
local Scheduler = require(path.to.TaskScheduler)

UI.CreateMenu(Config, 
    function()
        -- Callback ketika tombol START ditekan
        Scheduler.Start(Config)
        print("[Framework] Automation Started.")
    end, 
    function()
        -- Callback ketika tombol STOP ditekan
        Scheduler.Stop()
        print("[Framework] Automation Stopped.")
    end
)
