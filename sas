
local Inset, Mouse, Client, Vector2New, Cam =
    game:GetService("GuiService"):GetGuiInset().Y,
    game.Players.LocalPlayer:GetMouse(),
    game.Players.LocalPlayer,
    Vector2.new,
    workspace.CurrentCamera
local Targetting

local FOV = Drawing.new("Circle")
FOV.Transparency = 0.5
FOV.Thickness = 1.6
FOV.Color = Color3.fromRGB(230, 230, 250)
FOV.Filled = true

local UpdateFOV = function(Radius)
    if (not FOV) then
        return
    end

    FOV.Position = Vector2New(Mouse.X, Mouse.Y + (Inset))
    FOV.Visible = getgenv().Silent.Setting.FOV["Visible"]
    FOV.Radius = (Radius) * 3.067

    return FOV
end

task.spawn(function() while task.wait() do UpdateFOV(getgenv().Silent.Setting.FOV["Radius"]) end end)

local WallCheck = function(destination, ignore)
    if getgenv().Silent.Setting.WallCheck then
        local Origin = Cam.CFrame.p
        local CheckRay = Ray.new(Origin, destination - Origin)
        local Hit = game.workspace:FindPartOnRayWithIgnoreList(CheckRay, ignore)
        return Hit == nil
    else
        return true
    end
end

local getClosestChar = function()
    local Target, Closest = nil, 1 / 0
    for _, v in pairs(game.Players:GetPlayers()) do
        if (v.Character and v ~= Client and v.Character:FindFirstChild("HumanoidRootPart")) then
            local Position, OnScreen = Cam:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
            local Distance = (Vector2New(Position.X, Position.Y) - Vector2New(Mouse.X, Mouse.Y)).Magnitude

            if
                (FOV.Radius > Distance and Distance < Closest and OnScreen and
                    WallCheck(v.Character.HumanoidRootPart.Position, {Client, v.Character}))
             then
                Closest = Distance
                Target = v
            end
        end
    end
    return Target
end

local Old
Old =
    hookmetamethod(
    game,
    "__index",
    function(self, key)
        if self:IsA("Mouse") and key == "Hit" then
            Targetting = getClosestChar()
            if Targetting ~= nil then
                return Targetting.Character[getgenv().Silent.Setting.TargetPart].CFrame +
                    (Targetting.Character[getgenv().Silent.Setting.TargetPart].Velocity *
                        getgenv().Silent.Setting.Prediction)
            end
        end
        return Old(self, key)
    end
)
