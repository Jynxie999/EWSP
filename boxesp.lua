return function(Library, camera, Players, player)
    local ESPObjects = {}
    local ESPConnections = {}
    local BoxESPEnabled = false

    local function NewQuad(thickness, color)
        local quad = Drawing.new("Quad")
        quad.Visible = false
        quad.Thickness = thickness
        quad.Color = color
        quad.Transparency = 1
        quad.Filled = false
        return quad
    end

    local function CreateESP(plr)
        local box = NewQuad(1, Color3.new(1,1,1))
        ESPObjects[plr] = box

        ESPConnections[plr] = game:GetService("RunService").RenderStepped:Connect(function()
            if not BoxESPEnabled or not box then box.Visible = false return end
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Head") then
                local HumPos, OnScreen = camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if OnScreen then
                    local head = camera:WorldToViewportPoint(plr.Character.Head.Position)
                    local DistanceY = math.clamp((Vector2.new(head.X, head.Y) - Vector2.new(HumPos.X, HumPos.Y)).magnitude, 2, math.huge)
                    box.PointA = Vector2.new(HumPos.X + DistanceY, HumPos.Y - DistanceY * 2)
                    box.PointB = Vector2.new(HumPos.X - DistanceY, HumPos.Y - DistanceY * 2)
                    box.PointC = Vector2.new(HumPos.X - DistanceY, HumPos.Y + DistanceY * 2)
                    box.PointD = Vector2.new(HumPos.X + DistanceY, HumPos.Y + DistanceY * 2)
                    box.Visible = true
                else
                    box.Visible = false
                end
            else
                box.Visible = false
            end
        end)
    end

    local function EnableESP()
        BoxESPEnabled = true
        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= player and not ESPObjects[v] then
                CreateESP(v)
            end
        end

        Players.PlayerAdded:Connect(function(newplr)
            if newplr ~= player then CreateESP(newplr) end
        end)
    end

    local function DisableESP()
        BoxESPEnabled = false
        for _, conn in pairs(ESPConnections) do conn:Disconnect() end
        for _, box in pairs(ESPObjects) do box:Remove() end
        table.clear(ESPConnections)
        table.clear(ESPObjects)
    end

    return {
        Enable = EnableESP,
        Disable = DisableESP
    }
end
