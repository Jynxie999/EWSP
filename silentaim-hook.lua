local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Gc = getgc()
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function SearchGc(name)
    for _, v in ipairs(Gc) do
        if typeof(v) == "function" then
            local info = debug.getinfo(v)
            if info.name == name then
                return v
            end
        end
    end
end

local function GetFovTarget(circle, partName)
    local closest, lowest = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char and char:FindFirstChild(partName) and char:FindFirstChild("Humanoid") then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp and char.Humanoid.Health > 0 then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    local dist = (circle.Position - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if dist < circle.Radius and dist < lowest and onScreen then
                        closest, lowest = plr, dist
                    end
                end
            end
        end
    end
    return closest
end

local CastBlacklist = SearchGc("CastBlacklist")
local CastWhitelist = SearchGc("CastWhitelist")

if not CastBlacklist or not CastWhitelist then
    LocalPlayer:Kick("Missing Function, Error Code: #1")
    return
end

local hookfunction = hookfunction or (rawget(_G, "hookfunction") or function(func, newFunc)
    return replaceclosure(func, newFunc)
end)

local OldCast
OldCast = hookfunction(CastBlacklist, function(...)
    local args = { ... }
    local target = GetFovTarget(getgenv().FovCircle, getgenv().SilentAimPart)
    if target and getgenv().SilentAim and target.Character and target.Character:FindFirstChild(getgenv().SilentAimPart) then
        args[2] = target.Character[getgenv().SilentAimPart].Position - args[1]
        if getgenv().SilentAimWallbang then
            args[3] = { target.Character }
            return CastWhitelist(unpack(args))
        end
        return OldCast(unpack(args))
    end
    return OldCast(...)
end)
