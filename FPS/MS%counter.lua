-- FPS + Ping Monitor — размещён в PlayerGui с DisplayOrder = 0,
-- чтобы другие интерфейсы могли накладываться поверх.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
if not player then return end

local function getPing()
    local ok, value = pcall(function()
        local item = Stats.Network and Stats.Network.ServerStatsItem and Stats.Network.ServerStatsItem["Data Ping"]
        if not item then return nil end
        return item:GetValueString()
    end)
    if not ok or not value then return 0 end
    local pingNum = value:match("%d+%.?%d*")
    return tonumber(pingNum) and math.floor(tonumber(pingNum)) or 0
end

local function createMonitor()
    local playerGui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 5)
    if not playerGui then return end

    local hostGui = playerGui:FindFirstChild("FPSPingGui")
    if not hostGui then
        hostGui = Instance.new("ScreenGui")
        hostGui.Name = "FPSPingGui"
        hostGui.ResetOnSpawn = false
        hostGui.DisplayOrder = 0
        hostGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        hostGui.Parent = playerGui
    end

    local oldFrame = hostGui:FindFirstChild("FPSPingFrame")
    if oldFrame then oldFrame:Destroy() end

    local frame = Instance.new("Frame")
    frame.Name = "FPSPingFrame"
    frame.Size = UDim2.new(0, 200, 0, 44)
    frame.Position = UDim2.new(1, 0, 0, -45) -- ПРАВЫЙ ВЕРХНИЙ УГОЛ с отступом сверху 15 пикселей
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
    frame.BackgroundTransparency = 0.08
    frame.Parent = hostGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = frame

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.new(1, 1, 1)
    text.Font = Enum.Font.BuilderSansBold
    text.TextSize = 16
    text.Text = "FPS: -- | Ping: --ms"
    text.Parent = frame

    local accumulatedDelta = 0
    local frameCount = 0
    local conn
    conn = RunService.RenderStepped:Connect(function(delta)
        if not frame.Parent then
            conn:Disconnect()
            return
        end
        frameCount = frameCount + 1
        accumulatedDelta = accumulatedDelta + delta
        if accumulatedDelta >= 1 then
            local fps = frameCount / accumulatedDelta
            local ping = getPing()
            text.Text = string.format("FPS: %.1f | Ping: %dms", fps, ping)
            frameCount = 0
            accumulatedDelta = 0
        end
    end)
end

createMonitor()
print("FPS + Ping Monitor loaded (правый верхний угол, смещение вниз 15px).")
