return function(Library, camera, Players, LocalPlayer)
    local RunService = game:GetService("RunService")
    local NameESPTexts = {}
    local NameESPConnections = {}
    local GlobalConnections = {}

    local function removeESP(player)
        if NameESPConnections[player] then
            for _, conn in ipairs(NameESPConnections[player]) do
                pcall(function() conn:Disconnect() end)
            end
            NameESPConnections[player] = nil
        end

        if NameESPTexts[player] then
            pcall(function()
                NameESPTexts[player].Visible = false
                NameESPTexts[player]:Remove()
            end)
            NameESPTexts[player] = nil
        end
    end

    local function createESP(player, character)
        local head = character:WaitForChild("Head", 5)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if not head or not humanoid then return end

        removeESP(player)

        local text = Drawing.new("Text")
        text.Visible = false
        text.Center = true
        text.Outline = true
        text.Font = 2
        text.Size = 14
        text.Color = Color3.fromRGB(255, 255, 255)

        NameESPTexts[player] = text

        local renderConn = RunService.RenderStepped:Connect(function()
            if not character:IsDescendantOf(workspace) then
                removeESP(player)
                return
            end

            local pos, onScreen = camera:WorldToViewportPoint(head.Position)
            if onScreen then
                text.Position = Vector2.new(pos.X, pos.Y - 25)
                text.Text = player.DisplayName
                text.Visible = true
            else
                text.Visible = false
            end
        end)

        local deathConn = humanoid.HealthChanged:Connect(function(health)
            if health <= 0 then
                removeESP(player)
            end
        end)

        local ancestorConn = character.AncestryChanged:Connect(function(_, parent)
            if not parent then
                removeESP(player)
            end
        end)

        NameESPConnections[player] = {renderConn, deathConn, ancestorConn}
    end

    local function handlePlayer(player)
        if player == LocalPlayer then return end
        if player.Character then createESP(player, player.Character) end

        local charConn = player.CharacterAdded:Connect(function(char)
            createESP(player, char)
        end)

        if not NameESPConnections[player] then
            NameESPConnections[player] = {}
        end
        table.insert(NameESPConnections[player], charConn)
    end

    local function enable()
        for _, player in ipairs(Players:GetPlayers()) do
            handlePlayer(player)
        end

        GlobalConnections["PlayerAdded"] = Players.PlayerAdded:Connect(handlePlayer)
        GlobalConnections["PlayerRemoving"] = Players.PlayerRemoving:Connect(removeESP)
    end

    local function disable()
        for player in pairs(NameESPConnections) do
            removeESP(player)
        end

        for _, conn in pairs(GlobalConnections) do
            pcall(function() conn:Disconnect() end)
        end

        GlobalConnections = {}
    end

    return {
        Enable = enable,
        Disable = disable
    }
end
