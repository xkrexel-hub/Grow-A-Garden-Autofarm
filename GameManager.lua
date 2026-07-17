--[[
GameManager.lua (Script)
Tempatkan di: game.ServerScriptService

Mengontrol pembuatan data pemain (Sheckles, Benih, dan Buah),
serta merespon RemoteEvents pembelian/penjualan secara aman.


]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Import Modul Database Tanaman
local CropData = require(ReplicatedStorage:WaitForChild("CropData"))

-- Inisialisasi Folder Remote Events
local RemoteFolder = ReplicatedStorage:FindFirstChild("GardenRemotes") or Instance.new("Folder", ReplicatedStorage)
RemoteFolder.Name = "GardenRemotes"

local BuySeedEvent = RemoteFolder:FindFirstChild("BuySeed") or Instance.new("RemoteEvent", RemoteFolder)
BuySeedEvent.Name = "BuySeed"

local BuyRarityPackEvent = RemoteFolder:FindFirstChild("BuyRarityPack") or Instance.new("RemoteEvent", RemoteFolder)
BuyRarityPackEvent.Name = "BuyRarityPack"

local SellFruitsEvent = RemoteFolder:FindFirstChild("SellFruits") or Instance.new("RemoteEvent", RemoteFolder)
SellFruitsEvent.Name = "SellFruits"

-- Membuat Data Pemain saat Masuk Server
Players.PlayerAdded:Connect(function(player)
-- Pembuatan Leaderstats Standar (Uang / Sheckles)
local leaderstats = Instance.new("Folder")
leaderstats.Name = "leaderstats"
leaderstats.Parent = player

local sheckles = Instance.new("IntValue")
sheckles.Name = "Sheckles"
sheckles.Value = 500 -- Modal awal untuk beli bibit awal
sheckles.Parent = leaderstats

-- Folder Penyimpanan Benih (Seeds Inventory)
local seedsFolder = Instance.new("Folder")
seedsFolder.Name = "Seeds"
seedsFolder.Parent = player

-- Folder Penyimpanan Buah Hasil Panen (Fruits Inventory)
local fruitsFolder = Instance.new("Folder")
fruitsFolder.Name = "Fruits"
fruitsFolder.Parent = player

-- Inisialisasi awal seluruh isi tanaman dengan jumlah 0
for cropName, _ in pairs(CropData.Crops) do
	local seedValue = Instance.new("IntValue")
	seedValue.Name = cropName
	seedValue.Value = 0
	seedValue.Parent = seedsFolder

	local fruitValue = Instance.new("IntValue")
	fruitValue.Name = cropName
	fruitValue.Value = 0
	fruitValue.Parent = fruitsFolder
end

-- Beri bonus bibit Carrot awal gratis
seedsFolder.Carrot.Value = 5


end)

-- LOGIKA: Membeli Benih Spesifik
BuySeedEvent.OnServerEvent:Connect(function(player, seedName)
local crop = CropData.Crops[seedName]
if not crop then return end

local sheckles = player.leaderstats.Sheckles
local seedInventory = player.Seeds:FindFirstChild(seedName)

if seedInventory and sheckles.Value >= crop.Cost then
	sheckles.Value = sheckles.Value - crop.Cost
	seedInventory.Value = seedInventory.Value + 1
	print(("[Shop] %s membeli 1x %s Seed seharga %d Sheckles."):format(player.Name, seedName, crop.Cost))
else
	warn(("[Shop] %s gagal membeli %s Seed (Uang tidak cukup atau data error)."):format(player.Name, seedName))
end


end)

-- LOGIKA: Membeli Gacha Pack Berdasarkan Rarity
BuyRarityPackEvent.OnServerEvent:Connect(function(player, rarityName)
local rarityData = CropData.Rarities[rarityName]
if not rarityData then return end

local sheckles = player.leaderstats.Sheckles
local cost = rarityData.GachaCost

if sheckles.Value >= cost then
	-- Dapatkan list benih yang sesuai dengan rarity
	local possibleCrops = CropData.GetCropsByRarity(rarityName)
	if #possibleCrops == 0 then return end

	-- Roll acak benih
	local randomChoice = possibleCrops[math.random(1, #possibleCrops)]
	local seedInventory = player.Seeds:FindFirstChild(randomChoice.Name)

	if seedInventory then
		sheckles.Value = sheckles.Value - cost
		seedInventory.Value = seedInventory.Value + 1
		print(("[Gacha] %s membuka %s Pack seharga %d dan mendapatkan %s Seed!"):format(player.Name, rarityName, cost, randomChoice.Name))
	end
else
	warn(("[Gacha] %s gagal membeli %s Pack (Uang tidak cukup)."):format(player.Name, rarityName))
end


end)

-- LOGIKA: Menjual Seluruh Hasil Panen (Fruits Inventory)
SellFruitsEvent.OnServerEvent:Connect(function(player)
local sheckles = player.leaderstats.Sheckles
local fruitsFolder = player:FindFirstChild("Fruits")
if not fruitsFolder then return end

local totalEarnings = 0
local soldCount = 0

for _, fruitObj in ipairs(fruitsFolder:GetChildren()) do
	if fruitObj:IsA("IntValue") and fruitObj.Value > 0 then
		local cropInfo = CropData.Crops[fruitObj.Name]
		if cropInfo then
			local earnings = fruitObj.Value * cropInfo.SellPrice
			totalEarnings = totalEarnings + earnings
			soldCount = soldCount + fruitObj.Value
			fruitObj.Value = 0 -- Reset buah setelah terjual
		end
	end
end

if totalEarnings > 0 then
	sheckles.Value = sheckles.Value + totalEarnings
	print(("[Merchant] Berhasil menjual %d buah dengan total pendapatan %d Sheckles."):format(soldCount, totalEarnings))
else
	print("[Merchant] Kamu tidak memiliki buah untuk dijual.")
end


end)
