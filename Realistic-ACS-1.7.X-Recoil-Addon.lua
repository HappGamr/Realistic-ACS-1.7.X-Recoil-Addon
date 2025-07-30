-- test game: https://www.roblox.com/games/10326782956/ACS-1-7-but-Edited-Recoil

-- all uncommented code here is supposed to be put inside acs_client

-- put the code below outside before function unset

local StockedCFrame2,Stocked

-- put inside function unset

StockedCFrame2,Stocked = nil,nil

-- change spawn to task.spawn in function recoil

-- put the code below in function recoil, outside and after task.spawn

local new = Instance.new("Part")
new.CanCollide = false
new.Anchored = true
new.Transparency = 0.5
new.Parent = game.Workspace.Camera
new.Size = Vector3.new(0.1,0.1,0.1)
new.Name = "NewRecoil"

if Stocked and StockedCFrame2 ~= nil then
	new.CFrame = ArmaClone.Handle.CFrame * StockedCFrame2
else
	new.CFrame = ArmaClone.Handle.CFrame * CFrame.new(0, 0.0591001511, 0.466899931, 1.00000012, -8.92215013e-08, 0, 8.9592433e-08, 1.00000012, 0, -5.45696821e-12, -9.09494702e-13, 1)
end

local new2 = Instance.new("Part")
new2.CanCollide = false
new2.Anchored = false
new2.Transparency = 0.5
new2.Parent = game.Workspace.Camera
new2.Size = Vector3.new(0.1,0.1,0.1)
new2.Name = "NewRecoil3"

local new3 = Instance.new("Motor6D")
new3.Parent = new
new3.Part0 = new
new3.Part1 = new2

local BPCF = game.Workspace.Camera.BasePart.CFrame

new3.C1 = BPCF:ToObjectSpace(new.CFrame) * Recoil
Recoil = new2.CFrame:ToObjectSpace(BPCF)

new:Destroy()
new2:Destroy()

-- put the code below in personagem.childadded after all possible function calls

local StockPart,sizee
if ArmaClone:FindFirstChild("SmokePart") ~= nil then
	local pos1aa = ArmaClone.SmokePart.Position
	local pos2aa
	if ArmaClone:FindFirstChild("Trigger") ~= nil and ArmaClone.Trigger:IsA("BasePart") and ArmaClone.Trigger.Transparency ~= 1 then
		pos2aa = ArmaClone.Trigger.Position
	else
		pos2aa = ArmaClone.Handle.Position
	end	
	local pos1topos2 = (pos1aa - pos2aa).magnitude
	local Stock = 0
	Stocked = false
	for _, i in pairs(ArmaClone:GetChildren()) do
		if i:IsA("BasePart") and i.Name ~= "Mag" and i.Name ~= "Bolt" and i.Name ~= "Slide" and i.Name ~= "Silenciador" and i.Name ~= "Shell" and i.Transparency ~= 1 then
			local sizehalf = math.max(i.Size.X,i.Size.Y,i.Size.Z)/2
			local Distance = (pos1aa-i.Position).magnitude+sizehalf-pos1topos2						
			if Distance > Stock then
				Stock = Distance
				StockPart = i
				sizee = sizehalf
				if Stock >= 1.22 then
					Stocked = true
				end
			end
		end
	end
end 

if Stocked then
	local rotsave = HeadBase.CFrame.Rotation
	HeadBase.CFrame *= rotsave:Inverse()
	local p0s1,p0s2,p0s3,p0s4,p0s5,p0s6 = Vector3.new(StockPart.Position.X+sizee,StockPart.Position.Y,StockPart.Position.Z),Vector3.new(StockPart.Position.X,StockPart.Position.Y+sizee,StockPart.Position.Z),Vector3.new(StockPart.Position.X,StockPart.Position.Y,StockPart.Position.Z+sizee),Vector3.new(StockPart.Position.X-sizee,StockPart.Position.Y,StockPart.Position.Z),Vector3.new(StockPart.Position.X,StockPart.Position.Y-sizee,StockPart.Position.Z),Vector3.new(StockPart.Position.X,StockPart.Position.Y,StockPart.Position.Z-sizee)
	local pos1aa = ArmaClone.SmokePart.Position
	local pos1,pos2,pos3,pos4,pos5,pos6 = (p0s1-pos1aa).magnitude,(p0s2-pos1aa).magnitude,(p0s3-pos1aa).magnitude,(p0s4-pos1aa).magnitude,(p0s5-pos1aa).magnitude,(p0s6-pos1aa).magnitude
	local farthest = math.max(pos1,pos2,pos3,pos4,pos5,pos6)

	local StockedCFrame 

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

	local BP = ArmaClone.Handle.Orientation

	StockedCFrame *= CFrame.Angles(math.rad(BP.X),math.rad(BP.Y),math.rad(BP.Z))

	StockedCFrame2 = ArmaClone.Handle.CFrame:ToObjectSpace(StockedCFrame)
	HeadBase.CFrame *= rotsave
end
