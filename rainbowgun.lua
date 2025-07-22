return function(Library, Camera, Players, LocalPlayer)
    local RunService = game:GetService("RunService")

    local rainbowGun = {
        Enabled = false,
        Connections = {},
        CurrentGun = nil
    }

    local function getRainbowColor(hueShift)
        return Color3.fromHSV((tick() * hueShift % 5) / 5, 1, 1)
    end

    local function cleanPart(part)
        for _, child in ipairs(part:GetChildren()) do
            if child:IsA("SurfaceAppearance") then
                child:Destroy()
            elseif child:IsA("SpecialMesh") then
                child.TextureId = ""
            end
        end
        if part:IsA("MeshPart") then
            part.TextureID = ""
        end
        part.Material = Enum.Material.Plastic
    end

    local function getAllParts(model)
        local parts = {}
        for _, descendant in ipairs(model:GetDescendants()) do
            if descendant:IsA("BasePart") then
                table.insert(parts, descendant)
            end
        end
        return parts
    end

    local function disconnectAll()
        for _, conn in ipairs(rainbowGun.Connections) do
            pcall(function() conn:Disconnect() end)
        end
        table.clear(rainbowGun.Connections)
    end

    local function applyRainbow(gun)
        disconnectAll()
        if not gun then return end

        local gunParts = getAllParts(gun)
        for _, part in ipairs(gunParts) do
            cleanPart(part)
        end

        local conn = RunService.RenderStepped:Connect(function()
            if not rainbowGun.Enabled then return end
            local color = getRainbowColor(0.5)
            for _, part in ipairs(gunParts) do
                if part:IsA("BasePart") and part:IsDescendantOf(gun) then
                    part.Color = color
                end
            end
        end)

        table.insert(rainbowGun.Connections, conn)
    end

    local function onToolEquipped(tool)
        local handle = tool:WaitForChild("Handle", 3)
        local gunModel = handle and handle.Parent
        if gunModel and gunModel:IsDescendantOf(workspace) then
            applyRainbow(gunModel)
        end
    end

    local function enable()
        rainbowGun.Enabled = true

        -- Detect future equips
        table.insert(rainbowGun.Connections, LocalPlayer.CharacterAdded:Connect(function(char)
            char.ChildAdded:Connect(function(child)
                if child:IsA("Tool") then
                    onToolEquipped(child)
                end
            end)
        end))

        if LocalPlayer.Character then
            table.insert(rainbowGun.Connections, LocalPlayer.Character.ChildAdded:Connect(function(child)
                if child:IsA("Tool") then
                    onToolEquipped(child)
                end
            end))

            -- Detect current equipped tool
            local currentTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if currentTool then
                onToolEquipped(currentTool)
            end
        end
    end

    local function disable()
        rainbowGun.Enabled = false
        disconnectAll()
    end

    return {
        Enable = enable,
        Disable = disable
    }
end
