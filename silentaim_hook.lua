local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Gc = getgc()

local function GetFovTarget(circle, part)
    local closest, dist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char and char:FindFirstChild(part) and char:FindFirstChild("Humanoid") then
                if char.Humanoid.Health > 0 then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(char[part].Position)
                    local mag = (getgenv().FovCircle.Position - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if onScreen and mag < getgenv().FovCircle.Radius and mag < dist then
                        dist = mag
                        closest = plr
                    end
                end
            end
        end
    end
    return closest
end

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

local CastBlacklist = SearchGc("CastBlacklist")
local CastWhitelist = SearchGc("CastWhitelist")
if not CastBlacklist or not CastWhitelist then return LocalPlayer:Kick("Silent Aim missing required functions") end

local hookfunction = hookfunction or replaceclosure
local Old; Old = hookfunction(CastBlacklist, function(...)
    local target = GetFovTarget(getgenv().FovCircle, getgenv().SilentAimPart)
    if getgenv().SilentAim and target and target.Character and target.Character:FindFirstChild(getgenv().SilentAimPart) then
        local args = { ... }
        args[2] = target.Character[getgenv().SilentAimPart].Position - args[1]
        if getgenv().SilentAimWallbang then
            args[3] = { target.Character }
            return CastWhitelist(unpack(args))
        end
        return Old(unpack(args))
    end
    return Old(...)
end)
