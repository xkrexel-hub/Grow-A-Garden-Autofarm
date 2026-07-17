--[[
CropData.lua (ModuleScript)
Tempatkan di: game.ReplicatedStorage

Database ini berisi data resmi tanaman dari Grow a Garden 2
lengkap dengan harga beli, harga jual, dan rarity-nya.


]]

local CropData = {}

-- Daftar Rarity beserta warna UI dan harga beli Paket Acak (Gacha Pack)
CropData.Rarities = {
Common = { Color = Color3.fromRGB(180, 180, 180), GachaCost = 15 },
Uncommon = { Color = Color3.fromRGB(85, 255, 127), GachaCost = 250 },
Rare = { Color = Color3.fromRGB(85, 170, 255), GachaCost = 1500 },
Epic = { Color = Color3.fromRGB(170, 85, 255), GachaCost = 25000 },
Legendary = { Color = Color3.fromRGB(255, 170, 0), GachaCost = 500000 },
Mythic = { Color = Color3.fromRGB(255, 85, 255), GachaCost = 8000000 },
Super = { Color = Color3.fromRGB(255, 85, 85), GachaCost = 45000000 }
}

-- Daftar Lengkap Tanaman (Crops)
CropData.Crops = {
-- COMMON
Carrot = { Cost = 1, SellPrice = 5, Rarity = "Common" },
Strawberry = { Cost = 10, SellPrice = 3, Rarity = "Common" },
Blueberry = { Cost = 25, SellPrice = 5, Rarity = "Common" },

-- UNCOMMON
Tulip = { Cost = 40, SellPrice = 60, Rarity = "Uncommon" },
Tomato = { Cost = 200, SellPrice = 9, Rarity = "Uncommon" },
Apple = { Cost = 400, SellPrice = 12, Rarity = "Uncommon" },

-- RARE
Bamboo = { Cost = 700, SellPrice = 800, Rarity = "Rare" },
Corn = { Cost = 2500, SellPrice = 34, Rarity = "Rare" },
Cactus = { Cost = 5000, SellPrice = 40, Rarity = "Rare" },
Pineapple = { Cost = 10000, SellPrice = 30, Rarity = "Rare" },

-- EPIC
Mushroom = { Cost = 15000, SellPrice = 13000, Rarity = "Epic" },
GreenBean = { Cost = 20000, SellPrice = 10, Rarity = "Epic" },
Banana = { Cost = 30000, SellPrice = 35, Rarity = "Epic" },
Grape = { Cost = 50000, SellPrice = 45, Rarity = "Epic" },
Coconut = { Cost = 70000, SellPrice = 60, Rarity = "Epic" },
Mango = { Cost = 300000, SellPrice = 90, Rarity = "Epic" },

-- LEGENDARY
DragonFruit = { Cost = 120000, SellPrice = 150, Rarity = "Legendary" },
Acorn = { Cost = 700000, SellPrice = 200, Rarity = "Legendary" },
Cherry = { Cost = 1200000, SellPrice = 350, Rarity = "Legendary" },
Sunflower = { Cost = 5000000, SellPrice = 1750, Rarity = "Legendary" },

-- MYTHIC
VenusFlyTrap = { Cost = 7000000, SellPrice = 3000, Rarity = "Mythic" },
Pomegranate = { Cost = 12000000, SellPrice = 900, Rarity = "Mythic" },
PoisonApple = { Cost = 25000000, SellPrice = 900, Rarity = "Mythic" },
VenomSpitter = { Cost = 30000000, SellPrice = 4000, Rarity = "Mythic" },

-- SUPER
MoonBloom = { Cost = 65000000, SellPrice = 9000, Rarity = "Super" },
DragonsBreath = { Cost = 90000000, SellPrice = 3400, Rarity = "Super" }


}

-- Fungsi Helper untuk mendapatkan daftar tanaman berdasarkan Rarity tertentu
function CropData.GetCropsByRarity(rarityName)
local list = {}
for name, data in pairs(CropData.Crops) do
if data.Rarity == rarityName then
table.insert(list, {Name = name, Cost = data.Cost, SellPrice = data.SellPrice})
end
end
-- Urutkan berdasarkan harga termurah
table.sort(list, function(a, b) return a.Cost < b.Cost end)
return list
end

return CropData
