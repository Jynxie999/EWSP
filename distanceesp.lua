return function(Library, Camera, Players, LocalPlayer)
    local RunService = game:GetService("RunService")

    local activeESP = {}
    local connections = {}
    local PlayerAddedConn

    local function removeESP(player)
        if activeESP[player] then
            for _, obj in ipairs(activeESP[player]) do
                if typeof(obj) == "Instance" or typeof(obj) == "RBXScriptConnection" then
                    pcall(function() obj:Disconnect() end)
                elseif typeof(obj) == "table" then
                    for _, drawing in ipairs(obj) do
                        pcall(function()
                            drawing.Visible = false
                            drawing:Remove()
                        end)
                    end
                end
            end
            activeESP[player] = nil
        end
    end

    local function createESP(player, character)
        local Humanoid = character:WaitForChild("Humanoid", 5)
        local Head = character:WaitForChild("Head", 5)
        if not Humanoid or not Head then return end

        removeESP(player)

        local label = Drawing.new("Text")
        label.Visible = false
        label.Center = true
        label.Outline = true
        label.Font = 2
        label.Size = 13
        label.Color = Color3.new(1, 1, 1)

        local distanceLabel = Drawing.new("Text")
        distanceLabel.Visible = false
        distanceLabel.Center = true
        distanceLabel.Outline = true
        distanceLabel.Font = 2
        distanceLabel.Size = 13
        distanceLabel.Color = Color3.new(1, 0.5, 0)

        local renderConn = RunService.RenderStepped:Connect(function()
            if not character:IsDescendantOf(workspace) then
                removeESP(player)
                return
            end

            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local screenPos, onScreen = Camera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
            if onScreen then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                label.Position = Vector2.new(screenPos.X, screenPos.Y - 14)
                label.Text = "Distance:"
                label.Visible = true

                distanceLabel.Position = Vector2.new(screenPos.X, screenPos.Y)
                distanceLabel.Text = string.format("%.1f", distance)
                distanceLabel.Visible = true
            else
                label.Visible = false
                distanceLabel.Visible = false
            end
        end)

        local deathConn = Humanoid.HealthChanged:Connect(function(health)
            if health <= 0 then
                removeESP(player)
            end
        end)

        local ancestryConn = character.AncestryChanged:Connect(function(_, parent)
            if not parent then
                removeESP(player)
            end
        end)

        activeESP[player] = {
            {label, distanceLabel},
            renderConn,
            deathConn,
            ancestryConn
        }
    end

    local function onCharacterLoaded(player, character)
        if player == LocalPlayer then return end
        createESP(player, character)
    end

    local function onPlayerAdded(player)
        connections[player] = player.CharacterAdded:Connect(function(character)
            onCharacterLoaded(player, character)
        end)
        if player.Character then
            onCharacterLoaded(player, player.Character)
        end
    end

    local function enable()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                onPlayerAdded(player)
            end
        end
        PlayerAddedConn = Players.PlayerAdded:Connect(onPlayerAdded)
    end

    local function disable()
        if PlayerAddedConn then PlayerAddedConn:Disconnect() end
        for _, conn in pairs(connections) do
            pcall(function() conn:Disconnect() end)
        end
        connections = {}

        for player in pairs(activeESP) do
            removeESP(player)
        end
    end

    return {
        Enable = enable,
        Disable = disable
    }
end
