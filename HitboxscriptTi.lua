-- GUI Elements
local ScreenGui = Instance.new("ScreenGui")
local main = Instance.new("Frame")
local label = Instance.new("TextLabel")
local toggleButton = Instance.new("TextButton")
local sizeBox = Instance.new("TextBox")
local closeButton = Instance.new("TextButton")


local headSize = 7
local enabled = false
local originalStates = {}

-- Parent GUI to CoreGui
ScreenGui.Name = "HitboxGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")


main.Name = "main"
main.Parent = ScreenGui
main.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
main.Position = UDim2.new(0.4, 0, 0.35, 0)
main.Size = UDim2.new(0, 160, 0, 200)
main.Active = true
main.Draggable = true


label.Name = "label"
label.Parent = main
label.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
label.Size = UDim2.new(1, 0, 0, 25)
label.Font = Enum.Font.SourceSansBold
label.Text = "Hitbox Tool"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextScaled = true
label.TextWrapped = true


toggleButton.Name = "HitboxToggle"
toggleButton.Parent = main
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
toggleButton.Position = UDim2.new(0.1, 0, 0.2, 0)
toggleButton.Size = UDim2.new(0.8, 0, 0, 40)
toggleButton.Font = Enum.Font.SourceSans
toggleButton.Text = "Toggle (F)"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 20


sizeBox.Name = "SizeBox"
sizeBox.Parent = main
sizeBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sizeBox.Position = UDim2.new(0.1, 0, 0.5, 0)
sizeBox.Size = UDim2.new(0.8, 0, 0, 30)
sizeBox.Font = Enum.Font.SourceSans
sizeBox.PlaceholderText = "HeadSize"
sizeBox.Text = tostring(headSize)
sizeBox.TextColor3 = Color3.fromRGB(0, 0, 0)
sizeBox.TextScaled = true


closeButton.Name = "CloseButton"
closeButton.Parent = main
closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeButton.Position = UDim2.new(0.1, 0, 0.8, 0)
closeButton.Size = UDim2.new(0.8, 0, 0, 30)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Text = "CLOSE"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true


sizeBox.FocusLost:Connect(function()
	local newSize = tonumber(sizeBox.Text)
	if newSize then
		headSize = math.clamp(tonumber(string.format("%.2f", newSize)), 0.5, 50)
	else
		sizeBox.Text = tostring(headSize)
	end
end)


local function updateHitboxes()
	for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
		if player ~= game:GetService("Players").LocalPlayer then
			local success, err = pcall(function()
				local char = player.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				if root then
					-- Lưu trạng thái gốc nếu chưa lưu
					if not originalStates[player] then
						originalStates[player] = {
							Size = root.Size,
							Transparency = root.Transparency,
							Color = root.BrickColor,
							Material = root.Material,
							CanCollide = root.CanCollide
						}
					end

					-- Áp dụng hitbox
					root.Size = Vector3.new(headSize, headSize, headSize)
					root.Transparency = 0.7
					root.BrickColor = BrickColor.new("Really black")
					root.Material = Enum.Material.Neon
					root.CanCollide = false
				end
			end)
			if not success then
				warn(err)
			end
		end
	end
end


local function resetHitboxes()
	for player, data in pairs(originalStates) do
		local success, err = pcall(function()
			local char = player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root then
				root.Size = data.Size
				root.Transparency = data.Transparency
				root.BrickColor = data.Color
				root.Material = data.Material
				root.CanCollide = data.CanCollide
			end
		end)
		if not success then
			warn(err)
		end
	end
	originalStates = {} -- Xoá cache
end


local function toggleHitbox()
	enabled = not enabled
	toggleButton.Text = enabled and "ON (F)" or "OFF (F)"
	if not enabled then
		resetHitboxes()
	end
end


toggleButton.MouseButton1Click:Connect(toggleHitbox)


game:GetService("UserInputService").InputBegan:Connect(function(input, isProcessed)
	if not isProcessed and input.KeyCode == Enum.KeyCode.F then
		toggleHitbox()
	end
end)


local runConnection
runConnection = game:GetService("RunService").RenderStepped:Connect(function()
	if enabled then
		updateHitboxes()
	end
end)


closeButton.MouseButton1Click:Connect(function()
	enabled = false
	resetHitboxes()
	if runConnection then runConnection:Disconnect() end
	ScreenGui:Destroy()


	headSize = nil
	originalStates = nil
	toggleHitbox = nil
	resetHitboxes = nil
	updateHitboxes = nil
	runConnection = nil
end)
