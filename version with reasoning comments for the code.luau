-- test game: https://www.roblox.com/games/10326782956/ACS-1-7-but-Edited-Recoil

-- All uncommented code here is supposed to be put inside acs_client

-- ========== SECTION 1: STOCK RECOIL SYSTEM INITIALIZATION ==========

-- Declare variables for stock (buttstock) recoil system
-- StockedCFrame2: Stores the offset CFrame for stock position relative to weapon handle
-- Stocked: Boolean flag indicating if weapon has a detectable stock
local StockedCFrame2, Stocked

-- Put inside function unset (cleanup function)
-- Reset stock variables when weapon is unequipped to prevent memory leaks
StockedCFrame2, Stocked = nil, nil

-- Change spawn to task.spawn in function recoil (Roblox deprecated spawn() in favor of task.spawn())

-- Remove "Recoil:lerp(" and ",1)" in function recoil so it should look something like "Recoil = Recoil*Cframe..."
-- This changes recoil from interpolated to instantaneous application

-- ========== SECTION 2: RECOIL ANCHOR SYSTEM SETUP ==========

-- Create or find a transparent, non-colliding part anchored to the camera to serve as recoil reference
-- This part acts as the base reference point for calculating recoil transformations
local new = game.Workspace.Camera:FindFirstChild("NewRecoil") or Instance.new("Part")
new.CanCollide = false        -- Prevent physics collisions
new.Anchored = true           -- Fixed in place relative to camera
new.Transparency = 1          -- Invisible to player
new.Parent = game.Workspace.Camera
new.Size = Vector3.new(0.1, 0.1, 0.1)  -- Minimal size to avoid visual issues
new.Name = "NewRecoil"

-- Create a second part that will move with recoil transformations
-- This part is unanchored so it can be positioned by the Motor6D
local new2 = game.Workspace.Camera:FindFirstChild("NewRecoil3") or Instance.new("Part")
new2.CanCollide = false
new2.Anchored = false         -- Can move independently
new2.Transparency = 1
new2.Parent = game.Workspace.Camera
new2.Size = Vector3.new(0.1, 0.1, 0.1)
new2.Name = "NewRecoil3"

-- Create or find a Motor6D (rigid constraint) to connect the two recoil parts
-- This motor will apply the recoil transformation between the parts
local new3 = new:FindFirstChildWhichIsA("Motor6D") or Instance.new("Motor6D")
new3.Parent = new
new3.Part0 = new   -- Fixed base part
new3.Part1 = new2  -- Moving part that receives recoil

-- ========== SECTION 3: RECOIL APPLICATION LOGIC ==========

-- Put the code below in function recoil, outside and after task.spawn

-- Position the base recoil part based on whether weapon has a stock
-- If stock exists and has calculated position: use stock-relative position
-- Otherwise: use default position offset from weapon handle
if Stocked and StockedCFrame2 ~= nil then
	-- Apply stock position offset for more realistic recoil pivot
	new.CFrame = ArmaClone.Handle.CFrame * StockedCFrame2
else
	-- Default offset when no stock is detected
	new.CFrame = ArmaClone.Handle.CFrame * CFrame.new(0, 0.0591001511, 0.466899931, 1.00000012, -8.92215013e-08, 0, 8.9592433e-08, 1.00000012, 0, -5.45696821e-12, -9.09494702e-13, 1)
end

-- Get current camera/basepart CFrame for coordinate space conversions
local BPCF = game.Workspace.Camera.BasePart.CFrame

-- Apply recoil transformation through the Motor6D:
-- 1. Convert new.CFrame to object space relative to camera
-- 2. Apply Recoil transformation (CFrame rotation/offset)
-- 3. Set as Motor6D's C1 transform (offset of Part1 relative to Part0)
new3.C1 = BPCF:ToObjectSpace(new.CFrame) * Recoil

-- Update Recoil variable by measuring the new transform from new2 back to camera
-- This creates a feedback loop for cumulative recoil effects
Recoil = new2.CFrame:ToObjectSpace(BPCF)

-- ========== SECTION 4: STOCK DETECTION SYSTEM ==========

-- Put the code below in personagem.childadded after all possible function calls
-- This detects if the weapon has a stock (buttstock) and calculates its position

local StockPart, sizee  -- Variables to store the detected stock part and its half-size

