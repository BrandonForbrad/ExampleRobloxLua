local module = {}
module.TradeRequest = {} -- playeruserid =  {{sender, details = {you give {},  you recieve {}}}}
module.CoolDown = {}
function module:ValidateTrade(receiver, req)
 
    local sInv
    sInv  = self.InventoryService:GetInventory(req.sender) 
    local rInv
    rInv  = self.InventoryService:GetInventory(receiver) 
    --VALIDAtING SENDER INV
    local valid = true
    for i,c in pairs(req.details[1]) do 
        local sIhas = false
        for i2,c2 in pairs(sInv) do 
            if c[1]  == c2[1] then
                if c[2] <= c2[2] then
                    sIhas = true
                end
            end
        end
        if sIhas == false then
            valid = false
        end
    end
 
    for i,c in pairs(req.details[2]) do 
        local sIhas = false
        for i2,c2 in pairs(rInv) do 
            if c[1]  == c2[1] then
                if c[2] <= c2[2] then
                    sIhas = true
                end
            end
        end
        if sIhas == false then
            valid = false
        end
    end
    if req.details[1]["coins"] ~= nil then
        if req.sender.PlrSets.Coins.Value < req.details[1]["coins"] then
            valid = false
        end
    end
    if req.details[2]["coins"] ~= nil then
        if receiver.PlrSets.Coins.Value < req.details[2]["coins"] then
            valid = false
        end
    end
    if game.Players:FindFirstChild(req.sender.Name) == nil then
        valid = false
    end
    if game.Players:FindFirstChild(receiver.Name) == nil then
        valid = false
    end
    if valid then
        return true 
    else
        self.Remotes.Trade:FireClient(req.sender, "Ping", "Unable to send trade: INVALID TRADE")
        warn("Unable to send trade: INVALID TRADE")
    end
end
 
function module:Start()
    print("SERVER UPDATE")
    self.Remotes.Trade.OnServerEvent:Connect(function(player, TYPE,receiver, req) --player, "accept", tradeid
        if TYPE == "send" then
            req.sender = player
            if req.sender ~= nil and req.sender.UserId ~= receiver.UserId  and receiver ~= nil and module.CoolDown[req.sender.UserId] == nil then
                module.CoolDown[player.UserId] = true
                spawn(function() wait(2) module.CoolDown[player.UserId]  = nil end)
                if module:ValidateTrade(receiver, req) then
                    
                    module.TradeRequest[receiver.UserId][#module.TradeRequest[receiver.UserId]+1] = req
                    
                    self.Remotes.Trade:FireClient(receiver, "Trade",  #module.TradeRequest[receiver.UserId],  req)
                    
                end
 
 
            end
        end 
        if TYPE == "accept" then
 
            local tradeid = receiver
            
            if module.TradeRequest[player.UserId][tradeid] ~= nil and module.CoolDown[player.UserId] == nil  then
                
                module.CoolDown[player.UserId] = true
                spawn(function() wait(2) module.CoolDown[player.UserId]  = nil end)
                if module:ValidateTrade(player, module.TradeRequest[player.UserId][tradeid] ) then
                    
                    local trade = module.TradeRequest[player.UserId][tradeid] 
                    for i,c in pairs(trade.details[1]) do
                        module.InventoryService:UpdateInventory(player, c)
                        module.InventoryService:UpdateInventory(trade.sender, {c[1], c[2]*-1})
 
                    end
                    if trade.details[1].coins ~= nil then
                        trade.sender.PlrSets.Coins.Value = trade.sender.PlrSets.Coins.Value + trade.details[1].coins
                        player.PlrSets.Coins.Value = player.PlrSets.Coins.Value - trade.details[1].coins
                    end
                    for i,c in pairs(trade.details[2]) do
                        module.InventoryService:UpdateInventory(trade.sender, c)
                        module.InventoryService:UpdateInventory(player, {c[1], c[2]*-1})
                    end
                    if trade.details[2].coins ~= nil then
                        trade.sender.PlrSets.Coins.Value = trade.sender.PlrSets.Coins.Value - trade.details[2].coins
                        player.PlrSets.Coins.Value = player.PlrSets.Coins.Value + trade.details[2].coins
                    end
                    module.InventoryService:SaveInventoryCache(player)
                    module.InventoryService:SaveInventoryCache(trade.sender)
 
                    
                    self.Remotes.Trade:FireClient(player, "Ping", "trade with "..trade.sender.Name.." completed!")
                    self.Remotes.Trade:FireClient(trade.sender, "Ping", "trade with "..player.Name.." completed!")
                end
 
            
            end
            if TYPE == "decline" then
 
                local tradeid = receiver
                if module.TradeRequest[player.UserId][tradeid] ~= nil and module.CoolDown[player.UserId] == nil then
                    local trade =module.TradeRequest[player.UserId][tradeid]
 
 
                    self.Remotes.Trade:FireClient(player, "Ping", "trade with "..trade.sender.Name.." declined!")
                    self.Remotes.Trade:FireClient(trade.sender, "Ping", "trade with "..player.Name.." declined!")
 
                    module.TradeRequest[player.UserId][tradeid] = nil
 
                    self.Remotes.Trade:FireClient(player, "Update", module.TradeRequest[player.UserId])
                    self.Remotes.Trade:FireClient(trade.sender, "Update", module.TradeRequest[trade.sender.UserId])
                end
            end
            
        end
    end)
end
 
function module:Init()
 
end
 
 
function module:PlayerAdded(player)
    module.TradeRequest[player.UserId] = {}
    
end
 
 
function module:PlayerRemoving(player)
    
    module.TradeRequest[player.UserId] = nil
    for i,c in pairs(game.Players:GetChildren()) do
        for i2, trade in pairs(module.TradeRequest[c.UserId]) do
            if trade.sender.UserId == player.UserId then
                module.TradeRequest[c.UserId][i2] = nil
            end
        end
        self.Remotes.Trade:FireClient(c, "Update", module.TradeRequest[c.UserId])
 
    end
end
return module
 
