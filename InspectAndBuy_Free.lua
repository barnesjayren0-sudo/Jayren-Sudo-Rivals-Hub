-- Grok Hacker - InspectAndBuy Free Purchase Bypass (Rayfield)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Grok Hacker - Free Avatar Shop",
})

local Tab = Window:CreateTab("Buy Bypass", 4483362458)

Tab:CreateToggle({
    Name = "Enable Free Purchases",
    CurrentValue = true,
    Callback = function(Value)
        if Value then
            local MarketplaceService = game:GetService("MarketplaceService")
            local oldPrompt = MarketplaceService.PromptPurchase
            MarketplaceService.PromptPurchase = function(self, player, assetId, ...)
                print("Free purchase for: " .. assetId)
                MarketplaceService:FirePromptPurchaseFinished(player, assetId, true)
                return oldPrompt(self, player, assetId, ...)
            end
            
            local oldBundle = MarketplaceService.PromptBundlePurchase
            MarketplaceService.PromptBundlePurchase = function(self, player, bundleId, ...)
                print("Free bundle: " .. bundleId)
                MarketplaceService:FirePromptBundlePurchaseFinished(player, bundleId, true)
                return oldBundle(self, player, bundleId, ...)
            end
            
            Rayfield:Notify({Title = "Free Buy ON", Content = "Buy anything in shop for free!", Duration = 5})
        end
    end,
})

print("✅ Rayfield Free Shop Hack Loaded")
