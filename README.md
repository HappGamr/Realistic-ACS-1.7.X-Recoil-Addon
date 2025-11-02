An add-on for ACS 1.7.X that is designed to make the gun rotate around a certain point instead of HeadBase/BasePart (Camera) when recoil is applied to it.

AI generated readme:

# ACS 1.7 Recoil Edit

[![Roblox](https://img.shields.io/badge/Platform-Roblox-blue.svg)](https://www.roblox.com)
[![Lua](https://img.shields.io/badge/Language-Lua-orange.svg)](https://www.lua.org)
[![Version](https://img.shields.io/badge/ACS_Version-1.7-green.svg)](https://devforum.roblox.com/t/acs-advanced-combat-system-robloxs-1-fps-combat-system/1285741)

## Overview

This repository contains modifications to the [Advanced Combat System (ACS)](https://devforum.roblox.com/t/acs-advanced-combat-system-robloxs-1-fps-combat-system/1285741), a popular open-source FPS gun framework for Roblox. ACS is widely used in Roblox games for creating realistic first-person shooter mechanics, including weapons, recoil, animations, and combat systems. It has been adopted in over 100,000 games and has an active community on Discord and the Roblox Developer Forum.

The specific edits here focus on improving the recoil system in ACS version 1.7. The changes enhance recoil handling for weapons with stocks (e.g., rifles), by dynamically detecting stock parts and adjusting CFrame calculations for more accurate and realistic shoulder-mounted recoil simulation. This prevents unnatural recoil behavior on stocked weapons and improves overall gameplay feel.

These modifications are based on client-side Lua scripts and are intended for integration into the `acs_client` module. They were tested in the Roblox place: [ACS 1.7 but Edited Recoil](https://www.roblox.com/games/10326782956/ACS-1-7-but-Edited-Recoil).

**Key Improvements:**
- Dynamic detection of weapon stocks using part distances and sizes.
- Custom CFrame adjustments for stocked vs. non-stocked weapons.
- Use of temporary parts in the camera workspace for precise recoil interpolation.
- Compatibility with ACS 1.7's existing recoil functions.

**Note:** ACS has evolved with versions like 2.0 (now deprecated in some forks). If you're using a newer version, these edits may require adaptation. Always test in a development place to avoid breaking core functionality.

## Prerequisites

- **Roblox Studio**: Required for editing and testing scripts.
- **ACS 1.7 Framework**: Download from the official ACS resources on the Roblox Developer Forum or community forks. (Search for "ACS 1.7 Roblox" for assets.)
- Basic knowledge of Lua scripting and Roblox's Workspace/CFrame system.
- A test Roblox place for integration (e.g., the linked game above).

## Installation and Usage

These modifications are provided as code snippets with placement instructions. Integrate them into your existing `acs_client` script (typically found in ReplicatedStorage or a similar module in ACS setups).

### Step 1: Locate the `acs_client` Script
- Open your Roblox place in Studio.
- Find the `acs_client` script (client-side module for ACS handling recoil, animations, etc.).

### Step 2: Add Global Variables
Before the `unset` function definition, add these variables:

```lua
local StockedCFrame2, Stocked
```

### Step 3: Modify the `unset` Function
Inside the `unset` function, add this to reset the variables:

```lua
StockedCFrame2, Stocked = nil, nil
```

### Step 4: Update the `recoil` Function
- Replace any `spawn` calls with `task.spawn` for better performance (Roblox's recommended coroutine handling).
- Modify the Recoil assignment line: Remove `"Recoil:lerp("` and `",1)"` so it becomes something like `Recoil = Recoil * CFrame...` (adjust based on your exact ACS version's syntax).
- After the `task.spawn` block (outside and after it), add this code to handle recoil with temporary parts:

```lua
local new = Instance.new("Part")
new.CanCollide = false
new.Anchored = true
new.Transparency = 0.5
new.Parent = game.Workspace.Camera
new.Size = Vector3.new(0.1, 0.1, 0.1)
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
new2.Size = Vector3.new(0.1, 0.1, 0.1)
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
```

This creates temporary debug parts in the camera to calculate and apply recoil offsets, improving precision for stocked weapons.

### Step 5: Modify `personagem.ChildAdded` Event
After all existing function calls in the `personagem.ChildAdded` event handler (where `ArmaClone` is typically processed), add this code to detect and configure stocked weapons:

```lua
local StockPart, sizee
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
            local sizehalf = math.max(i.Size.X, i.Size.Y, i.Size.Z) / 2
            local Distance = (pos1aa - i.Position).magnitude + sizehalf - pos1topos2                        
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
    local p0s1, p0s2, p0s3, p0s4, p0s5, p0s6 = Vector3.new(StockPart.Position.X + sizee, StockPart.Position.Y, StockPart.Position.Z), Vector3.new(StockPart.Position.X, StockPart.Position.Y + sizee, StockPart.Position.Z), Vector3.new(StockPart.Position.X, StockPart.Position.Y, StockPart.Position.Z + sizee), Vector3.new(StockPart.Position.X - sizee, StockPart.Position.Y, StockPart.Position.Z), Vector3.new(StockPart.Position.X, StockPart.Position.Y - sizee, StockPart.Position.Z), Vector3.new(StockPart.Position.X, StockPart.Position.Y, StockPart.Position.Z - sizee)
    local pos1aa = ArmaClone.SmokePart.Position
    local pos1, pos2, pos3, pos4, pos5, pos6 = (p0s1 - pos1aa).magnitude, (p0s2 - pos1aa).magnitude, (p0s3 - pos1aa).magnitude, (p0s4 - pos1aa).magnitude, (p0s5 - pos1aa).magnitude, (p0s6 - pos1aa).magnitude
    local farthest = math.max(pos1, pos2, pos3, pos4, pos5, pos6)

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

    StockedCFrame *= CFrame.Angles(math.rad(BP.X), math.rad(BP.Y), math.rad(BP.Z))

    StockedCFrame2 = ArmaClone.Handle.CFrame:ToObjectSpace(StockedCFrame)
    HeadBase.CFrame *= rotsave
end
```

This logic scans the weapon model for the farthest qualifying part (simulating a stock) and computes a relative CFrame for recoil anchoring.

### Step 6: Testing
- Publish your place or test in Studio.
- Equip a stocked weapon (e.g., a rifle) and fire to observe improved recoil.
- For non-stocked weapons (e.g., pistols), fallback CFrame is used.
- Debug with print statements if needed, and adjust the stock detection threshold (`1.22`) for your models.

## Potential Issues and Fixes
- **CFrame Precision**: Floating-point values may vary slightly; test on multiple devices.
- **Performance**: Temporary parts are destroyed immediately, but high fire rates could cause minor lag—optimize if needed.
- **Compatibility**: If using ACS 2.0 or forks (e.g., edited versions from DevForum), verify variable names like `ArmaClone`, `HeadBase`, etc.
- **Roblox Updates**: CFrame and Instance changes in Roblox could break this; monitor DevForum for patches.

## Contributing
Feel free to fork this repo and submit pull requests for improvements, such as support for newer ACS versions or additional weapon types.

## Resources
- [Official ACS DevForum Thread](https://devforum.roblox.com/t/acs-advanced-combat-system-robloxs-1-fps-combat-system/1285741)
- [ACS Community Discord](https://discord.com/invite/advanced-combat-system-community-827005719454810173)
- [Test Game](https://www.roblox.com/games/10326782956/ACS-1-7-but-Edited-Recoil)
- Related Tutorials: Search YouTube for "How to Add ACS Guns in Roblox Studio"

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. (Note: ACS itself is open-source; respect original creators' terms.)
