return function(Library, camera, Players, LocalPlayer)
    local RunService = game:GetService("RunService")
    local Vector2new = Vector2.new
    local HSVtoRGB = function(h, s, v)
        local c = v * s
        local x = c * (1 - math.abs((h * 6) % 2 - 1))
        local m = v - c
        local r, g, b

        if h < 1/6 then r, g, b = c, x, 0
        elseif h < 2/6 then r, g, b = x, c, 0
        elseif h < 3/6 then r, g, b = 0, c, x
        elseif h < 4/6 then r, g, b = 0, x, c
        elseif h < 5/6 then r, g, b = x, 0, c
        else r, g, b = c, 0, x end

        return Color3.new(r + m, g + m, b + m)
    end

    local connections = {}

    local function NewLine(thickness, color)
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = thickness
        line.Color = color
        line.Transparency = 1
        return line
    end

    local function Visibility(state, lib)
        if lib then lib.Visible = state end
    end

    local function createHealthBar(player)
        if player == LocalPlayer then return end

        local healthbar = NewLine(3, Color3.fromRGB(0, 0, 0))
        local greenhealth = NewLine(1.5, Color3.fromRGB(0, 255, 0))

        local conn = RunService.RenderStepped:Connect(function()
            local char = player.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")

            if hum and hrp and head then
                local HumPos, OnScreen = camera:WorldToViewportPoint(hrp.Position)
                if OnScreen then
                    local HeadPos = camera:WorldToViewportPoint(head.Position)
                    local DistanceY = math.clamp((Vector2new(HeadPos.X, HeadPos.Y) - Vector2new(HumPos.X, HumPos.Y)).magnitude, 2, math.huge)
                    local d = (Vector2new(HumPos.X - DistanceY, HumPos.Y - DistanceY * 2) - Vector2new(HumPos.X - DistanceY, HumPos.Y + DistanceY * 2)).magnitude
                    local offset = hum.Health / hum.MaxHealth * d

                    greenhealth.From = Vector2new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY * 2)
                    greenhealth.To = Vector2new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY * 2 - offset)

                    healthbar.From = Vector2new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY * 2)
                    healthbar.To = Vector2new(HumPos.X - DistanceY - 4, HumPos.Y - DistanceY * 2)

                    greenhealth.Color = HSVtoRGB((tick() % 5) / 5, 1, 1)

                    Visibility(true, healthbar)
                    Visibility(true, greenhealth)
                else
                    Visibility(false, healthbar)
                    Visibility(false, greenhealth)
                end
            else
                Visibility(false, healthbar)
                Visibility(false, greenhealth)
            end
        end)

        connections[player] = {conn, healthbar, greenhealth}
    end

    local function enable()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                createHealthBar(plr)
            end
        end

        connections.PlayerAdded = Players.PlayerAdded:Connect(function(plr)
            if plr ~= LocalPlayer then
                createHealthBar(plr)
            end
        end)
    end

    local function disable()
        for k, v in pairs(connections) do
            if k ~= "PlayerAdded" then
                local conn, healthbar, greenhealth = unpack(v)
                if conn then conn:Disconnect() end
                if healthbar then healthbar:Remove() end
                if greenhealth then greenhealth:Remove() end
            end
        end
        if connections.PlayerAdded then
            connections.PlayerAdded:Disconnect()
        end
        connections = {}
    end

    return {
        Enable = enable,
        Disable = disable
    }
end