-- Only run stock detection if weapon has a SmokePart (muzzle flash/smoke emitter)
if ArmaClone:FindFirstChild("SmokePart") ~= nil then
	local pos1aa = ArmaClone.SmokePart.Position  -- Muzzle position

	-- Determine reference point: either Trigger position or Handle position
	-- Trigger is preferred as it's closer to where hands grip the weapon
	local pos2aa
	if ArmaClone:FindFirstChild("Trigger") ~= nil and ArmaClone.Trigger:IsA("BasePart") and ArmaClone.Trigger.Transparency ~= 1 then
		pos2aa = ArmaClone.Trigger.Position
	else
		pos2aa = ArmaClone.Handle.Position  -- Fallback to handle
	end

	-- Calculate distance from muzzle to grip reference point
	local pos1topos2 = (pos1aa - pos2aa).magnitude

	local Stock = 0        -- Track farthest distance found
	Stocked = false        -- Reset stock detection flag

	-- Iterate through all BaseParts in the weapon to find potential stock parts
	for _, i in pairs(ArmaClone:GetChildren()) do
		-- Filter criteria for stock parts:
		-- Must be BasePart, not certain excluded parts, and visible (not transparent)
		if i:IsA("BasePart") and i.Name ~= "Mag" and i.Name ~= "Bolt" and i.Name ~= "Slide" 
			and i.Name ~= "Silenciador" and i.Name ~= "Shell" and i.Transparency ~= 1 then

			-- Calculate half of the largest dimension (approximate radius)
			-- There is a bias toward one dimension in the sizes of a gun model’s BaseParts (https://youtube.com/shorts/y3HyMLgaTUY)
			local sizehalf = math.max(i.Size.X, i.Size.Y, i.Size.Z) / 2

			-- Calculate how far this part extends beyond the grip-muzzle line
			-- Positive distance means part extends behind the grip (toward shoulder)
			local Distance = (pos1aa - i.Position).magnitude + sizehalf - pos1topos2

			-- Track the part with the greatest extension behind the grip
			if Distance > Stock then
				Stock = Distance
				StockPart = i   -- Store the candidate stock part
				sizee = sizehalf -- Store its half-size

				-- If extension is significant enough, confirm it's a stock
				-- 1.22 studs threshold (approximately shoulder contact distance)
				-- https://en.wikipedia.org/wiki/Length_of_pull
				if Stock >= 1.22 then
					Stocked = true
				end
			end
		end
	end
end

-- If a stock was detected, calculate its precise position for recoil application
if Stocked then
	-- Temporarily remove camera rotation to calculate in world space
	local rotsave = HeadBase.CFrame.Rotation
	HeadBase.CFrame *= rotsave:Inverse()

	-- Calculate the 6 extreme points of the stock part's bounding box
	-- These are the center points of each face (X+, Y+, Z+, X-, Y-, Z-)
	local p0s1 = Vector3.new(StockPart.Position.X + sizee, StockPart.Position.Y, StockPart.Position.Z)
	local p0s2 = Vector3.new(StockPart.Position.X, StockPart.Position.Y + sizee, StockPart.Position.Z)
	local p0s3 = Vector3.new(StockPart.Position.X, StockPart.Position.Y, StockPart.Position.Z + sizee)
	local p0s4 = Vector3.new(StockPart.Position.X - sizee, StockPart.Position.Y, StockPart.Position.Z)
	local p0s5 = Vector3.new(StockPart.Position.X, StockPart.Position.Y - sizee, StockPart.Position.Z)
	local p0s6 = Vector3.new(StockPart.Position.X, StockPart.Position.Y, StockPart.Position.Z - sizee)

	local pos1aa = ArmaClone.SmokePart.Position  -- Muzzle position

	-- Calculate distance from muzzle to each extreme point
	local pos1 = (p0s1 - pos1aa).magnitude
	local pos2 = (p0s2 - pos1aa).magnitude
	local pos3 = (p0s3 - pos1aa).magnitude
	local pos4 = (p0s4 - pos1aa).magnitude
	local pos5 = (p0s5 - pos1aa).magnitude
	local pos6 = (p0s6 - pos1aa).magnitude

	-- Find which point is farthest from muzzle (most likely contact point with shoulder)
	local farthest = math.max(pos1, pos2, pos3, pos4, pos5, pos6)

	local StockedCFrame

	-- Create CFrame at the farthest extreme point (shoulder contact point)
	if farthest == pos1 then
		StockedCFrame = CFrame.new(p0s1)
	elseif farthest == pos2 then
		StockedCFrame = CFrame.new(p0s2)
	elseif farthest == pos3 then
		StockedCFrame = CFrame.new(p0s3)
	elseif farthest == pos4 then
		StockedCFrame = CFrame.new(p0s4)
	elseif farthest == pos5 then
		StockedCFrame = CFrame.new(p0s5)
	elseif farthest == pos6 then
		StockedCFrame = CFrame.new(p0s6)
	end

	-- Apply the weapon's current orientation to the stock CFrame
	-- This ensures the stock position rotates with the weapon
	local BP = ArmaClone.Handle.Orientation
	StockedCFrame *= CFrame.Angles(math.rad(BP.X), math.rad(BP.Y), math.rad(BP.Z))

	-- Convert to object space relative to weapon handle for easy application
	-- This creates an offset that can be applied regardless of weapon position
	StockedCFrame2 = ArmaClone.Handle.CFrame:ToObjectSpace(StockedCFrame)

	-- Restore the original camera rotation
	HeadBase.CFrame *= rotsave
end
