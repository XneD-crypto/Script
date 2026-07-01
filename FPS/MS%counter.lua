-- FPS + Ping Monitor — позиция восстановлена к оригинальной.
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
    -- Try PlayerGui TopbarStandard path first (original position)
    if player and player:FindFirstChild("PlayerGui") then
        local topbar = player.PlayerGui:FindFirstChild("TopbarStandard")
        if topbar and topbar:FindFirstChild("Holders") and topbar.Holders:FindFirstChild("Left") then
            local leftHolder = topbar.Holders.Left
            if leftHolder:FindFirstChild("FPSPingFrame") then return end

            local frame = Instance.new("Frame")
            frame.Name = "FPSPingFrame"
            frame.Size = UDim2.new(0, 180, 0, 44)
            frame.Position = UDim2.new(1, -190, 0, 0) -- ВОЗВРАЩЕНО: как в оригинале
            frame.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
            frame.BackgroundTransparency = 0.08
            frame.Parent = leftHolder

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
            return
        end
    end

    -- Fallback to CoreGui TopBarApp path (original fallback layout)
    local coreGui = game:GetService("CoreGui")
    local topBarApp = coreGui:FindFirstChild("TopBarApp")
    if not topBarApp then return end
    local container = topBarApp:FindFirstChild("TopBarApp") or topBarApp
    if container:FindFirstChild("FPSPingFrame") then return end

    local frame1 = Instance.new("Frame")
    frame1.Name = "FPSPingFrame"
    frame1.Size = UDim2.new(1, 0, 0, 48)
    frame1.Position = UDim2.new(0, 0, 0, 10)
    frame1.BackgroundTransparency = 1
    frame1.Parent = container

    local frame2 = Instance.new("Frame")
    frame2.Size = UDim2.new(1, 0, 0, 44)
    frame2.Position = UDim2.new(0, 0, 0, 2)
    frame2.BackgroundTransparency = 1
    frame2.Parent = frame1

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 12)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Parent = frame2

    local frame3 = Instance.new("Frame")
    frame3.Size = UDim2.new(0, 180, 0, 44)
    frame3.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
    frame3.BackgroundTransparency = 0.08
    frame3.Parent = frame2

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = frame3

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.new(1, 1, 1)
    text.Font = Enum.Font.BuilderSansBold
    text.TextSize = 16
    text.Text = "FPS: -- | Ping: --ms"
    text.Parent = frame3

    local accumulatedDelta = 0
    local frameCount = 0
    local conn
    conn = RunService.RenderStepped:Connect(function(delta)
        if not frame3.Parent then
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
print("FPS + Ping Monitor loaded.")
