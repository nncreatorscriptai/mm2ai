-- Надежный ESP для MM2 (через Highlight и BillboardGui)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Colors = {
    Murderer = Color3.fromRGB(255, 0, 0),     -- Красный
    Sheriff = Color3.fromRGB(0, 150, 255),    -- Синий
    Innocent = Color3.fromRGB(0, 255, 0),     -- Зеленый
    GunDrop = Color3.fromRGB(255, 255, 0)     -- Желтый
}

local function applyESP(character, color, roleName)
    if not character:FindFirstChild("HumanoidRootPart") then return end
    
    -- 1. Подсветка силуэта сквозь стены (Highlight)
    if not character:FindFirstChild("MM2_Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "MM2_Highlight"
        highlight.Adornee = character
        highlight.FillColor = color
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = character
    end

    -- 2. Текст над головой (BillboardGui)
    if not character:FindFirstChild("MM2_Tag") then
        local head = character:WaitForChild("Head", 5)
        if head then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "MM2_Tag"
            billboard.Adornee = head
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 2.5, 0)
            billboard.AlwaysOnTop = true

            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = roleName
            textLabel.TextColor3 = color
            textLabel.TextScaled = true
            textLabel.Font = Enum.Font.SourceSansBold
            textLabel.TextStrokeTransparency = 0
            textLabel.Parent = billboard

            billboard.Parent = character
        end
    end
end

local function checkPlayer(player)
    if player == LocalPlayer then return end

    local function update()
        local character = player.Character
        if not character then return end

        task.wait(0.5) -- Ждем прогрузку персонажа

        local role = "Innocent"
        local color = Colors.Innocent

        -- Проверяем инвентарь и руки
        local function scan(item)
            if item:IsA("Tool") then
                if item.Name == "Knife" then
                    role = "Murderer"
                    color = Colors.Murderer
                elseif item.Name == "Gun" then
                    role = "Sheriff"
                    color = Colors.Sheriff
                end
            end
        end

        if player.Backpack then
            for _, item in ipairs(player.Backpack:GetChildren()) do scan(item) end
        end
        for _, item in ipairs(character:GetChildren()) do scan(item) end

        applyESP(character, color, player.Name .. "\n[" .. role .. "]")
    end

    player.CharacterAdded:Connect(function()
        task.wait(1)
        update()
    end)

    if player.Character then
        task.spawn(update)
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    checkPlayer(p)
end

Players.PlayerAdded:Connect(checkPlayer)

print("MM2 ESP (v2) Loaded!")
