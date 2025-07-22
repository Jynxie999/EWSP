return function(Library, Camera, Players, LocalPlayer)
    local RunService = game:GetService("RunService")

    local excludedTools = {
        "Card", "Hot Chips", "Potato Chips", "Phone", "Fist",
        "Crate", "TrashBag", "Knife", "Fake ID", "Standard Clip",
        "Potato", "Drum Magazine", "Extended Clip", "Speed Loader",
        "SkiMask", "Flour", "Heavy Magazine", "CaneBeam", "Bacon Egg And Cheese"
    }

    local showGunsEnabled = false

    local function isExcludedTool(toolName)
        for _, excluded in ipairs(excludedTools) do
            if toolName == excluded then
                return true
            end
        end
        return false
    end

    local function updatePlayerTool(player)
        if not showGunsEnabled then return end
        local character = player.Character
        if not character then return end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        local currentTool = humanoid.Parent:FindFirstChildOfClass("Tool")
        local billboardName = "ToolDisplay"
        local billboard = character:FindFirstChild(billboardName)

        if not billboard then
            billboard = Instance.new("BillboardGui")
            billboard.Name = billboardName
            billboard.AlwaysOnTop = true
            billboard.Size = UDim2.new(3, 0, 1, 0)
            billboard.StudsOffset = Vector3.new(0, 6, 0)

            local textLabel = Instance.new("TextLabel", billboard)
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.TextSize = 20
            textLabel.TextStrokeTransparency = 0.5
            textLabel.BackgroundTransparency = 1
            textLabel.Font = Enum.Font.SourceSansBold

            billboard.Parent = character
        end

        local textLabel = billboard:FindFirstChildOfClass("TextLabel")
        if currentTool then
            local toolName = currentTool.Name
            if isExcludedTool(toolName) then
                textLabel.Text = ""
            else
                textLabel.Text = toolName
                if string.find(toolName, "Micro ARP") or string.find(toolName, "AK Draco") then
                    textLabel.TextColor3 = Color3.new(1, 0, 0)
                elseif string.find(toolName, "MCX") or
                       string.find(toolName, "Draco") or
                       string.find(toolName, "Tec-9") or
                       string.find(toolName, "Springfield XD MOD") or
                       string.find(toolName, "AR Pistol") or
                       string.find(toolName, "P320E") or
                       string.find(toolName, "FN57") or
                       string.find(toolName, "G19EXT") then
                    textLabel.TextColor3 = Color3.new(0, 1, 0)
                elseif string.find(toolName, "Drum") then
                    textLabel.TextColor3 = Color3.new(1, 0.8, 0)
                else
                    textLabel.TextColor3 = Color3.new(1, 1, 1)
                end
            end
        else
            textLabel.Text = ""
        end
    end

    local runningThread

    local function startToolLoop()
        runningThread = task.spawn(function()
            while showGunsEnabled do
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        updatePlayerTool(player)
                    end
                end
                task.wait(0.1)
            end
        end)
    end

    local function stopToolLoop()
        showGunsEnabled = false
        if runningThread then
            coroutine.close(runningThread)
            runningThread = nil
        end
        for _, player in ipairs(Players:GetPlayers()) do
            local char = player.Character
            if char then
                local label = char:FindFirstChild("ToolDisplay")
                if label then label:Destroy() end
            end
        end
    end

    local function onCharacterAdded(character)
        updatePlayerTool(character.Parent)
    end

    local function enable()
        showGunsEnabled = true
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                updatePlayerTool(player)
            end
        end
        startToolLoop()

        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                onCharacterAdded(character)
            end)
        end)
    end

    local function disable()
        stopToolLoop()
    end

    return {
        Enable = enable,
        Disable = disable
    }
end
