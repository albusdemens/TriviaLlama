-- createCubeWithText.server.lua
-- This script updates text when a player jumps over the cube
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Create the cube
local cube = Instance.new("Part")
cube.Size = Vector3.new(4, 4, 4)
cube.Position = Vector3.new(0, 2, 0) -- Positioned near the ground
cube.Anchored = true
cube.BrickColor = BrickColor.new("White")
cube.Material = Enum.Material.SmoothPlastic
cube.CanCollide = true
cube.Name = "OllamaCube"
cube.Parent = workspace

-- Create a SurfaceGui to display text
local surfaceGui = Instance.new("SurfaceGui")
surfaceGui.Name = "TextDisplay"
surfaceGui.Face = Enum.NormalId.Front
surfaceGui.Parent = cube

-- Create the TextLabel
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, 0, 1, 0)
textLabel.BackgroundTransparency = 1
textLabel.TextScaled = true
textLabel.TextWrapped = true
textLabel.TextColor3 = Color3.new(0, 0, 0)
textLabel.Text = "Jump over me for a new fact!"
textLabel.Parent = surfaceGui

-- Create a jump detector part above the cube
local jumpDetector = Instance.new("Part")
jumpDetector.Size = Vector3.new(6, 1, 6) -- Slightly wider than the cube
jumpDetector.Position = Vector3.new(0, 6, 0) -- Positioned above the cube
jumpDetector.Anchored = true
jumpDetector.Transparency = 0.9 -- Almost invisible
jumpDetector.CanCollide = false -- Players can pass through it
jumpDetector.Name = "JumpDetector"
jumpDetector.Parent = workspace

-- Function to fetch text from Ollama bridge
local function fetchOllamaText()
    local success, result
    
    -- Make HTTP request to bridge server
    success, result = pcall(function()
        return HttpService:RequestAsync({
            Url = "http://localhost:3000/generate-text",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode({
                prompt = "Write a short interesting fact in 20 words or less.",
                model = "qwen2:1.5b"
            })
        })
    end)
    
    if success then
        if result.Success then
            -- Request was successful
            local responseData = HttpService:JSONDecode(result.Body)
            if responseData.success == false then
                return "Error: " .. (responseData.text or "Unknown error")
            else
                return responseData.text
            end
        else
            -- HTTP request failed but pcall succeeded
            return "HTTP Error: " .. result.StatusCode .. " - " .. result.StatusMessage
        end
    else
        -- pcall failed (connection error)
        return "Connection Error: " .. tostring(result)
    end
end

-- Update the text (with error handling)
local function updateCubeText()
    local text = "Fetching a new fact..."
    textLabel.Text = text
    
    local success, result = pcall(fetchOllamaText)
    if success then
        text = result
    else
        text = "Error: " .. tostring(result)
    end
    
    print("Ollama response: " .. text)
    
    -- Update the TextLabel
    textLabel.Text = text
end

-- Initial text update when the script runs
updateCubeText()

-- Keep track of players who recently triggered the detector
local playerCooldowns = {}

-- Detect when a player jumps over the cube
jumpDetector.Touched:Connect(function(hit)
    local character = hit.Parent
    local player = Players:GetPlayerFromCharacter(character)
    
    if player then
        local userId = player.UserId
        
        -- Check if player is on cooldown
        if not playerCooldowns[userId] then
            -- Set cooldown for this player
            playerCooldowns[userId] = true
            
            -- Update the cube text
            updateCubeText()
            
            -- Remove cooldown after a few seconds
            spawn(function()
                wait(3) -- 3 second cooldown
                playerCooldowns[userId] = nil
            end)
        end
    end
end)

-- Add a note to output so developers know the script is running
print("Cube is ready! Jump over it to see new facts.")