An add-on for ACS 1.7.X that is designed to make the gun rotate around a certain point instead of HeadBase/BasePart (Camera) when recoil is applied to it.

AI generated readme:

# Custom-Pivot-Recoil-for-ACS-1.7.X

An add-on for ACS 1.7.X that enhances the recoil system in Roblox games by making recoil rotations more realistic. Instead of rotating around the default HeadBase/BasePart (camera), this addon dynamically detects weapon stocks (e.g., on rifles) and anchors recoil to a computed point on the stock for shouldered firing. For non-stocked weapons (e.g., pistols), it falls back to a predefined offset. This improves immersion and gameplay feel in FPS experiences built with ACS.

Tested in: [ACS 1.7 but Edited Recoil](https://www.roblox.com/games/10326782956/ACS-1-7-but-Edited-Recoil)

## Overview

ACS (Advanced Combat System) is a popular open-source FPS gun framework for Roblox, used in thousands of games for handling weapons, animations, and combat mechanics. This addon specifically targets the recoil functions in ACS version 1.7.X to provide more physically accurate behavior:

- **Dynamic Stock Detection**: Scans the weapon model for potential stock parts based on distance thresholds from the muzzle (SmokePart) to visible BaseParts, excluding magazines, bolts, etc.
- **Custom Recoil Pivot**: Uses reusable temporary parts in the Workspace.Camera to calculate and apply recoil CFrames relative to the stock point or a default offset.
- **Performance Optimizations**: Reuses parts instead of creating/destroying them per recoil event, replaces deprecated `spawn` with `task.spawn`, and removes unnecessary lerp calls for direct CFrame multiplication.
- **Compatibility**: Designed for ACS 1.7.X client-side scripts. May require minor adaptations for ACS 2.0 or community forks, as ACS has evolved and been deprecated in some versions.

This addon assumes you're familiar with Roblox scripting and ACS's structure. It modifies the `acs_client` script (typically found in ReplicatedStorage or a weapon module).

## Prerequisites

- Roblox Studio installed.
- ACS 1.7.X framework (available from the [Roblox Developer Forum ACS thread](https://devforum.roblox.com/t/acs-advanced-combat-system-robloxs-1-fps-combat-system/1285741) or community forks).
- Basic knowledge of Lua, Roblox Workspace, CFrames, and event handling.
- A test Roblox place with ACS integrated (e.g., the linked test game).

## Installation and Usage

Integrate these modifications into your `acs_client` script. All changes are client-side for recoil handling. Backup your original script before editing.

### Step 1: Locate the `acs_client` Script
Open your Roblox place in Studio. Find the `acs_client` script responsible for weapon handling, recoil, and character events (often in ReplicatedStorage or a LocalScript).

### Step 2: Add Global Variables
Place this before the `unset` function definition:

```lua
local StockedCFrame2, Stocked
```

### Step 3: Modify the `unset` Function
Inside the `unset` function, add this to reset the variables:

```lua
StockedCFrame2, Stocked = nil, nil
```

### Step 4: Create Reusable Recoil Parts
Place this outside and before the `recoil` function definition. These parts are created once (if not found) and reused for efficiency:

```lua
local new = game.Workspace.Camera:FindFirstChild("NewRecoil") or Instance.new("Part")
new.CanCollide = false
new.Anchored = true
new.Transparency = 1
new.Parent = game.Workspace.Camera
new.Size = Vector3.new(0.1, 0.1, 0.1)
new.Name = "NewRecoil"

local new2 = game.Workspace.Camera:FindFirstChild("NewRecoil3") or Instance.new("Part")
new2.CanCollide = false
new2.Anchored = false
new2.Transparency = 1
new2.Parent = game.Workspace.Camera
new2.Size = Vector3.new(0.1, 0.1, 0.1)
new2.Name = "NewRecoil3"

local new3 = new:FindFirstChildWhichIsA("Motor6D") or Instance.new("Motor6D")
new3.Parent = new
new3.Part0 = new
new3.Part1 = new2
```

### Step 5: Update the `recoil` Function
- Replace all `spawn` calls with `task.spawn` for better threading performance.
- Remove `"Recoil:lerp("` and `",1)"` from the Recoil assignment line, so it becomes something like `Recoil = Recoil * CFrame...` (adjust based on your exact ACS version).
- After the `task.spawn` block (outside it), add this to apply the custom recoil pivot:

```lua
if Stocked and StockedCFrame2 ~= nil then
    new.CFrame = ArmaClone.Handle.CFrame * StockedCFrame2
else
    new.CFrame = ArmaClone.Handle.CFrame * CFrame.new(0, 0.0591001511, 0.466899931, 1.00000012, -8.92215013e-08, 0, 8.9592433e-08, 1.00000012, 0, -5.45696821e-12, -9.09494702e-13, 1)
end

local BPCF = game.Workspace.Camera.BasePart.CFrame
new3.C1 = BPCF:ToObjectSpace(new.CFrame) * Recoil
Recoil = new2.CFrame:ToObjectSpace(BPCF)
```

### Step 6: Modify the `personagem.ChildAdded` Event
In the `personagem.ChildAdded` event handler (where `ArmaClone` is processed), add this after all existing function calls. This detects if the weapon is stocked and computes the relative CFrame:

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

### Step 7: Testing
- Publish your place or test in Studio.
- Equip a weapon (stocked like a rifle or non-stocked like a pistol).
- Fire and observe the recoil: It should pivot from the stock point for realism on rifles, reducing unnatural camera jolts.
- Adjust the stock detection threshold (`1.22`) if needed for your weapon models.
- Monitor performance in high-fire-rate scenarios; the reusable parts should minimize lag compared to creating/destroying instances.

## Potential Issues and Fixes

- **CFrame Precision**: Test on different devices/resolutions, as floating-point errors in CFrames can cause minor misalignments.
- **Performance**: If lag occurs with rapid fire, ensure `task.spawn` is used correctly. The reusable parts avoid instance overhead.
- **Compatibility**: Variable names like `ArmaClone`, `HeadBase`, `SmokePart` must match your ACS setup. For ACS 2.0+, adapt event handlers and recoil logic.
- **Roblox Updates**: Engine changes (e.g., to Workspace or CFrame handling) may require tweaks. Check the Roblox Developer Forum for ACS updates.
- **Invisible Parts**: The parts have `Transparency = 1` for production; set to `0.5` during debugging to visualize them.

## Contributing

Fork this repository and submit pull requests for improvements, such as:
- Support for newer ACS versions.
- Enhanced stock detection for custom weapon models.
- Additional recoil customization options.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. Respect the terms of the original ACS framework.
