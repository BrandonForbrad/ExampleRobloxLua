local module = {}
 
function module:Start()
    local Player = game.Players.LocalPlayer
    local GameInfo = self.Assets.GameInfo
    wait(1)
    GameInfo.TopMessage.Changed:Connect(function() 
        if GameInfo.TopMessage.Value == "" then
 
            self.Gui.MainHud.TopMessage:TweenPosition(UDim2.new(0.2, 0,-0.5, 0))
            wait(1)
            self.Gui.MainHud.TopMessage.Visible = false
            
        else
            if self.Gui.MainHud.TopMessage.Visible == false then
                self.Gui.MainHud.TopMessage.Visible = true
                self.Gui.MainHud.TopMessage.Position = UDim2.new(0.2, 0,-0.5, 0)
                self.Gui.MainHud.TopMessage:TweenPosition(UDim2.new(0.2, 0,0.107, 0))
            end
 
        end
        self.Gui.MainHud.TopMessage.Text = GameInfo.TopMessage.Value
        
 
    end)
 
    GameInfo.Timer.Changed:Connect(function() 
        if GameInfo.Timer.Value == 0 then
 
            self.Gui.MainHud.Timer:TweenPosition(UDim2.new(0.368, 0,-0.5, 0))
            wait(1)
            self.Gui.MainHud.Timer.Visible = false
            
        else
            if  self.Gui.MainHud.Timer.Visible == false then
                self.Gui.MainHud.Timer.Visible = true
                self.Gui.MainHud.Timer.Position = UDim2.new(0.368, 0,-0.5, 0)
                self.Gui.MainHud.Timer:TweenPosition(UDim2.new(0.368, 0,0.006, 0))
            end
 
        end
        self.Gui.MainHud.Timer.Value.Text = GameInfo.Timer.Value
 
 
    end)
    for i,c in pairs(self.Assets.MapsToVote:GetChildren()) do
        local selui = self.Gui.MainHud.MapVote[c.Name]
        self.Assets.MapsToVote[c.Name].Changed:Connect(function() 
            selui.Image = self.Assets.MapPics[self.Assets.MapsToVote[c.Name].Value].Image
            selui.MapName.Text = self.Assets.MapsToVote[c.Name].Value
        end)
        self.Assets.MapsToVote[c.Name].Votes.Changed:Connect(function() 
            selui.Votes.Text = self.Assets.MapsToVote[c.Name].Votes.Value
        end)
 
        self.Gui.MainHud.MapVote[c.Name].Button.MouseButton1Down:Connect(function() 
            self.Remotes.VoteMap:FireServer(c.Name)
        end)
    end
 
    self.Remotes.VoteMap.OnClientEvent:Connect(function(inp) 
        if inp == "close" then
            self.Gui.MainHud.MapVote.Position = UDim2.new(0.226, 0,0.241, 0)
            self.Gui.MainHud.MapVote:TweenPosition(UDim2.new(0.226, 0,-0.4, 0))
        end
        if inp == "open" then
            self.Gui.MainHud.MapVote.Visible = true
            self.Gui.MainHud.MapVote.Position = UDim2.new(0.226, 0,-0.4, 0)
            self.Gui.MainHud.MapVote:TweenPosition(UDim2.new(0.226, 0,0.241, 0))
        end
    end)
 
 
 
    local LASTBL = {}
    local BLUi = self.Gui.MainHud.BottomLeader
    local function Spectate(playerName)
        if game.Players.LocalPlayer.PlrSets.Dead.Value == true then
            workspace.CurrentCamera.CameraSubject = game.Workspace:FindFirstChild(playerName)
            self.Gui.MainHud.Spectate.Close.Visible = true
        end
        
    end
    self.Remotes.UpdateBL.OnClientEvent:Connect(function(changed) 
        if changed == "clear" then
            for i,c in pairs(BLUi:GetChildren()) do
                if c:IsA("ImageButton") then
                    c:Destroy()
                end
            end
        else
 
            local BL = {} -- {playerName, am}
            for i,c in pairs(game.Players:GetChildren()) do
                BL[#BL+1] = {c.Name, c.PlrSets.CoinsCollected.Value}
            end
            table.sort(BL, function(a, b) return a[2] > b[2] end)
 
            
            local function Create(i,c)
                local cSetUI = game.Players[c[1]].PlrSets.BLplr:Clone()
                cSetUI.Name = i
                cSetUI.Title.Text = c[1]
                cSetUI.Coin.Amount.Text = c[2]
                if game.Players[c[1]].PlrSets.VIP.Value == true then
                    cSetUI.VIPImg.Visible = true
                end
                cSetUI.Parent = BLUi
                
                cSetUI.MouseButton1Down:Connect(function() 
                    Spectate(cSetUI.Title.Text)
                end)
                return cSetUI
            end
            for i,c in pairs(BL) do 
                if game.Players:FindFirstChild(c[1]) then
                    if game.Players[c[1]].PlrSets.CoinsCollected.Value > 0 then
                        if BLUi:FindFirstChild(i    ) then
                            if  game.Players[c[1]].PlrSets.Dead.Value == true then 
                                BLUi[i].BackgroundTransparency = 0.5
                            else
                                BLUi[i].BackgroundTransparency = 1
                            end
                            BLUi[i].Image = game.Players[c[1]].PlrSets.BLplr.Image
                            BLUi[i].Title.Text = c[1]
                            BLUi[i].Coin.Amount.Text = c[2]
                            if game.Players[c[1]].PlrSets.VIP.Value == true then
                                BLUi[i].VIPImg.Visible = true
                            else
                                BLUi[i].VIPImg.Visible = false
                            end
                        else
 
                            local cSetUI = Create(i,c) 
                            if i > 1 then 
                                if (i % 2 == 0) then
                                    --even
                                    cSetUI.Position = cSetUI.Position  - UDim2.new(0 + (0.15 * math.floor(i/2)) ,0,0,0)
                                else
                                    --odd
                                    cSetUI.Position = cSetUI.Position  + UDim2.new(0 + (0.15 * math.floor(i/2)) ,0,0,0)
                                end
                            end
 
                        end
                        if changed.Name == c[1] then
                            spawn(function() 
                                BLUi[i].Coin.Amount.TextColor3 = Color3.fromRGB(0, 255, 0)
                                BLUi[i].Coin:TweenSize(UDim2.new(0.853,0,0.885,0))
                                wait(1)
                                BLUi[i].Coin:TweenSize(UDim2.new(0.653, 0,0.685, 0))
                                wait(1)
                                BLUi[i].Coin.Amount.TextColor3 = Color3.fromRGB(255, 250, 89)
                                BLUi[i].Coin.Size = UDim2.new(0.653, 0,0.685, 0)
                            end)
 
                        end
                    else 
                        if BLUi:FindFirstChild(i) then
                            BLUi[i]:Destroy()
                        end
 
                    end
 
 
                end
 
 
 
            end
            local count = 0
            
            for i,c in pairs(self.Gui.MainHud.BottomLeader:GetChildren()) do
                if c:IsA("ImageButton") then
                    count = count + 1
                end
            end
            if count == 0 then 
                workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character
                self.Gui.MainHud.Spectate.Close.Visible = false
                self.Gui.MainHud.Spectate.Label.Visible = false
            else
                
                 if game.Players.LocalPlayer.PlrSets.Dead.Value == true then
                    self.Gui.MainHud.Spectate.Label.Visible = true
                end
            end
        end
 
 
 
    end)
 
    self.Remotes.EndGame.OnClientEvent:Connect(function() 
        spawn(function() 
            game.SoundService.SFX.Whoosh:Play()
            wait(2)
            game.SoundService.SFX.Punch:Play()
            wait(1)
            if #BLUi:GetChildren() > 2 then
                
                game.SoundService.SFX.Punch:Play()
                
            end
            wait(1)
            game.SoundService.SFX.Punch:Play()
            wait(1)
            game.SoundService.SFX.Punch:Play()
        end)
        for i,c in pairs(BLUi:GetChildren()) do
            if c:IsA("ImageButton") then
                spawn(function()
                    c.WinnerBar.Visible = true
                    if c.Name == "1" then
                        c.WinnerBar.BackgroundColor3 = Color3.fromRGB(255, 255, 127)
                    end
                    if c.Name == "2" then
                        c.WinnerBar.BackgroundColor3 = Color3.fromRGB(85, 255, 255)
                    end
                    if c.Name == "3" then
                        c.WinnerBar.BackgroundColor3 = Color3.fromRGB(85, 255, 255)
                    end
                    c:TweenPosition(UDim2.new(c.Position.X.Scale,0,-5 + (0.5 * tonumber(c.Name) ),0))
                    spawn(function() 
                        wait(2)
                        local NOTHING = true
                        if c.Name == "1" then
                            c["1st"].Visible = true
                            NOTHING = false
                        end
                        wait(1)
                        if c.Name == "2" then
                            c["1st"].Text = "2nd: x1.5"
                            c["1st"].Visible = true
                            c["1st"].TextColor3 = Color3.fromRGB(85, 255, 255)
                            NOTHING = false
                        end
                        if c.Name == "3" then
                            c["1st"].Text = "3nd: x1.5"
                            c["1st"].Visible = true
                            c["1st"].TextColor3 = Color3.fromRGB(85, 255, 255)
                            NOTHING = false
                        end
                        if NOTHING then 
                            c["1st"].Text = "x1"
                            c["1st"].Visible = true
                            c["1st"].TextColor3 = Color3.fromRGB(255, 255, 255)
                        end
                        wait(1)
                        if c.BackgroundTransparency == 0.5 then
                            local c1st = c["1st"]:Clone()
                            c1st.Visible = true
                    
                            c1st.Text = "Dead: /2"
                            c1st.TextColor3 = Color3.fromRGB(255, 0, 0)
                            c1st.Position =  UDim2.new( 0,0,-1.512,0)
                            c1st.Parent = c
                            if c.VIPImg.Visible == true then
                                wait(1)
                                c.VIP.Position =  UDim2.new( 0,0,-2.016,0)
                                c.VIP.Visible = true
                            end
                        else
                            if c.VIPImg.Visible == true then
                                wait(1)
                                c.VIP.Position = UDim2.new( 0,0,-1.512,0)
                                c.VIP.Visible = true
                            end
                        end
                    end)
                    wait(9)
                    c:TweenPosition(UDim2.new(c.Position.X.Scale,0,-0.016,0) )
                    wait(1)
                    c:Destroy()
                end)
            end
        end
 
    end)
    
    for i,c in pairs(Player.PlrSets.Powerup:GetChildren()) do
        Player.PlrSets.Powerup[c.Name].Changed:Connect(function(val) 
            if val == true then
                local Cpq = self.Gui.MainHud.Misc.PQSet:Clone()
                Cpq.Visible = true
                Cpq.Image = self.Assets.Items[c.Name].PrimaryPart.Settings.Icon.Image
                Cpq.Timer.Text = self.Assets.Items[c.Name].PrimaryPart.Settings.Duratation.Value
                Cpq.Parent = self.Gui.MainHud.PUQ
                local count = self.Assets.Items[c.Name].PrimaryPart.Settings.Duratation.Value
                repeat 
                    wait(1)
                    count = count - 1
                    Cpq.Timer.Text = count
                until count <= 0 or Player.PlrSets.Powerup[c.Name].Value == false
                Cpq:Destroy()
                
            end
        end)  
        
    end
    
    Player.PlrSets.Coins.Changed:Connect(function(val)
        if self.Gui.MainHud.Coins.Amount.Text ~= "LOADING..." then
            local new = val - tonumber(self.Gui.MainHud.Coins.Amount.Text) 
            local cNew = self.Gui.MainHud.Coins.NEW:Clone()
            cNew.Parent = self.Gui.MainHud.Coins
            cNew.Visible = true
            if new > 0 then 
                cNew.Text = "+"..new
                game.SoundService.SFX.CoinCollect:Play()
            else
                cNew.Text = new
                cNew.TextColor3 = Color3.fromRGB(255, 0, 0)
            end
            self.Gui.MainHud.Coins.Amount.Text = val
            cNew:TweenPosition(UDim2.new(cNew.Position.X.Scale,0,-2.5,0))
            wait(1)
            cNew:Destroy()
        else
            self.Gui.MainHud.Coins.Amount.Text = val
        end
        
    end)
    spawn(function() wait(3)
        self.Gui.MainHud.Coins.Amount.Text = Player.PlrSets.Coins.Value
    end)
    local cam = workspace.CurrentCamera
    self.Gui.MainHud.Spectate.Close.MouseButton1Down:Connect(function() 
        cam.CameraSubject = game.Players.LocalPlayer.Character
        self.Gui.MainHud.Spectate.Close.Visible = false
    end)
 
end
 
function module:Init()
 
end
 
 
 
return module
