return function(Library, Camera, Players, LocalPlayer)
    local RunService = game:GetService("RunService")
    local Vector2new, Vector3new, CFramenew, DrawingNew = Vector2.new, Vector3.new, CFrame.new, Drawing.new

    local AirChams = {
        Enabled = false,
        Color = Color3.fromRGB(0, 255, 255),
        Transparency = 0.2,
        Thickness = 0,
        Filled = true,
        EntireBody = false,
        Wrapped = {}
    }

    local function WorldToScreen(pos)
        local vec, onScreen = Camera:WorldToViewportPoint(pos)
        return Vector2new(vec.X, vec.Y), onScreen
    end

    local function UpdateCham(part, chamData)
        local cf, size = part.CFrame, part.Size / 2
        local points = {
            cf * CFramenew(-size.X,  size.Y, -size.Z),
            cf * CFramenew( size.X,  size.Y, -size.Z),
            cf * CFramenew(-size.X, -size.Y, -size.Z),
            cf * CFramenew( size.X, -size.Y, -size.Z),
            cf * CFramenew(-size.X,  size.Y,  size.Z),
            cf * CFramenew( size.X,  size.Y,  size.Z),
            cf * CFramenew(-size.X, -size.Y,  size.Z),
            cf * CFramenew( size.X, -size.Y,  size.Z)
        }
        local quads = {
            {1, 2, 4, 3}, {5, 6, 8, 7}, {2, 6, 8, 4},
            {1, 5, 7, 3}, {1, 2, 6, 5}, {3, 4, 8, 7}
        }

        for i, quad in ipairs(quads) do
            local q = chamData["Quad" .. i]
            local visible = AirChams.Enabled
            for p = 1, 4 do
                local screen, onScreen = WorldToScreen(points[quad[p]].Position)
                q["Point" .. string.char(64 + p)] = screen
                if not onScreen then visible = false end
            end
            q.Visible = visible
        end
    end

    local function ApplyChams(player)
        if not AirChams.Enabled or AirChams.Wrapped[player] then return end

        local character = player.Character or player.CharacterAdded:Wait()
        local isR15 = character:FindFirstChild("LowerTorso")
        local parts = {}

        if isR15 then
            if AirChams.EntireBody then
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then table.insert(parts, part) end
                end
            else
                for _, name in ipairs({ "Head", "UpperTorso", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg" }) do
                    local part = character:FindFirstChild(name)
                    if part then table.insert(parts, part) end
                end
            end
        else
            for _, name in ipairs({ "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }) do
                local part = character:FindFirstChild(name)
                if part then table.insert(parts, part) end
            end
        end

        AirChams.Wrapped[player] = {}
        local chamEntry = AirChams.Wrapped[player]

        for _, part in ipairs(parts) do
            local chamData = {}
            for i = 1, 6 do
                local q = DrawingNew("Quad")
                q.Thickness = AirChams.Thickness
                q.Filled = AirChams.Filled
                q.Transparency = AirChams.Transparency
                q.Color = AirChams.Color
                q.Visible = false
                chamData["Quad" .. i] = q
            end
            chamEntry[part] = chamData
        end

        chamEntry.Connection = RunService.RenderStepped:Connect(function()
            if not character or not character:IsDescendantOf(workspace) then return end
            for part, chamData in pairs(chamEntry) do
                if typeof(part) == "Instance" and part:IsA("BasePart") then
                    UpdateCham(part, chamData)
                end
            end
        end)
    end

    local function RemoveChams(player)
        local entry = AirChams.Wrapped[player]
        if not entry then return end

        if entry.Connection then
            pcall(function() entry.Connection:Disconnect() end)
        end

        for _, data in pairs(entry) do
            if typeof(data) == "table" then
                for _, q in pairs(data) do
                    if q.Remove then pcall(function() q:Remove() end) end
                end
            end
        end

        AirChams.Wrapped[player] = nil
    end

    local function enable()
        AirChams.Enabled = true
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                ApplyChams(plr)
            end
        end
    end

    local function disable()
        AirChams.Enabled = false
        for plr, _ in pairs(AirChams.Wrapped) do
            RemoveChams(plr)
        end
    end

    -- Optional: Hook into player join/leave
    Players.PlayerAdded:Connect(function(plr)
        if AirChams.Enabled then ApplyChams(plr) end
    end)
    Players.PlayerRemoving:Connect(RemoveChams)

    return {
        Enable = enable,
        Disable = disable
    }
end
