-- ESP Script for MM2
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Настройки цветов
local Colors = {
    Murderer = Color3.fromRGB(255, 0, 0),     -- Красный
    Sheriff = Color3.fromRGB(0, 150, 255),    -- Синий
    Innocent = Color3.fromRGB(0, 255, 0),     -- Зеленый
    GunDrop = Color3.fromRGB(255, 255, 0)     -- Желтый (выпавший пистолет)
}

local function createESP(character, color, textString)
    local rootPart = character:WaitForChild("HumanoidRootPart", 5)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not rootPart or not humanoid then return end

    -- Создаем текст над головой
    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = true
    text.Font = 2
    text.Size = 16
    text.Color = color

    local connection
    connection = game:GetService("RunService").RenderStepped:Connect(function()
        if not character or not character.Parent or humanoid.Health <= 0 then
            text:Remove()
            connection:Disconnect()
            return
        end

        local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 2.5, 0))
        if onScreen then
            text.Position = Vector2.new(vector.X, vector.Y)
            text.Text = textString
            text.Visible = true
        else
            text.Visible = false
        end
    end)
end

-- Функция проверки ролей в MM2
local function setupPlayer(player)
    if player == LocalPlayer then return end

    player.CharacterAdded:Connect(function(character)
        task.wait(1)
        local role = "Innocent"
        local color = Colors.Innocent

        -- Проверка инвентаря на наличие ножа или пистолета
        local function checkBackpack(item)
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

        for _, item in ipairs(player.Backpack:GetChildren()) do checkBackpack(item) end
        player.Backpack.ChildAdded:Connect(checkBackpack)

        if character:FindFirstChild("Knife") then
            role = "Murderer"
            color = Colors.Murderer
        elseif character:FindFirstChild("Gun") then
            role = "Sheriff"
            color = Colors.Sheriff
        end

        createESP(character, color, player.Name .. " [" .. role .. "]")
    end)

    if player.Character then
        task.spawn(function()
            local character = player.Character
            local role = "Innocent"
            local color = Colors.Innocent
            
            if character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife") then
                role = "Murderer"
                color = Colors.Murderer
            elseif character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun") then
                role = "Sheriff"
                color = Colors.Sheriff
            end

            createESP(character, color, player.Name .. " [" .. role .. "]")
        end)
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    setupPlayer(p)
end

Players.PlayerAdded:Connect(setupPlayer)

-- Подсветка выпавшего пистолета на карте
Workspace.ChildAdded:Connect(function(child)
    if child.Name == "GunDrop" then
        local text = Drawing.new("Text")
        text.Visible = true
        text.Center = true
        text.Outline = true
        text.Font = 2
        text.Size = 14
        text.Color = Colors.GunDrop
        text.Text = "GUN"

        local conn
        conn = game:GetService("RunService").RenderStepped:Connect(function()
            if not child.Parent then
                text:Remove()
                conn:Disconnect()
                return
            end
            local vector, onScreen = Camera:WorldToViewportPoint(child.Position)
            if onScreen then
                text.Position = Vector2.new(vector.X, vector.Y)
                text.Visible = true
            else
                text.Visible = false
            end
        end)
    end
end)

print("MM2 ESP Loaded!")