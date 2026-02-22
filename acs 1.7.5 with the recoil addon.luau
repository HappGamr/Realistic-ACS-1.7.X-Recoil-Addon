repeat
	wait()
until game.Players.LocalPlayer.Character

local Jogador = game.Players.LocalPlayer
local Personagem = Jogador.Character
local CurCamera = workspace.CurrentCamera
local PegarMouse = Jogador:GetMouse()

local Balinha
local Correndo
local ArmaClient
local ArmaClone
local Offset

local Engine = game.ReplicatedStorage:WaitForChild("ACS_Engine")
local Evt = Engine:WaitForChild("Eventos")
local Mod = Engine:WaitForChild("Modulos")
local PastaHUD = Engine:WaitForChild("HUD")
local PastaFX = Engine:WaitForChild("FX")
local GunMods = Engine:WaitForChild("GunMods")
local GunModels = Engine:WaitForChild("GunModels")
local GunModelClient = GunModels:WaitForChild("Client")
local GunModelServer = GunModels:WaitForChild("Server")
local Ultil = require(Mod:WaitForChild("Utilities"))
local SetupMod = require(Mod:WaitForChild("SetupModule"))
local Hitmarker = require(Mod:WaitForChild("Hitmarker"))
local SpringMod = require(Mod:WaitForChild("Spring"))
local ServerConfig = require(Engine.ServerConfigs:WaitForChild("Config"))
local ACS_Storage = workspace:WaitForChild("ACS_WorkSpace")

local ACS
local Var
local Prog
local Settings
local Anims

local Player = game.Players.LocalPlayer
local Character = Player.Character
local Human = Character:WaitForChild("Humanoid")
local Mouse = Player:GetMouse()
local uis = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local ToolEquip = false
local Equipped = false
local Nadando = false
local Saude = Character:WaitForChild("Saude")
local Sprinting = Saude.Stances:WaitForChild("Correndo")

local Recoil = CFrame.new()
local VRecoil,HRecoil,VPunchBase,HPunchBase,DPunchBase,RecoilPower,BSpread
local Ammo,StoredAmmo,GLAmmo
local FireRate,BurstFireRate
local Chambered,GLChambered,ModoTreino,Emperrado
local Sens,Zeroing

local DecreasedAimLastShot = false
local LastSpreadUpdate = time()

local Gui, CanUpdateGui = nil, true

local AimPartMode = 1
local SpeedPrecision = 0

local falling = false
local OverHeat = false 
local slideback = false
local Can_Shoot = true
local Safe = false
local AnimDebounce = false
local CancelReload = false
local MouseHeld

local PlaceHolder = true

local ModStorageFolder = Player.PlayerGui:FindFirstChild('ModStorage') or Instance.new('Folder')
ModStorageFolder.Parent = Player.PlayerGui
ModStorageFolder.Name = 'ModStorage'


local Aiming = false
local Reloading = false
local stance = 0

local NVG = false
local Bipod = false
local CanPlaceBipod = false
local BipodEnabled = false
local Silencer
local LanternaAtiva = false
local LaserAtivo = false
local IRmode = false
local Laser
local Pointer
local LaserSP
local LaserEP
local LaserDist = 999
local LanternaBeam
local LanternaSP
local LanternaEP

local Left_Weld, Right_Weld,RA,LA,RightS,LeftS,HeadBase,HeadBaseW,HW,HW2,Grip_Weld,GripNode
local AnimBase,AnimBaseW,NeckW,FakeArms,Folder,Arma,Clone

--// Gun Parts

local SFn

local ABS, HUGE, FLOOR, CEIL = math.abs, math.huge, math.floor, math.ceil
local RAD, SIN, COS, TAN = math.rad, math.sin, math.cos, math.tan
local VEC2, V3 = Vector2.new, Vector3.new
local CF, CFANG = CFrame.new, CFrame.Angles
local INSERT = table.insert


local Walking = false

local instance = Instance.new
local CFn = CFrame.new
local CFa = CFrame.Angles
local asin = math.asin
local abs = math.abs
local min = math.min
local max = math.max
local random = math.random

local OldTick = tick()
local t = 0
local Reconum = SpringMod.new(V3())
local sway = SpringMod.new(V3())
local Walk = SpringMod.new(V3())
local WalkRate = 1
local speed = 10
local damper = 1


Walk.s = speed
Walk.d = damper
Reconum.s = speed
Reconum.d = 0.15
sway.s = speed
sway.d = damper
local WVal = 0.25
local Waval = CFn()
local TS = game:GetService('TweenService')
local RS = game:GetService("RunService")

--// Char Parts
local Humanoid = Personagem:WaitForChild('Humanoid')
local Head = Personagem:WaitForChild('Head')
local Torso = Personagem:WaitForChild('Torso')
local HumanoidRootPart = Personagem:WaitForChild('HumanoidRootPart')
local RootJoint = HumanoidRootPart:WaitForChild('RootJoint')
local Neck = Torso:WaitForChild('Neck')
local Right_Shoulder = Torso:WaitForChild('Right Shoulder')
local Left_Shoulder = Torso:WaitForChild('Left Shoulder')
local Right_Hip = Torso:WaitForChild('Right Hip')
local Left_Hip = Torso:WaitForChild('Left Hip')

local Connections = {}

local Debris = game:GetService("Debris")

local Ignore_Model = ACS_Storage:FindFirstChild("Server")

local BulletModel = ACS_Storage:FindFirstChild("Client")

local IgnoreList = {"Ignorable","Glass"}

local Ray_Ignore = {Character, Ignore_Model, Camera, BulletModel, IgnoreList}


Camera.CameraType = Enum.CameraType.Custom
Camera.CameraSubject = Humanoid

----------------------------------------------------------------------------------------------
--------------------------------[PROGRAMA]----------------------------------------------------
----------------------------------------------------------------------------------------------

	HeadBase = Instance.new('Part')
	HeadBase.Name = 'BasePart'
	HeadBase.Parent = Camera
	HeadBase.Anchored = true
	HeadBase.CanCollide = false
	HeadBase.Transparency = 1
	HeadBase.Size = Vector3.new(0.1, 0.1, 0.1)

	HeadBaseAtt = Instance.new('Attachment')
	HeadBaseAtt.Parent = HeadBase
	


	local StatusUI = PastaHUD:WaitForChild("StatusUI")
	local StatusClone = StatusUI:Clone()
	StatusClone.Parent = Jogador.PlayerGui
	
	if ServerConfig.EnableHunger then
		StatusClone.FomeSede.Disabled = false
	end

if ServerConfig.EnableGPS then
	local StatusUI = PastaHUD:WaitForChild("GPShud")
	local StatusClone = StatusUI:Clone()
	StatusClone.Parent = Jogador.PlayerGui
	StatusClone.GPS.Disabled = false
end

function ResetWorkspace()
	Ignore_Model:ClearAllChildren()
	BulletModel:ClearAllChildren()
	workspace.Terrain:ClearAllChildren()
end

ResetWorkspace()

Evt.Hit.OnClientEvent:Connect(function(Player,Position, HitPart, Normal, Material,Settings)
	if Player ~= Jogador then 
		Hitmarker.HitEffect(Ray_Ignore,ACS_Storage,Position, HitPart, Normal, Material,Settings)
	end
end)

Evt.HeadRot.OnClientEvent:Connect(function(Player, Rotacao, Offset, Equipado)
	if Player ~= Jogador and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") ~= nil then
		local HRPCF =  Player.Character["HumanoidRootPart"].CFrame * CFrame.new(0, 1.5, 0) * CFrame.new(Offset)
		Player.Character.Torso:WaitForChild("Neck").C0 =  Player.Character.Torso.CFrame:toObjectSpace(HRPCF)
		Player.Character.Torso:WaitForChild("Neck").C1 =  CFrame.Angles(Rotacao, 0, 0)
	end
end)

Evt.Atirar.OnClientEvent:Connect(function(Player,FireRate,Anims,Arma)

if Player ~= Jogador then 

	if Player.Character:FindFirstChild('S' .. Arma.Name) ~= nil and Player.Character['S' .. Arma.Name].Grip:FindFirstChild("Muzzle") ~= nil then
		local Muzzle = Player.Character['S' .. Arma.Name].Grip:FindFirstChild("Muzzle")
		
		if  Player.Character['S' .. Arma.Name]:FindFirstChild("Silenciador") ~= nil and Player.Character['S' .. Arma.Name].Silenciador.Transparency == 0 then
				Muzzle:FindFirstChild("FlashFX").Brightness = 0
				Muzzle:FindFirstChild("FlashFX[Flash]").Rate = 0
			else
				Muzzle:FindFirstChild("FlashFX").Brightness = 5
				Muzzle:FindFirstChild("FlashFX[Flash]").Rate = 1000
			end


		for _, v in pairs(Muzzle:GetChildren()) do
				if v.Name:sub(1, 7) == "FlashFX" or v.Name:sub(1, 7) == "Smoke" then
					v.Enabled = true
					end
				end

		delay(1 / 30, function()

			for _, v in pairs(Muzzle:GetChildren()) do
				if v.Name:sub(1, 7) == "FlashFX" or v.Name:sub(1, 7) == "Smoke" then
					v.Enabled = false
				end
			end
		end)		

	end
 	if  Player.Character:FindFirstChild("AnimBase") ~= nil and Player.Character.AnimBase:FindFirstChild("AnimBaseW") then
		local AnimBase = Player.Character:WaitForChild("AnimBase"):WaitForChild("AnimBaseW")

		TS:Create(AnimBase, TweenInfo.new(FireRate), {C1 = Anims.ShootPos} ):Play()
		wait(FireRate*2)
		TS:Create(AnimBase, TweenInfo.new(.2), {C1 = CFrame.new()} ):Play()
	end
end
end)

function Setup(Tools)
	
	local Torso = Character:FindFirstChild('Torso')
	local Head = Character:FindFirstChild('Head')
	local HumanoidRootPart = Character:FindFirstChild('HumanoidRootPart')

	ArmaClient = Tools
	ArmaClone = GunModelClient:WaitForChild(ArmaClient.Name):Clone()
	Var = Tools.ACS_Modulo.Variaveis
	Settings = require(Var:WaitForChild("Settings"))
	Anims = require(Var:WaitForChild("Animations"))
	
	 VRecoil = math.random(Settings.VRecoil[1],Settings.VRecoil[2])/1000
	 HRecoil = math.random(Settings.HRecoil[1],Settings.HRecoil[2])/1000
	 VPunchBase = (Settings.VPunchBase)
	 HPunchBase = (Settings.HPunchBase)
	 DPunchBase = (Settings.DPunchBase)
	 RecoilPower = Settings.MinRecoilPower
	 BSpread = Settings.MinSpread

	 Silencer = Var.Suppressor
	 Ammo, StoredAmmo, GLAmmo = Var.Ammo, Var.StoredAmmo, Var.LauncherAmmo
	 Chambered,Emperrado,GLChambered = Var.Chambered, Var.Emperrado, Var.GLChambered
	 FireRate = 1/(Settings.FireRate/60)
	 BurstFireRate = 1/(Settings.BurstFireRate/60)

	 ModoTreino = Settings.ModoTreino

	 Sens = Var.Sens
	 Zeroing = Var.Zeroing


	Evt.Equipar:FireServer(ArmaClient,Settings)

 	Folder = Instance.new("Model", Camera)
	Folder.Name = Tools.Name

	AnimBase = Instance.new("Part", Folder)
	AnimBase.FormFactor = "Custom"
	AnimBase.CanCollide = false
	AnimBase.Transparency = 1
	AnimBase.Anchored = true
	AnimBase.Name = "AnimBase"
	AnimBase.Size = Vector3.new(0.1, 0.1, 0.1)
	
	AnimBaseW = Instance.new("Motor6D")
	AnimBaseW.Part0 = AnimBase
	AnimBaseW.Part1 = HeadBase
	AnimBaseW.Parent = AnimBase
	AnimBaseW.Name = "AnimBaseW"
	AnimBase.Anchored = false

	Clone = Instance.new('Motor6D')
	Clone.Name = 'Clone'
	Clone.Parent = AnimBase
	Clone.Part0 = AnimBase
	Clone.Part1 = HeadBase


	ArmaClone.Parent = Folder


	for L_209_forvar1, L_210_forvar2 in pairs(ArmaClone:GetChildren()) do
		if L_210_forvar2:IsA('BasePart') and L_210_forvar2.Name ~= 'Handle' then
			if L_210_forvar2.Name ~= "Bolt" and L_210_forvar2.Name ~= 'Lid' then
				Ultil.Weld(L_210_forvar2, ArmaClone:WaitForChild("Handle"))
			end
			
			if L_210_forvar2.Name == "Bolt" or L_210_forvar2.Name == "Slide" then
				Ultil.WeldComplex(ArmaClone:WaitForChild("Handle"), L_210_forvar2, L_210_forvar2.Name)
			end;
			
			if L_210_forvar2.Name == "Lid" then
				if ArmaClone:FindFirstChild('LidHinge') then
					Ultil.Weld(L_210_forvar2, ArmaClone:WaitForChild("LidHinge"))
				else
					Ultil.Weld(L_210_forvar2, ArmaClone:WaitForChild("Handle"))
				end
			end
		end
	end;

	for L_213_forvar1, L_214_forvar2 in pairs(ArmaClone:GetChildren()) do
		if L_214_forvar2:IsA('BasePart') and L_214_forvar2.Name ~= 'Grip' then
			L_214_forvar2.Anchored = false
			L_214_forvar2.CanCollide = false
		end
	end;
	--LoadClientMods()
	RA, LA, Right_Weld, Left_Weld, AnimBase, AnimBaseW = SetupMod(Folder, Ultil, Character, RA, LA, Right_Weld, Left_Weld, AnimBase, AnimBaseW, Settings, ArmaClone)
	Equipped = true
	if ArmaClone:FindFirstChild('Silenciador')~= nil then
		if Silencer.Value == true then
			ArmaClone.Silenciador.Transparency = 0
			ArmaClone.SmokePart.FlashFX.Brightness = 0
			ArmaClone.SmokePart:FindFirstChild("FlashFX[Flash]").Rate = 0
			Evt.SilencerEquip:FireServer(ArmaClient,Silencer.Value)
		else
			ArmaClone.Silenciador.Transparency = 1
			ArmaClone.SmokePart.FlashFX.Brightness = 5
			ArmaClone.SmokePart:FindFirstChild("FlashFX[Flash]").Rate = 1000
			Evt.SilencerEquip:FireServer(ArmaClient,Silencer.Value)
		end
	end
end

local StockedCFrame2,Stocked

function Unset()
	
	StockedCFrame2,Stocked = nil,nil
	
	if ArmaClient then
	Evt.Desequipar:FireServer(ArmaClient,Settings)
	end
	UnloadClientMods()
	
	if Folder then
		Folder:Destroy()
	end
	Equipped = false
	Aiming = false
	Safe = false
	Bipod = false
	LanternaAtiva = false
	IRmode = false
	LaserAtivo = false
	--Silencer = false
	CancelReload = false
	Reloading = false
	slideback = false
	OverHeat = false
	uis.MouseIconEnabled = true
	game:GetService('UserInputService').MouseDeltaSensitivity = 1
	Camera.CameraType = Enum.CameraType.Custom
	Player.CameraMode = Enum.CameraMode.Classic
	AimPartMode = 1
	stance = 0
	tweenFoV(70,15)
	TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.3),{ImageTransparency = 1}):Play()
	Evt.SVLaser:FireServer(Vector3.new(0,0,0),2,nil,ArmaClient,IRmode)
	if Gui then
		Gui.Visible = false
	end

	for _,c in pairs(Connections) do
			c:disconnect()
		end
		Connections = {}
		Walking = false
		a = false
		d = false
end

function Update_Gui()
	if CanUpdateGui then
				
		if ArmaClone:FindFirstChild("BipodPoint") ~= nil then
			Gui.Bipod.Visible = true
		else
			Gui.Bipod.Visible = false
		end

		if Settings.ArcadeMode == true then
			Gui.Ammo.Visible = true
			Gui.Ammo.AText.Text = Ammo.Value.."|"..Settings.Ammo
		else
			Gui.Ammo.Visible = false
		end

		if Settings.FireModes.Explosive == true and GLChambered.Value == true then
			Gui.E.ImageColor3 = Color3.fromRGB(255,255,255)
			Gui.E.Visible = true
		elseif Settings.FireModes.Explosive == true and GLChambered.Value == false then
			Gui.E.ImageColor3 = Color3.fromRGB(255,0,0)
			Gui.E.Visible = true
		elseif Settings.FireModes.Explosive == false then
			Gui.E.Visible = false
		end

		if Safe == true then
			Gui.A.Visible = true
		else
			Gui.A.Visible = false
		end

		if Chambered.Value == true and Ammo.Value > 0 and Emperrado.Value == false then
			Gui.B.Visible = true
			Gui.B.BackgroundColor3 = Color3.fromRGB(255,255,255)
		elseif Chambered.Value == true and Ammo.Value > 0 and Emperrado.Value == true then
			Gui.B.Visible = true
			Gui.B.BackgroundColor3 = Color3.fromRGB(255,0,0)
		else
			Gui.B.Visible = false
		end
		Gui.FText.Text = Settings.Mode
		
		if Settings.Mode ~= "Explosive" then
			Gui.BText.Text = Settings.BulletType
		else
			Gui.BText.Text = "HEDP"
		end
		Gui.Sens.Text = (Sens.Value/100)
		Gui.ZeText.Text = Zeroing.Value .." m"
		Gui.NText.Text = Settings.Name

		if Settings.Mode ~= "Explosive" then
			if Settings.MagCount then
				Gui.SAText.Text = math.ceil(StoredAmmo.Value/Settings.Ammo)
			else
				Gui.SAText.Text = StoredAmmo.Value
			end
		else
			Gui.SAText.Text =  GLAmmo.Value
		end

		if Silencer.Value == true then
			Gui.Silencer.Visible = true
		else
			Gui.Silencer.Visible = false
		end

		if LaserAtivo == true then
			Gui.Laser.Visible = true
			if IRmode then
				Gui.Laser.ImageColor3 = Color3.new(0,255,0)
			else
				Gui.Laser.ImageColor3 = Color3.new(255,255,255)
			end
		else
			Gui.Laser.Visible = false
		end

		if LanternaAtiva == true then
			Gui.Flash.Visible = true
		else
			Gui.Flash.Visible = false
		end

	end
end

function CheckMagFunction()
	if CanUpdateGui then
		Gui.CMText.TextTransparency = 0
		Gui.CMText.TextStrokeTransparency = 0.9
		if Ammo.Value >= Settings.Ammo then
			Gui.CMText.Text = "Full"
		elseif Ammo.Value > math.floor((Settings.Ammo)*.75) and Ammo.Value < Settings.Ammo then
			Gui.CMText.Text = "Nearly full"
		elseif Ammo.Value < math.floor((Settings.Ammo)*.75) and Ammo.Value > math.floor((Settings.Ammo)*.5) then
			Gui.CMText.Text = "Almost half"
		elseif Ammo.Value == math.floor((Settings.Ammo)*.5) then
			Gui.CMText.Text = "Half"
		elseif Ammo.Value > math.ceil((Settings.Ammo)*.25) and Ammo.Value <  math.floor((Settings.Ammo)*.5) then
			Gui.CMText.Text = "Less than half"
		elseif Ammo.Value < math.ceil((Settings.Ammo)*.25) and Ammo.Value > 0 then
			Gui.CMText.Text = "Almost empty"
		elseif Ammo.Value == 0 then
			Gui.CMText.Text = "Empty"
		end
		TS:Create(Gui.CMText,TweenInfo.new(10),{TextTransparency = 1,TextStrokeTransparency = 1}):Play()
	end
end

function Sprint()
if Equipped then
	if Correndo and SpeedPrecision > 0 then
		MouseHeld = false
		if Aiming then
			game:GetService('UserInputService').MouseDeltaSensitivity = 1
			ArmaClone.Handle.AimUp:Play()	
			tweenFoV(70,120)
			Aiming = false
			TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.3),{ImageTransparency = 1}):Play()
		end
		if not Safe and not AnimDebounce then
		stance = 3
		Evt.Stance:FireServer(stance,Settings,Anims)
		SprintAnim()
		end
	elseif not Correndo or SpeedPrecision == 0 then
		if not Safe and not AnimDebounce then
		if Aiming then
		stance = 2
		Evt.Stance:FireServer(stance,Settings,Anims)
		IdleAnim()
		else
		stance = 0
		Evt.Stance:FireServer(stance,Settings,Anims)
		IdleAnim()
		end
		end
	end
end
end

Sprinting.Changed:connect(function(Valor)
	Correndo = Valor
	Sprint()
end)

--Ammo.Changed:connect(Update_Gui)
--StoredAmmo.Changed:connect(Update_Gui)
--GLAmmo.Changed:connect(Update_Gui)

local RAD, SIN, ATAN, COS = math.rad, math.sin, math.atan2, math.cos

--------------------[ MATH FUNCTIONS ]------------------------------------------------

function RAND(Min, Max, Accuracy)
	local Inverse = 1 / (Accuracy or 1)
	return (math.random(Min * Inverse, Max * Inverse) / Inverse)
end

---------------------[ TWEEN MODULE ]-------------------------------------------------


function tweenFoV(goal, frames)
 coroutine.resume(coroutine.create(function()
  SFn = SFn and SFn + 1 or 0 
  local SFn_S = SFn
  for i = 1, frames do
   if SFn ~= SFn_S then break end
  		 Camera.FieldOfView = Camera.FieldOfView + (goal - Camera.FieldOfView) * (i / frames)
   game:GetService("RunService").RenderStepped:wait()
  end
 end))
end

function Lerp(n,g,t)
	return n+(g-n)*t
end

local RS = game:GetService("RunService")

function tweenJoint(Joint, newC0, newC1, Alpha, Duration)
	spawn(function()
		local newCode = math.random(-1e9, 1e9) --This creates a random code between -1000000000 and 1000000000
		local tweenIndicator = nil
		if (not Joint:findFirstChild("tweenCode")) then --If the joint isn't being tweened, then
			tweenIndicator = Instance.new("IntValue")
			tweenIndicator.Name = "tweenCode"
			tweenIndicator.Value = newCode
			tweenIndicator.Parent = Joint
		else
			tweenIndicator = Joint.tweenCode
			tweenIndicator.Value = newCode --If the joint is already being tweened, this will change the code, and the tween loop will stop
		end
		--local tweenIndicator = createTweenIndicator:InvokeServer(Joint, newCode)
		if Duration <= 0 then --If the duration is less than or equal to 0 then there's no need for a tweening loop
			if newC0 then Joint.C0 = newC0 end
			if newC1 then Joint.C1 = newC1 end
		else
			local Increment = 1.5 / Duration
			local startC0 = Joint.C0
			local startC1 = Joint.C1
			local X = 0
			while true do
				RS.RenderStepped:wait() --This makes the for loop step every 1/60th of a second
				local newX = X + Increment
				X = (newX > 90 and 90 or newX)
				if tweenIndicator.Value ~= newCode then break end --This makes sure that another tween wasn't called on the same joint
				if (not Equipped) then break end --This stops the tween if the tool is deselected
				if newC0 then Joint.C0 = startC0:lerp(newC0, Alpha(X)) end
				if newC1 then Joint.C1 = startC1:lerp(newC1, Alpha(X)) end
				if X == 90 then break end
			end
		end
		if tweenIndicator.Value == newCode then --If this tween functions was the last one called on a joint then it will remove the code
			tweenIndicator:Destroy()
		end
	end)
end


function LoadClientMods()
	for L_335_forvar1, L_336_forvar2 in pairs(GunMods:GetChildren()) do
		if L_336_forvar2:IsA('LocalScript') then
			local L_337_ = L_336_forvar2:clone()
			L_337_.Parent = ModStorageFolder
			L_337_.Disabled = false
		end
	end
end

function UnloadClientMods()
	for L_335_forvar1, L_336_forvar2 in pairs(ModStorageFolder:GetChildren()) do
		if L_336_forvar2:IsA('LocalScript') then
			L_336_forvar2:Destroy()
		end
	end
end

function CheckForHumanoid(L_225_arg1)
	local L_226_ = false
	local L_227_ = nil
	if L_225_arg1 then
		if (L_225_arg1.Parent:FindFirstChildOfClass("Humanoid") or L_225_arg1.Parent.Parent:FindFirstChildOfClass("Humanoid")) then
			L_226_ = true
			if L_225_arg1.Parent:FindFirstChildOfClass('Humanoid') then
				L_227_ = L_225_arg1.Parent:FindFirstChildOfClass('Humanoid')
			elseif L_225_arg1.Parent.Parent:FindFirstChildOfClass('Humanoid') then
				L_227_ = L_225_arg1.Parent.Parent:FindFirstChildOfClass('Humanoid')
			end
		else
			L_226_ = false
		end	
	end
	return L_226_, L_227_
end

function CreateShell()
	delay(math.random(4,8)/10, function()
		if PastaFX:FindFirstChild('ShellCasing') then
			local Som = PastaFX.ShellCasing:clone()
			Som.Parent = Jogador.PlayerGui
			Som.PlaybackSpeed = math.random(30,50)/40
			Som.PlayOnRemove = true
			Debris:AddItem(Som, 0)
		end
	end)
end

local Tracers = 1
function TracerCalculation()
	local VisibleTracer
	if Settings.RandomTracer then
	if (math.random(1, 100) <= Settings.TracerChance) then	
		VisibleTracer = true
	else
		VisibleTracer = false
	end
	else
		if Tracers >= Settings.TracerEveryXShots then
			VisibleTracer = true
			Tracers = 1
		else
			Tracers = Tracers + 1
		end
	end
	return VisibleTracer
end

function CreateBullet(BSpread)

	local Bullet = Instance.new("Part")
	Bullet.Name = Player.Name.."_Bullet"
	Bullet.CanCollide = false
	Bullet.Transparency = 1
	Bullet.FormFactor = "Custom"
	Bullet.Size = Vector3.new(1,1,1)
	local BulletMass = Bullet:GetMass()
	local Force = Vector3.new(0,BulletMass * (196.2) - (Settings.BDrop) * (196.2), 0)
	local BF = Instance.new("BodyForce")
	BF.force = Force
	BF.Parent = Bullet
	local Origin = ArmaClone.SmokePart.Position
	local Direction = ArmaClone.SmokePart.CFrame.lookVector + (ArmaClone.SmokePart.CFrame.upVector * (((Settings.BDrop*Zeroing.Value/2.8)/Settings.BSpeed))/2)
	local BulletCF = CFrame.new(Origin, Origin + Direction)
	local balaspread = CFrame.Angles(
			RAD(RAND(-BSpread - ((SpeedPrecision/Saude.Stances.Mobility.Value)*Settings.WalkMultiplier), BSpread + ((SpeedPrecision/Saude.Stances.Mobility.Value)*Settings.WalkMultiplier)) / 20),
			RAD(RAND(-BSpread - ((SpeedPrecision/Saude.Stances.Mobility.Value)*Settings.WalkMultiplier), BSpread + ((SpeedPrecision/Saude.Stances.Mobility.Value)*Settings.WalkMultiplier)) / 20),
			RAD(RAND(-BSpread - ((SpeedPrecision/Saude.Stances.Mobility.Value)*Settings.WalkMultiplier), BSpread + ((SpeedPrecision/Saude.Stances.Mobility.Value)*Settings.WalkMultiplier)) / 20)
		)
	Direction = balaspread * Direction	


	Bullet.Parent = BulletModel
	Bullet.CFrame = BulletCF + Direction
	Bullet.Velocity = Direction * Settings.BSpeed
	local RainbowModeCode = Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))
		
	local Visivel = TracerCalculation()

if Settings.BulletFlare == true and Visivel then
	local bg = Instance.new("BillboardGui", Bullet)
		bg.Adornee = Bullet
		bg.Enabled = false
		local flashsize = math.random(275, 375)/10
		bg.Size = UDim2.new(flashsize, 0, flashsize, 0)
		bg.LightInfluence = 0
		local flash = Instance.new("ImageLabel", bg)
		flash.BackgroundTransparency = 1
		flash.Size = UDim2.new(1, 0, 1, 0)
		flash.Position = UDim2.new(0, 0, 0, 0)
		flash.Image = "http://www.roblox.com/asset/?id=1047066405"

		if Settings.RainbowMode == true then
			flash.ImageColor3 = RainbowModeCode
		else
			flash.ImageColor3 = Settings.BulletFlareColor
		end
		flash.ImageTransparency = math.random(2, 5)/15
		spawn(function()
				wait(.2)
				if Bullet:FindFirstChild("BillboardGui") ~= nil then
				Bullet.BillboardGui.Enabled = true
				end
		end)
end



if Settings.Tracer == true and Visivel then

	local At1 = Instance.new("Attachment")
	At1.Name = "At1"
	At1.Position = Vector3.new(-(Settings.TracerWidth),0,0)
	At1.Parent = Bullet
	
	local At2  = Instance.new("Attachment")
	At2.Name = "At2"
	At2.Position = Vector3.new((Settings.TracerWidth),0,0)
	At2.Parent = Bullet

	local Particles = Instance.new("Trail")
	Particles.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0, 0);
				NumberSequenceKeypoint.new(1, 1);
			}
		)
	Particles.WidthScale = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 2, 0);
				NumberSequenceKeypoint.new(1, 1);
			}
		)

	if Settings.RainbowMode == true then
		Particles.Color = ColorSequence.new(RainbowModeCode)
	else
		Particles.Color = ColorSequence.new(Settings.TracerColor)
	end
	Particles.Texture = "rbxassetid://232918622"
	Particles.TextureMode = Enum.TextureMode.Stretch
	
	Particles.FaceCamera = true
	Particles.LightEmission = Settings.TracerLightEmission
	Particles.LightInfluence = Settings.TracerLightInfluence 
	Particles.Lifetime = Settings.TracerLifeTime
	Particles.Attachment0 = At1
	Particles.Attachment1 = At2
	Particles.Parent = Bullet
end
	
if Settings.BulletLight == true and Visivel then
	local BulletLight = Instance.new("PointLight")
	BulletLight.Parent = Bullet
	BulletLight.Brightness = Settings.BulletLightBrightness
	if Settings.RainbowMode == true then
	BulletLight.Color = RainbowModeCode
	else
	BulletLight.Color = Settings.BulletLightColor
	end
	BulletLight.Range = Settings.BulletLightRange
	BulletLight.Shadows = true
	
end

	CreateShell()

	if Visivel then
		if ServerConfig.ReplicatedBullets then
			Evt.ServerBullet:FireServer(BulletCF, Settings.Tracer, Settings.BDrop, Settings.BSpeed, Direction, Settings.TracerColor,Ray_Ignore,Settings.BulletFlare,Settings.BulletFlareColor)
		end
	end
	game.Debris:AddItem(Bullet, 5)
	return Bullet

end


function CalcularDano(DanoBase,Dist,Vitima,Type)

	local damage = 0
	local VestDamage = 0
	local HelmetDamage = 0
	local Traveleddamage = DanoBase-(math.ceil(Dist)/40)*Settings.FallOfDamage
	if Vitima.Parent:FindFirstChild("Saude") ~= nil then

				local Vest =  Vitima.Parent.Saude.Protecao.VestVida
				local Vestfactor = Vitima.Parent.Saude.Protecao.VestProtect
				local Helmet = Vitima.Parent.Saude.Protecao.HelmetVida
				local Helmetfactor = Vitima.Parent.Saude.Protecao.HelmetProtect

		if Type == "Head" then
				if Helmet.Value > 0 and (Settings.BulletPenetration) < Helmetfactor.Value  then
					damage = Traveleddamage * ((Settings.BulletPenetration)/Helmetfactor.Value)
					HelmetDamage = (Traveleddamage * ((100 - Settings.BulletPenetration)/Helmetfactor.Value))
				
					if HelmetDamage <= 0 then
					HelmetDamage = 0.5
					end
					
				elseif Helmet.Value > 0 and (Settings.BulletPenetration) >= Helmetfactor.Value then
					damage = Traveleddamage
					HelmetDamage = (Traveleddamage * ((100 - Settings.BulletPenetration)/Helmetfactor.Value))
					
					if HelmetDamage <= 0 then
					HelmetDamage = 1
					end				

				elseif Helmet.Value <= 0 then
					damage = Traveleddamage
	
				end
			else
				if Vest.Value > 0 and (Settings.BulletPenetration) < Vestfactor.Value  then
					damage = Traveleddamage * ((Settings.BulletPenetration)/Vestfactor.Value)
					VestDamage = (Traveleddamage * ((100 - Settings.BulletPenetration)/Vestfactor.Value))
				
					if VestDamage <= 0 then
					VestDamage = 0.5
					end
					
				elseif Vest.Value > 0 and (Settings.BulletPenetration) >= Vestfactor.Value then
					damage = Traveleddamage
					VestDamage = (Traveleddamage * ((100 - Settings.BulletPenetration)/Vestfactor.Value))
					
					if VestDamage <= 0 then
					VestDamage =  1
					end				

				elseif Vest.Value <= 0 then
					damage = Traveleddamage
	
				end
			end
		else
			damage = Traveleddamage
	end			
		if damage <= 0 then
			damage = 1
		end

	return damage,VestDamage,HelmetDamage
end

local WhizzSound = {"342190005"; "342190012"; "342190017"; "342190024";}

Evt.Whizz.OnClientEvent:connect(function()

	local Som = Instance.new('Sound')
	Som.Parent = Jogador.PlayerGui
	Som.SoundId = "rbxassetid://"..WhizzSound[math.random(1,4)]
	Som.Volume = 2
	Som.PlayOnRemove = true
	Som:Destroy()

end)

Evt.Suppression.OnClientEvent:Connect(function(Mode,Intensity,Tempo)
	if ServerConfig.EnableStatusUI and Jogador.Character and Human.Health > 0 then
		if Mode == 1 then

			TS:Create(StatusClone.Efeitos.Suppress,TweenInfo.new(.1),{ImageTransparency = 0, Size = UDim2.fromScale(1,1.15)}):Play()
			delay(.1,function()
				TS:Create(StatusClone.Efeitos.Suppress,TweenInfo.new(1,Enum.EasingStyle.Exponential,Enum.EasingDirection.InOut,0,false,0.15),{ImageTransparency = 1,Size = UDim2.fromScale(2,2)}):Play()
			end)
		else
			--local SKP_22 = script.FX.Dirty:clone()
			--SKP_22.Parent = Jogador.PlayerGui.StatusUI.Supressao
			--SKP_22.ImageTransparency = 0
			--SKP_22.BackgroundTransparency = (Intensity - 1) * -1

			--TS:Create(SKP_22,TweenInfo.new(0.25 ,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0),{ImageTransparency = 0}):Play()
			--TS:Create(SKP_22,TweenInfo.new(Tempo/2 ,Enum.EasingStyle.Elastic,Enum.EasingDirection.In,0,false,0),{BackgroundTransparency = 1}):Play()


			--delay(Tempo/2,function()
			--TS:Create(SKP_22,TweenInfo.new(Tempo ,Enum.EasingStyle.Sine,Enum.EasingDirection.In,0,false,0),{ImageTransparency = 1}):Play()
			--TS:AddItem(SKP_22, Tempo)
			--end)
		end
	end
end)


function CastRay(Bala)

	local Hit2, Pos2, Norm2, Mat2
	local Hit, Pos, Norm, Mat
	local L_257_ = ArmaClone.SmokePart.Position;
	local L_258_ = Bala.Position;
	local TotalDistTraveled = 0
	local L_260_ = false	
	local recast
	
	while true do
		RS.Heartbeat:wait()
		L_258_ = Bala.Position;
		TotalDistTraveled = TotalDistTraveled + (L_258_ - L_257_).magnitude
	
		Hit2, Pos2, Norm2, Mat2 = workspace:FindPartOnRayWithIgnoreList(Ray.new(L_257_, (L_258_ - L_257_)*20), Ray_Ignore, false, true);

		Hit, Pos, Norm, Mat = workspace:FindPartOnRayWithIgnoreList(Ray.new(L_257_, (L_258_ - L_257_)), Ray_Ignore, false, true);
		
		for L_264_forvar1, L_265_forvar2 in pairs(game.Players:GetChildren()) do
			if L_265_forvar2:IsA('Player') and L_265_forvar2 ~= Player and L_265_forvar2.Character and L_265_forvar2.Character:FindFirstChild('Head') and (L_265_forvar2.Character.Head.Position - Pos).magnitude <= Settings.SuppressMaxDistance and Settings.BulletWhiz and not L_260_ then
				Evt.Whizz:FireServer(L_265_forvar2)
				Evt.Suppression:FireServer(L_265_forvar2)
				L_260_ = true
			end
		end

		if TotalDistTraveled > Settings.Distance then
			Bala:Destroy()
			L_260_ = true
			break
		end
		
		if Hit2 then
			while not recast do
				if Hit2 and (Hit2 and Hit2.Transparency >= 1 or Hit2.CanCollide == false or Hit2.Name == "Ignorable" or Hit2.Name == "Glass" or Hit2.Parent.Name == "Top" or Hit2.Parent.Name == "Helmet" or Hit2.Parent.Name == "Up" or Hit2.Parent.Name == "Down" or Hit2.Parent.Name == "Face" or Hit2.Parent.Name == "Olho" or Hit2.Parent.Name == "Headset" or Hit2.Parent.Name == "Numero" or Hit2.Parent.Name == "Vest" or Hit2.Parent.Name == "Chest" or Hit2.Parent.Name == "Waist" or Hit2.Parent.Name == "Back" or Hit2.Parent.Name == "Belt" or Hit2.Parent.Name == "Leg1" or Hit2.Parent.Name == "Leg2" or Hit2.Parent.Name == "Arm1"  or Hit2.Parent.Name == "Arm2") and Hit2.Name ~= 'Right Arm' and Hit2.Name ~= 'Left Arm' and Hit2.Name ~= 'Right Leg' and Hit2.Name ~= 'Left Leg' and Hit2.Name ~= 'Armor' and Hit2.Name ~= 'EShield' then
					table.insert(Ray_Ignore, Hit2)
					recast = true
				end
	
				if recast then
					Hit2, Pos2, Norm2, Mat2 = workspace:FindPartOnRayWithIgnoreList(Ray.new(L_257_, (L_258_ - L_257_)*20), Ray_Ignore, false, true);
					Hit, Pos, Norm, Mat = workspace:FindPartOnRayWithIgnoreList(Ray.new(L_257_, (L_258_ - L_257_)), Ray_Ignore, false, true);
					recast = false
				else
					break
				end
			end
		end

		if Hit and not recast then
			Bala:Destroy()
			L_260_ = true
			local FoundHuman,VitimaHuman = CheckForHumanoid(Hit)
				Hitmarker.HitEffect(Ray_Ignore,ACS_Storage, Pos, Hit, Norm, Mat, Settings)
				Evt.Hit:FireServer(Pos, Hit, Norm, Mat,Settings,TotalDistTraveled)
			if FoundHuman == true and VitimaHuman.Health > 0 then
				if ServerConfig.HitmarkerSound then
					local hurtSound = PastaFX.Hitmarker:Clone()
					hurtSound.Parent = Player.PlayerGui
					hurtSound.Volume = 2
					hurtSound.PlayOnRemove = true
					Debris:AddItem(hurtSound,0)	
				end			

				if not  Settings.ModoTreino then
					Evt.CreateOwner:FireServer(VitimaHuman)

					if game.Players:FindFirstChild(VitimaHuman.Parent.Name) == nil then
							if Hit.Name == "Head" then
								local DanoBase = math.random(Settings.HeadDamage[1], Settings.HeadDamage[2])
								local Dano,DanoColete,DanoCapacete = CalcularDano(DanoBase, TotalDistTraveled, VitimaHuman, "Head")	
								Evt.Damage:FireServer(VitimaHuman,Dano,DanoColete,DanoCapacete)
							elseif Hit.Name == "Torso" or Hit.Parent.Name == "UpperTorso" or Hit.Parent.Name == "LowerTorso" then
								local DanoBase = math.random(Settings.TorsoDamage[1], Settings.TorsoDamage[2])
								local Dano,DanoColete,DanoCapacete = CalcularDano(DanoBase, TotalDistTraveled, VitimaHuman, "Body")	
								Evt.Damage:FireServer(VitimaHuman,Dano,DanoColete,DanoCapacete)
							else
								local DanoBase = math.random(Settings.LimbsDamage[1], Settings.LimbsDamage[2])
								local Dano,DanoColete,DanoCapacete = CalcularDano(DanoBase, TotalDistTraveled, VitimaHuman, "Body")	
								Evt.Damage:FireServer(VitimaHuman,Dano,DanoColete,DanoCapacete)
							end	
				
					else
					
					if not ServerConfig.TeamKill then
						if game.Players:FindFirstChild(VitimaHuman.Parent.Name) and game.Players:FindFirstChild(VitimaHuman.Parent.Name).Team ~= Player.Team or game.Players:FindFirstChild(VitimaHuman.Parent.Name) == nil then
							if Hit.Name == "Head" or Hit.Parent.Name == "Top" or Hit.Parent.Name == "Headset" or Hit.Parent.Name == "Olho" or Hit.Parent.Name == "Face" or Hit.Parent.Name == "Numero" then
								local DanoBase = math.random(Settings.HeadDamage[1], Settings.HeadDamage[2])
								local Dano,DanoColete,DanoCapacete = CalcularDano(DanoBase, TotalDistTraveled, VitimaHuman, "Head")	
								Evt.Damage:FireServer(VitimaHuman,Dano,DanoColete,DanoCapacete)
							elseif (Hit.Parent:IsA('Accessory') or Hit.Parent:IsA('Hat')) then
								local DanoBase = math.random(Settings.HeadDamage[1], Settings.HeadDamage[2])
								local Dano,DanoColete,DanoCapacete = CalcularDano(DanoBase, TotalDistTraveled, VitimaHuman, "Head")	
								Evt.Damage:FireServer(VitimaHuman,Dano,DanoColete,DanoCapacete)
							elseif Hit.Name == "Torso" or Hit.Parent.Name == "Chest" or Hit.Parent.Name == "Waist" then
								local DanoBase = math.random(Settings.TorsoDamage[1], Settings.TorsoDamage[2])
								local Dano,DanoColete,DanoCapacete = CalcularDano(DanoBase, TotalDistTraveled, VitimaHuman, "Body")	
								Evt.Damage:FireServer(VitimaHuman,Dano,DanoColete,DanoCapacete)
							elseif Hit.Name == "Right Arm" or Hit.Name == "Right Leg" or Hit.Name == "Left Leg" or Hit.Name == "Left Arm" then
								local DanoBase = math.random(Settings.LimbsDamage[1], Settings.LimbsDamage[2])
								local Dano,DanoColete,DanoCapacete = CalcularDano(DanoBase, TotalDistTraveled, VitimaHuman, "Body")	
								Evt.Damage:FireServer(VitimaHuman,Dano,DanoColete,DanoCapacete)
							end	
						end
					else
						if game.Players:FindFirstChild(VitimaHuman.Parent.Name) and game.Players:FindFirstChild(VitimaHuman.Parent.Name).Team ~= Player.Team or game.Players:FindFirstChild(VitimaHuman.Parent.Name) == nil  then				
							if Hit.Name == "Head" or Hit.Parent.Name == "Top" or Hit.Parent.Name == "Headset" or Hit.Parent.Name == "Olho" or Hit.Parent.Name == "Face" or Hit.Parent.Name == "Numero" then
								local DanoBase = math.random(Settings.HeadDamage[1], Settings.HeadDamage[2])
								local Dano,DanoColete,DanoCapacete = CalcularDano(DanoBase, TotalDistTraveled, VitimaHuman, "Head")	
								Evt.Damage:FireServer(VitimaHuman,Dano,DanoColete,DanoCapacete)
							elseif (Hit.Parent:IsA('Accessory') or Hit.Parent:IsA('Hat')) then
								local DanoBase = math.random(Settings.HeadDamage[1], Settings.HeadDamage[2])
								local Dano,DanoColete,DanoCapacete = CalcularDano(DanoBase, TotalDistTraveled, VitimaHuman, "Head")	
								Evt.Damage:FireServer(VitimaHuman,Dano,DanoColete,DanoCapacete)
							elseif Hit.Name == "Torso" or Hit.Parent.Name == "Chest" or Hit.Parent.Name == "Waist" then
								local DanoBase = math.random(Settings.TorsoDamage[1], Settings.TorsoDamage[2])
								local Dano,DanoColete,DanoCapacete = CalcularDano(DanoBase, TotalDistTraveled, VitimaHuman, "Body")	
								Evt.Damage:FireServer(VitimaHuman,Dano,DanoColete,DanoCapacete)
							elseif Hit.Name == "Right Arm" or Hit.Name == "Right Leg" or Hit.Name == "Left Leg" or Hit.Name == "Left Arm" then 
								local DanoBase = math.random(Settings.LimbsDamage[1], Settings.LimbsDamage[2])
								local Dano,DanoColete,DanoCapacete = CalcularDano(DanoBase, TotalDistTraveled, VitimaHuman, "Body")	
								Evt.Damage:FireServer(VitimaHuman,Dano,DanoColete,DanoCapacete)
							end	
						else 
							if Hit.Name == "Head" or Hit.Parent.Name == "Top" or Hit.Parent.Name == "Headset" or Hit.Parent.Name == "Olho" or Hit.Parent.Name == "Face" or Hit.Parent.Name == "Numero" then
								local DanoBase = math.random(Settings.HeadDamage[1], Settings.HeadDamage[2])* ServerConfig.TeamDamageMultiplier
								local Dano,DanoColete,DanoCapacete = CalcularDano(DanoBase, TotalDistTraveled, VitimaHuman, "Head")	
								Evt.Damage:FireServer(VitimaHuman,Dano,DanoColete,DanoCapacete)
							elseif (Hit.Parent:IsA('Accessory') or Hit.Parent:IsA('Hat')) then
								local DanoBase = math.random(Settings.HeadDamage[1], Settings.HeadDamage[2])* ServerConfig.TeamDamageMultiplier
								local Dano,DanoColete,DanoCapacete = CalcularDano(DanoBase, TotalDistTraveled, VitimaHuman, "Head")	
								Evt.Damage:FireServer(VitimaHuman,Dano,DanoColete,DanoCapacete)
							elseif Hit.Name == "Torso" or Hit.Parent.Name == "Chest" or Hit.Parent.Name == "Waist" then
								local DanoBase = math.random(Settings.TorsoDamage[1], Settings.TorsoDamage[2])* ServerConfig.TeamDamageMultiplier
								local Dano,DanoColete,DanoCapacete = CalcularDano(DanoBase, TotalDistTraveled, VitimaHuman, "Body")	
								Evt.Damage:FireServer(VitimaHuman,Dano,DanoColete,DanoCapacete)
							elseif Hit.Name == "Right Arm" or Hit.Name == "Right Leg" or Hit.Name == "Left Leg" or Hit.Name == "Left Arm" then
								local DanoBase = math.random(Settings.LimbsDamage[1], Settings.LimbsDamage[2])* ServerConfig.TeamDamageMultiplier
								local Dano,DanoColete,DanoCapacete = CalcularDano(DanoBase, TotalDistTraveled, VitimaHuman, "Body")	
								Evt.Damage:FireServer(VitimaHuman,Dano,DanoColete,DanoCapacete)
							end	
						end
					end
				end
				else
				if Hit.Name == "Head" or Hit.Parent.Name == "Top" or Hit.Parent.Name == "Headset" or Hit.Parent.Name == "Olho" or Hit.Parent.Name == "Face" or Hit.Parent.Name == "Numero"  or (Hit.Parent:IsA('Accessory') or Hit.Parent:IsA('Hat')) or Hit.Name == "Torso" or Hit.Parent.Name == "Chest" or Hit.Parent.Name == "Waist" or Hit.Name == "Right Arm" or Hit.Name == "Left Arm" or Hit.Name == "Right Leg" or Hit.Name == "Left Leg" or Hit.Parent.Name == "Back" or Hit.Parent.Name == "Leg1" or Hit.Parent.Name == "Leg2" or Hit.Parent.Name == "Arm1" or Hit.Parent.Name == "Arm2" then
					Evt.Treino:FireServer(VitimaHuman)
				end
			end
			break
			end
		end		
		L_257_ = L_258_;
	end
end

Human.Running:connect(function(walkin)
	if Equipped then
		SpeedPrecision = walkin
		Sprint()
		if walkin > 1 then
			Walking = true
		else
			Walking = false
		end
	end
end)


Mouse.KeyDown:connect(function(Key)
	if Equipped then
		if Key == "w" then
			if not w then
				w = true
			end
		end
		if Key == "a" then
			if not a then
				a = true
			end
		end
		if Key == "s" then
			if not s then
				s = true
			end
		end
		if Key == "d" then
			if not d then
				d = true
			end
		end
	end
end)

Mouse.KeyUp:connect(function(Key)
	if Equipped then
		if Key == "w" then
			if w then
				w = false
			end
		end
		if Key == "a" then
			if a then
				a = false
			end
		end
		if Key == "s" then
			if s then
				s = false
			end
		end
		if Key == "d" then
			if d then
				d = false
			end
		end
	end
end)



function SlideEx()
						tweenJoint(ArmaClone.Handle:WaitForChild("Slide"),  CFrame.new(Settings.SlideExtend) * CFrame.Angles(0,math.rad(0),0) , nil, function(X) return math.sin(math.rad(X)) end, 1 * (FireRate/2))
						if Settings.MoveBolt == true then
						tweenJoint(ArmaClone.Handle:WaitForChild("Bolt"),  CFrame.new(Settings.BoltExtend) * CFrame.Angles(0,math.rad(0),0) , nil, function(X) return math.sin(math.rad(X)) end, 1 * (FireRate/2))
						end
						delay(FireRate/2,function()
							if Ammo.Value >= 1 then
								tweenJoint(ArmaClone.Handle:WaitForChild("Slide"),  CFrame.new(0,0,0) * CFrame.Angles(0,math.rad(0),0) , nil, function(X) return math.sin(math.rad(X)) end, 1 * (FireRate/2))
								if Settings.MoveBolt == true then
								tweenJoint(ArmaClone.Handle:WaitForChild("Bolt"),  CFrame.new(0,0,0) * CFrame.Angles(0,math.rad(0),0) , nil, function(X) return math.sin(math.rad(X)) end, 1 * (FireRate/2))
								end
							elseif Ammo.Value < 1 and Settings.SlideLock == true then
								Chambered.Value = false
								if Settings.MoveBolt == true and Settings.BoltLock == false then
								tweenJoint(ArmaClone.Handle:WaitForChild("Bolt"),  CFrame.new(0,0,0) * CFrame.Angles(0,math.rad(0),0) , nil, function(X) return math.sin(math.rad(X)) end, 1 * (FireRate/2))
								end
								ArmaClone.Handle.Click:Play()
								slideback = true
							elseif Ammo.Value < 1 and Settings.SlideLock == false then
								tweenJoint(ArmaClone.Handle:WaitForChild("Slide"),  CFrame.new(0,0,0) * CFrame.Angles(0,math.rad(0),0) , nil, function(X) return math.sin(math.rad(X)) end, 1 * (FireRate/2))
								if Settings.MoveBolt == true then
								tweenJoint(ArmaClone.Handle:WaitForChild("Bolt"),  CFrame.new(0,0,0) * CFrame.Angles(0,math.rad(0),0) , nil, function(X) return math.sin(math.rad(X)) end, 1 * (FireRate/2))
								end
								Chambered.Value = false
								ArmaClone.Handle.Click:Play()
							end
						end)
					end

local new = game.Workspace.Camera:FindFirstChild("NewRecoil") or Instance.new("Part")
new.CanCollide = false
new.Anchored = true
new.Transparency = 1
new.Parent = game.Workspace.Camera
new.Size = Vector3.new(0.1,0.1,0.1)
new.Name = "NewRecoil"

local new2 = game.Workspace.Camera:FindFirstChild("NewRecoil3") or Instance.new("Part")
new2.CanCollide = false
new2.Anchored = false
new2.Transparency = 1
new2.Parent = game.Workspace.Camera
new2.Size = Vector3.new(0.1,0.1,0.1)
new2.Name = "NewRecoil3"

local new3 = new:FindFirstChildWhichIsA("Motor6D") or Instance.new("Motor6D")
new3.Parent = new
new3.Part0 = new
new3.Part1 = new2


function recoil()
	task.spawn(function()




		if Bipod then
			local vr  = (VRecoil)/5	
			local hr = ((HRecoil) * math.random(-1, 1))/5

			Camera.CFrame = Camera.CFrame * CFrame.Angles(vr, hr, 0)
			local c = -vr/30
			local cx = -(hr)/30
			local curId
			local EquipId = curId
			local vP
			if Settings.GunType == 0 then
				vP = (VPunchBase)
			else
				vP = (VPunchBase*10)/100
			end
			local hP = (math.random(-HPunchBase*25, HPunchBase*25))/100
			local dP = ((DPunchBase) * math.random(-1, 1))
			if not Aiming then
				Recoil = Recoil*CFrame.new(0,0,(Settings.RecoilPunch/2)) * CFrame.Angles(RAD(vP*RecoilPower*0.25),RAD(hP*RecoilPower*0.25),RAD(dP*RecoilPower*0.25))
			else
				Recoil = Recoil*CFrame.new(0,0,(Settings.RecoilPunch/2)) * CFrame.Angles(RAD(vP*RecoilPower*0.25),RAD(hP*RecoilPower*0.25),RAD(dP*RecoilPower*0.25))
			end
			for i = 1, 30 do
				if EquipId == curId then
					Camera.CoordinateFrame = CFrame.new(Camera.Focus.p) * (Camera.CoordinateFrame - Camera.CoordinateFrame.p) * CFrame.Angles(c,  cx, 0) * CFrame.new(0, 0, (Camera.Focus.p - Camera.CoordinateFrame.p).magnitude)
					wait()
				else
					break
				end
			end
		else
			local vr  = (VRecoil)	
			local hr = (HRecoil) * math.random(-1, 1)

			Camera.CFrame = Camera.CFrame * CFrame.Angles(vr, hr, 0)
			local c = -vr/30
			local cx = -(hr)/30
			local curId
			local EquipId = curId
			local vP
			if Settings.GunType == 0 then
				vP = (VPunchBase)
			else
				vP = (math.random(-VPunchBase*50,VPunchBase*100))/100
			end
			local hP = (math.random(-HPunchBase*100, HPunchBase*100))/100
			local dP = ((DPunchBase) * math.random(-1, 1))
			if not Aiming then
				Recoil = Recoil*CFrame.new(0,0,(Settings.RecoilPunch)) * CFrame.Angles(RAD(vP*RecoilPower),RAD(hP*RecoilPower),RAD(dP*RecoilPower))
			else
				Recoil = Recoil*CFrame.new(0,0,(Settings.RecoilPunch/2)) * CFrame.Angles(RAD(vP*RecoilPower/Settings.AimRecoilReduction),RAD(hP*RecoilPower/Settings.AimRecoilReduction),RAD(dP*RecoilPower/Settings.AimRecoilReduction))
			end
			for i = 1, 30*Settings.AimRecover do
				if EquipId == curId then
					Camera.CoordinateFrame = CFrame.new(Camera.Focus.p) * (Camera.CoordinateFrame - Camera.CoordinateFrame.p) * CFrame.Angles(c,  cx, 0) * CFrame.new(0, 0, (Camera.Focus.p - Camera.CoordinateFrame.p).magnitude)
					wait()
				else
					break
				end
			end
		end
	end)

	if Stocked and StockedCFrame2 ~= nil then
		new.CFrame = ArmaClone.Handle.CFrame * StockedCFrame2
	else
		new.CFrame = ArmaClone.Handle.CFrame * CFrame.new(0, 0.0591001511, 0.466899931, 1.00000012, -8.92215013e-08, 0, 8.9592433e-08, 1.00000012, 0, -5.45696821e-12, -9.09494702e-13, 1)
	end

	local BPCF = game.Workspace.Camera.BasePart.CFrame

	new3.C1 = BPCF:ToObjectSpace(new.CFrame) * Recoil
	Recoil = new2.CFrame:ToObjectSpace(BPCF)

	for _, v in pairs(ArmaClone.SmokePart:GetChildren()) do
		if v.Name:sub(1, 7) == "FlashFX" or v.Name:sub(1, 7) == "Smoke" then
			v.Enabled = true
		end
	end
	for _, a in pairs(ArmaClone.Chamber:GetChildren()) do
		if a.Name:sub(1, 7) == "FlashFX" or a.Name:sub(1, 7) == "Smoke" then
			a.Enabled = true
		end
	end

	delay(1 / 30, function()

		for _, v in pairs(ArmaClone.SmokePart:GetChildren()) do
			if v.Name:sub(1, 7) == "FlashFX" or v.Name:sub(1, 7) == "Smoke" then
				v.Enabled = false
			end
		end

		for _, a in pairs(ArmaClone.Chamber:GetChildren()) do
			if a.Name:sub(1, 7) == "FlashFX" or a.Name:sub(1, 7) == "Smoke" then
				a.Enabled = false
			end
		end

	end)
	if Silencer.Value == true then
		Character:WaitForChild('S'.. ArmaClone.Name):WaitForChild('Grip'):WaitForChild('Supressor'):Play()	
	else
		Character:WaitForChild('S'.. ArmaClone.Name):WaitForChild('Grip'):WaitForChild('Fire'):Play()	
		Character:WaitForChild('S'.. ArmaClone.Name):WaitForChild('Grip'):WaitForChild('Echo'):Play()
	end

	SlideEx()

end

function Emperrar()
	if Settings.CanBreak == true and Chambered.Value == true and (Ammo.Value - 1) > 0 then
	local Jam = math.random(Settings.JamChance)
	if Jam <= 2 then
		Emperrado.Value = true
		ArmaClone.Handle:WaitForChild("Click"):Play()
	end
end
end


function HalfStepFunc(Rot)
	if PlaceHolder then
		Offset = Human.CameraOffset
		Evt.HeadRot:FireServer(Rot, Offset, Equipped)
	end
	PlaceHolder = not PlaceHolder
end

oldtick = tick()
xTilt = 0
yTilt = 0
lastPitch = 0
lastYaw = 0
local TVal = 0

local L_199_ = nil
Personagem.ChildAdded:connect(function(Tool)
	if Tool:IsA('Tool') and Tool:FindFirstChild('ACS_Modulo') and Tool.ACS_Modulo:FindFirstChild('ACS_Setup') and Humanoid.Health > 0 and not ToolEquip and require(Tool.ACS_Modulo.ACS_Setup).Type == 'Gun' then
		local L_370_ = true
		if Personagem:WaitForChild('Humanoid').Sit and Personagem.Humanoid.SeatPart:IsA("VehicleSeat") or Personagem:WaitForChild('Humanoid').Sit and Personagem.Humanoid.SeatPart:IsA("VehicleSeat") or Nadando then
			L_370_ = false;
		end

		if L_370_ then
			L_199_ = Tool
			if not Equipped then
				uis.MouseIconEnabled = false
				Player.CameraMode = Enum.CameraMode.LockFirstPerson
				Setup(Tool)
				LoadClientMods()

				Ray_Ignore = {Character, Ignore_Model, Camera, BulletModel}

				Gui = StatusClone:WaitForChild("GunHUD")
				Gui.Visible = true
				CanUpdateGui = true
				Update_Gui()
				EquipAnim()
				if Settings.ZoomAnim and AimPartMode == 2 then
					ZoomAnim()
				end
				Sprint()
			elseif Equipped then
				Unset()
				Setup(L_199_)
				LoadClientMods()
			end;

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
		end;
	end
end)

Human.Seated:Connect(function(isSeated, seat)
	if isSeated and (seat:IsA("VehicleSeat")) then
		Unset()
		Humanoid:UnequipTools()
		Jogador.CameraMaxZoomDistance = ServerConfig.VehicleMaxZoom
	else
		Jogador.CameraMaxZoomDistance = game.StarterPlayer.CameraMaxZoomDistance
	end
end)

Jogador.Backpack.ChildRemoved:connect(function(L_371_arg1)
		Evt.Holster:FireServer(L_371_arg1)
end)

Personagem.ChildRemoved:connect(function(L_371_arg1)
	if L_371_arg1 == ArmaClient then
		if Equipped then
			if Balinha then
				Balinha:Destroy()
			end
			Unset()
		end
	end
end)

RS.RenderStepped:connect(function(Update)

	if not Equipped then
		HeadBase.CFrame = Camera.CFrame * CFrame.new(0, 0, -.5)
	else
		Update_Gui()
		HalfStepFunc(-math.asin(Camera.CoordinateFrame.lookVector.y))
		
		Recoil = Recoil:lerp(CFrame.new(),Settings.PunchRecover)		

		--RA.C0 = Recoil
		--LA.C0 = Recoil
			
		local Raio = Ray.new(ArmaClone.Handle.Position, Camera.CFrame.LookVector * Settings.GunSize)
		local Hit, Pos = workspace:FindPartOnRayWithIgnoreList(Raio, Ray_Ignore, false, true)

		local lk = Camera.CoordinateFrame.lookVector
		local x = lk.X
		local rise = lk.Y
		local z = lk.Z
		
		local lookpitch, lookyaw = math.asin(rise), -math.atan(x / z)
	
		local pitchChange = lastPitch - lookpitch
		local yawChange = lastYaw - lookyaw
		pitchChange = pitchChange * ((math.abs(pitchChange) < 1) and 1 or 0)
		yawChange = yawChange * ((math.abs(yawChange) < 1) and 1 or 0)
		yTilt = (yTilt * 0.5 + pitchChange)
		xTilt = (xTilt * 0.5 + yawChange)

		lastPitch = lookpitch
		lastYaw = lookyaw

			sway.t = V3(xTilt, yTilt, TVal)
			local swayVec = sway.p
			local TWAY = swayVec.z
			local XSWY = swayVec.X * 5
			local YSWY = swayVec.Y * 5							
								
			local xWalk = SIN(t*3)*(SpeedPrecision/ServerConfig.RunWalkSpeed *(WVal+1))
			local yWalk = COS(t*3)*(SpeedPrecision/ServerConfig.RunWalkSpeed *(WVal+1))
			local xWak  = SIN(t*1.75)*(SpeedPrecision/ServerConfig.RunWalkSpeed *(WVal+1))
			local yWak  = COS(t*3.5)*(SpeedPrecision/ServerConfig.RunWalkSpeed *(WVal+1))
			
			local zWalk = WVal	
			Walk.t = Vector3.new(xWalk,yWalk,WVal)
			local Walk2 = Walk.p
			local xWalk2 = Walk2.X/3
			local yWalk2 = Walk2.Y/3
			local zWalk2 = Walk2.Z/10
			local xWalk3 = Walk2.X/1
			local yWalk3 = Walk2.Y/1
			if Clone then
				if Aiming then
					zWalk = 0	
				else
					zWalk = WVal	
				end
				if Walking then
					WalkRate = (Human.WalkSpeed/3)	
					if a then
						TVal = Lerp(0,(-.20*SpeedPrecision/ServerConfig.RunWalkSpeed),10)
					elseif d then
						TVal = Lerp(0,(.20*SpeedPrecision/ServerConfig.RunWalkSpeed),10)
					else
						TVal = Lerp(0,0,10)
					end
				else
					WalkRate = (SpeedPrecision/ServerConfig.RunWalkSpeed) + .5
					WVal = Lerp(0,0,10)
				end									
				local currtick = tick()
				t = t + (((currtick - OldTick)*WalkRate))
				OldTick = currtick	
				local Sway = CFa(YSWY*RAD(5),-XSWY*RAD(5),-XSWY*RAD(0))
				Waval = Waval:lerp(CFn(xWalk3/220,-yWalk3/180,0)*CFn(xWak/220,-yWak/180,0)*CFa(0,0,zWalk2/5)*CFa(0,0,(TWAY/2)/10),1)
				Clone.C0 = Clone.C0:lerp(Waval*Sway,1)
			end
			if OverHeat and Can_Shoot then
			delay(5,function()
			if Can_Shoot then
			OverHeat = false
			end
			end)
		end

		if BSpread then
		local currTime = time()
		if currTime - LastSpreadUpdate > FireRate * 2 then
			LastSpreadUpdate = currTime
			BSpread = math.max(Settings.MinSpread, BSpread - (Settings.AimInaccuracyStepAmount)/5)
			RecoilPower =  math.max(Settings.MinRecoilPower, RecoilPower - (Settings.RecoilPowerStepAmount)/4)
		end
	end

	if OverHeat then
		ArmaClone.SmokePart.OverHeat.Enabled = true
	else
		ArmaClone.SmokePart.OverHeat.Enabled = false
	end
		
		if Aiming then
			if not NVG or ArmaClone.AimPart:FindFirstChild("NVAim") == nil then
				if AimPartMode == 1 and ArmaClone:FindFirstChild("AimPart2") ~= nil then
					Clone.C1 = Clone.C1:Lerp(Clone.C1 * Clone.C0:inverse() * Recoil * CFrame.new() * ArmaClone.AimPart.CFrame:toObjectSpace(HeadBase.CFrame),0.15)
				elseif AimPartMode == 2 and ArmaClone:FindFirstChild("AimPart2") ~= nil then
					Clone.C1 = Clone.C1:Lerp(Clone.C1 * Clone.C0:inverse() * Recoil * ArmaClone.AimPart2.CFrame:toObjectSpace(HeadBase.CFrame),0.15)
				else
					Clone.C1 = Clone.C1:Lerp(Clone.C1 * Clone.C0:inverse() * Recoil * ArmaClone.AimPart.CFrame:toObjectSpace(HeadBase.CFrame),0.15)
				end
			else
				if not Bipod then
					Clone.C1 = Clone.C1:Lerp(Clone.C1 * Clone.C0:inverse() * Recoil * CFrame.new() * (ArmaClone.AimPart.CFrame * ArmaClone.AimPart.NVAim.CFrame):toObjectSpace(HeadBase.CFrame),0.15)
				else
					Aiming = false
					stance = 0
				end
			end
		else
			if Hit and stance == 0 and Bipod == false then
				Clone.C1 = Clone.C1:Lerp(Clone.C0:inverse() * Recoil * CFrame.new(0,0,(((ArmaClone.Handle.Position - Pos).magnitude/Settings.GunSize) - 1) * -Settings.GunFOVReduction) ,0.15)
			else
				Clone.C1 = Clone.C1:Lerp(Clone.C0:inverse() * Recoil * CFrame.new(),0.15)
			end
		end

		if ArmaClone:FindFirstChild("BipodPoint") ~= nil then

			local BipodRay = Ray.new(ArmaClone.BipodPoint.Position, ArmaClone.BipodPoint.CFrame.UpVector * -1.75)
			local BipodHit, BipodPos, BipodNorm = workspace:FindPartOnRayWithIgnoreList(BipodRay, Ray_Ignore, false, true)

			if BipodHit and (stance == 0 or stance == 2) then
				Gui.Bipod.ImageColor3 = Color3.fromRGB(255, 255, 0)
				BipodEnabled = true
				if BipodEnabled and Bipod then
					Gui.Bipod.ImageColor3 = Color3.fromRGB(255, 255, 255)
					local StaminaValue = 0
					HeadBase.CFrame = Camera.CFrame * CFrame.new(0, 0, -.5) * CFrame.Angles( math.rad(StaminaValue * math.sin( tick() * 2.5 )),math.rad(StaminaValue * math.sin( tick() * 1.25 )), 0)
					if stance == 0 and not Aiming then
						Clone.C1 = Clone.C1:Lerp(Clone.C0:inverse() * Recoil * CFrame.new(0,(((ArmaClone.BipodPoint.Position - BipodPos).magnitude)-1) * (-1.5), 0) ,0.15)
					end
				else
					Gui.Bipod.ImageColor3 = Color3.fromRGB(255, 255, 0)
					local StaminaValue = Settings.SwayBase + (1-(Personagem.Saude.Variaveis.Stamina.Value/Personagem.Saude.Variaveis.Stamina.MaxValue))* Settings.MaxSway
					HeadBase.CFrame = Camera.CFrame * CFrame.new(0, 0, -.5) * CFrame.Angles( math.rad(StaminaValue * math.sin( tick() * 2.5 )),math.rad(StaminaValue * math.sin( tick() * 1.25 )), 0)
				end
			else
				Gui.Bipod.ImageColor3 = Color3.fromRGB(255, 0, 0)
				Bipod = false
				BipodEnabled = false
				local StaminaValue = Settings.SwayBase + (1-(Personagem.Saude.Variaveis.Stamina.Value/Personagem.Saude.Variaveis.Stamina.MaxValue))* Settings.MaxSway
				HeadBase.CFrame = Camera.CFrame * CFrame.new(0, 0, -.5) * CFrame.Angles( math.rad(StaminaValue * math.sin( tick() * 2.5 )),math.rad(StaminaValue * math.sin( tick() * 1.25 )), 0)
			end		

		else
			Gui.Bipod.ImageColor3 = Color3.fromRGB(255, 0, 0)
			local StaminaValue = Settings.SwayBase + (1-(Personagem.Saude.Variaveis.Stamina.Value/Personagem.Saude.Variaveis.Stamina.MaxValue))* Settings.MaxSway
			HeadBase.CFrame = Camera.CFrame * CFrame.new(0, 0, -.5) * CFrame.Angles( math.rad(StaminaValue * math.sin( tick() * 2.5 )),math.rad(StaminaValue * math.sin( tick() * 1.25 )), 0)
		end

		

		if Equipped and LaserAtivo then
			if NVG then
				Pointer.Transparency = 0
				Laser.Enabled = true
				
			else
			
				if not ServerConfig.RealisticLaser then
					Laser.Enabled = true
				else
					Laser.Enabled = false
				end
			
				if IRmode then
					Pointer.Transparency = 1
				else
					Pointer.Transparency = 0
				end
			end

			local L_361_ = Ray.new(ArmaClone.LaserPoint.Position, AnimBase.CFrame.lookVector * 999)
			local Hit, Pos, Normal = workspace:FindPartOnRayWithIgnoreList(L_361_, Ray_Ignore, false, true)
			
			LaserEP.CFrame = CFrame.new(0, 0, -LaserDist)
			Pointer.CFrame =  CFrame.new(Pos, Pos + Normal)
		
			
			if Hit then
				LaserDist = (ArmaClone.LaserPoint.Position - Pos).magnitude
			else
				LaserDist = 999
			end
			Evt.SVLaser:FireServer(Pos,1,ArmaClone.LaserPoint.Color,ArmaClient,IRmode)
		end
end
	end)

Evt.SVFlash.OnClientEvent:Connect(function(Player,Mode,Arma,Angle,Bright,Color,Range)
	if Player ~= Jogador and Player.Character['S' .. Arma.Name].Grip:FindFirstChild("Flash") ~= nil then
		local Arma = Player.Character['S' .. Arma.Name]
		local Luz = Instance.new("SpotLight")
		local bg = Instance.new("BillboardGui")
		
		
		if Mode == true then
		Luz.Parent = Arma.Grip.Flash
		Luz.Angle = Angle
		Luz.Brightness = Bright
		Luz.Range = Range
		Luz.Color = Color
		
		bg.Parent = Arma.Grip.Flash
		bg.Adornee = Arma.Grip.Flash
		bg.Size = UDim2.new(10, 0, 10, 0)

		local flash = Instance.new("ImageLabel", bg)
		flash.BackgroundTransparency = 1
		flash.Size = UDim2.new(1, 20, 1, 20)
		flash.AnchorPoint = Vector2.new(0.5,0.5)
		flash.Position = UDim2.new(0.5, 0, 0.5, 0)
		flash.Image = "http://www.roblox.com/asset/?id=1847258023"
		flash.ImageColor3 = Color
		flash.ImageTransparency = 0.25
		flash.Rotation = math.random(-45, 45)

		else
			if Arma.Grip.Flash:FindFirstChild("SpotLight") ~= nil then
				Arma.Grip.Flash:FindFirstChild("SpotLight"):Destroy()
			end
			if Arma.Grip.Flash:FindFirstChild("BillboardGui") ~= nil then
				Arma.Grip.Flash:FindFirstChild("BillboardGui"):Destroy()
			end
		end
	end
end)

Evt.SVLaser.OnClientEvent:Connect(function(Player,Position,Modo,Cor,Arma,IR)

if Player ~= Jogador then

	if BulletModel:FindFirstChild(Player.Name.."_Laser") == nil then
		local Dot = Instance.new('Part')
		local Att0 = Instance.new('Attachment')
		Att0.Name = "Att0"
		Att0.Parent = Dot
		Dot.Name = Player.Name.."_Laser"
		Dot.Parent = BulletModel
		Dot.Transparency = 1

		if Player.Character and Player.Character:FindFirstChild('S'.. Arma.Name) ~= nil and Player.Character:WaitForChild('S'.. Arma.Name):WaitForChild('Grip'):FindFirstChild("Laser") ~= nil then
		local Muzzle = Player.Character:WaitForChild('S'.. Arma.Name):WaitForChild('Grip'):WaitForChild("Laser")


		local Laser = Instance.new('Beam')
			Laser.Parent = Dot
			Laser.Transparency = NumberSequence.new(0)
			Laser.LightEmission = 1
			Laser.LightInfluence = 0
			Laser.Attachment0 = Att0
			Laser.Attachment1 = Muzzle
			Laser.Color = ColorSequence.new(Cor)
			Laser.FaceCamera = true
			Laser.Width0 = 0.01
			Laser.Width1 = 0.01
		if not NVG then
			Laser.Enabled = false
		end
	end
	end
	
if Modo == 1 then
	if BulletModel:FindFirstChild(Player.Name.."_Laser") ~= nil then
		local LA = BulletModel:FindFirstChild(Player.Name.."_Laser")
		LA.Shape = 'Ball'
		LA.Size = Vector3.new(0.2, 0.2, 0.2)
		LA.CanCollide = false
		LA.Anchored = true
		LA.Color = Cor
		LA.Material = Enum.Material.Neon
		LA.Position = Position	

		if NVG then

			LA.Transparency = 0

			if LA:FindFirstChild("Beam") ~= nil then
				LA.Beam.Enabled = true
			end
		
		else

			if Player.Character and Player.Character:FindFirstChild('S'.. Arma.Name) ~= nil and Player.Character:WaitForChild('S'.. Arma.Name):WaitForChild('Grip'):FindFirstChild("Laser") ~= nil then
				if IR then
					LA.Transparency = 1
				else
					LA.Transparency = 0
				end
			end

			if LA:FindFirstChild("Beam") ~= nil then
				LA.Beam.Enabled = false
			end			

		end
		
	end

elseif Modo == 2 then
	if BulletModel:FindFirstChild(Player.Name.."_Laser") ~= nil then
		local LA = BulletModel:FindFirstChild(Player.Name.."_Laser")
		LA:Destroy()
	end
end
end
end)

function Launcher()
	if Settings.FireModes.Explosive == true then
		Character:WaitForChild('S'.. ArmaClone.Name):WaitForChild('Grip'):WaitForChild('Fire2'):Play()
		

		
	local M203 = Instance.new("Part")
	M203.Shape = 'Ball'
	M203.CanCollide = false
	M203.Size = Vector3.new(0.25,0.25,0.25)
	M203.Material = Enum.Material.Metal
	M203.Color = Color3.fromRGB(27, 42, 53)
	M203.Parent = BulletModel
	M203.CFrame = ArmaClone.SmokePart2.CFrame
	M203.Velocity = ArmaClone.SmokePart2.CFrame.lookVector*(600-196.2)


	local At1 = Instance.new("Attachment")
	At1.Name = "At1"
	At1.Position = Vector3.new(-.15,0,0)
	At1.Parent = M203
	
	local At2  = Instance.new("Attachment")
	At2.Name = "At2"
	At2.Position = Vector3.new(.15,0,0)
	At2.Parent = M203

	local Particles = Instance.new("Trail")
	Particles.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0, 0);
				NumberSequenceKeypoint.new(1, 1);
			}
		)
	Particles.WidthScale = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 2, 0);
				NumberSequenceKeypoint.new(1, 1);
			}
		)

	
	Particles.Texture = "rbxassetid://232918622"
	Particles.TextureMode = Enum.TextureMode.Stretch
	
	Particles.FaceCamera = true
	Particles.LightEmission = 0
	Particles.LightInfluence = 1
	Particles.Lifetime = 0.2
	Particles.Attachment0 = At1
	Particles.Attachment1 = At2
	Particles.Parent = M203


	local Hit2, Pos2, Norm2, Mat2
	local Hit, Pos, Norm, Mat
	local L_257_ = ArmaClone.SmokePart2.Position;
	local L_258_ = M203.Position;
	local L_260_ = false	
	local recast
	
	while true do
		RS.Heartbeat:wait()
		L_258_ = M203.Position;
	
		Hit2, Pos2, Norm2, Mat2 = workspace:FindPartOnRayWithIgnoreList(Ray.new(L_257_, (L_258_ - L_257_)*20), Ray_Ignore, false, true);

		Hit, Pos, Norm, Mat = workspace:FindPartOnRayWithIgnoreList(Ray.new(L_257_, (L_258_ - L_257_)), Ray_Ignore, false, true);
		
		if Hit2 then
			while not recast do
				if Hit2 and (Hit2 and Hit2.Transparency >= 1 or Hit2.CanCollide == false or Hit2.Name == "Ignorable" or Hit2.Name == "Glass" or Hit2.Parent.Name == "Top" or Hit2.Parent.Name == "Helmet" or Hit2.Parent.Name == "Up" or Hit2.Parent.Name == "Down" or Hit2.Parent.Name == "Face" or Hit2.Parent.Name == "Olho" or Hit2.Parent.Name == "Headset" or Hit2.Parent.Name == "Numero" or Hit2.Parent.Name == "Vest" or Hit2.Parent.Name == "Chest" or Hit2.Parent.Name == "Waist" or Hit2.Parent.Name == "Back" or Hit2.Parent.Name == "Belt" or Hit2.Parent.Name == "Leg1" or Hit2.Parent.Name == "Leg2" or Hit2.Parent.Name == "Arm1"  or Hit2.Parent.Name == "Arm2") and Hit2.Name ~= 'Right Arm' and Hit2.Name ~= 'Left Arm' and Hit2.Name ~= 'Right Leg' and Hit2.Name ~= 'Left Leg' and Hit2.Name ~= 'Armor' and Hit2.Name ~= 'EShield' then
					table.insert(Ray_Ignore, Hit2)
					recast = true
				end
	
				if recast then
					Hit2, Pos2, Norm2, Mat2 = workspace:FindPartOnRayWithIgnoreList(Ray.new(L_257_, (L_258_ - L_257_)*20), Ray_Ignore, false, true);
					Hit, Pos, Norm, Mat = workspace:FindPartOnRayWithIgnoreList(Ray.new(L_257_, (L_258_ - L_257_)), Ray_Ignore, false, true);
					recast = false
				else
					break
				end
			end
		end

			if Hit and not recast then
				Evt.LauncherHit:FireServer(Pos, Hit, Norm, Mat)
				Hitmarker.Explosion(Pos, Hit, Norm)
				M203:remove()

		local Hitmark = Instance.new("Attachment")
		Hitmark.CFrame = CFrame.new(Pos, Pos + Norm)
		Hitmark.Parent = workspace.Terrain
		Debris:AddItem(Hitmark, 5)

		local Exp = Instance.new("Explosion")
		Exp.BlastPressure = 0
		Exp.BlastRadius = Settings.LauncherRadius
		Exp.DestroyJointRadiusPercent = 0
		Exp.Position = Hitmark.Position
		Exp.Parent = Hitmark
		Exp.Visible = false
	
		Exp.Hit:connect(function(hitPart, partDistance)

  		local FoundHuman,VitimaHuman = CheckForHumanoid(hitPart)
			local damage = math.random(Settings.LauncherDamage[1],Settings.LauncherDamage[2])
    			if FoundHuman == true and VitimaHuman.Health > 0 then
    		  	  local distance_factor = partDistance / Exp.BlastRadius    -- get the distance as a value between 0 and 1
      		 		 distance_factor = 1 - distance_factor                         -- flip the amount, so that lower == closer == more damage
					if distance_factor > 0 then
						Evt.Damage:FireServer(VitimaHuman,(damage*distance_factor),0,0)
  					 end
				end
		end)
			
				break
			end
			L_257_ = L_258_;
		end
	end		
end

Evt.LauncherHit.OnClientEvent:Connect(function(Player, Position, HitPart, Normal)
	if Player ~= Jogador then 
		Hitmarker.Explosion(Position, HitPart, Normal)
	end
end)

Mouse.Button1Down:connect(function()
	if Equipped then
	MouseHeld = true

	
if Settings.Mode ~= "Explosive" then
	if slideback or not Chambered.Value == true or Emperrado.Value == true then
		ArmaClone.Handle.Click:Play()
		return
	end
elseif Settings.Mode == "Explosive" and GLChambered.Value == false or GLAmmo.Value <= 0 then
	ArmaClone.Handle.Click:Play()
	return	
end


	if Can_Shoot and not Reloading and not Safe and not Correndo then
	Can_Shoot = false
	if Settings.Mode == "Semi" and Ammo.Value > 0 and Emperrado.Value == false then
		Evt.Atirar:FireServer(FireRate,Anims,ArmaClient)
		for _ = 1, Settings.Bullets do
			coroutine.resume(coroutine.create(function()
			Balinha = CreateBullet(BSpread)
			CastRay(Balinha)
				end))
			end	
		recoil()
		Emperrar()
		if Emperrado.Value == false then
			--EjectShells()
		end
		Ammo.Value = Ammo.Value - 1

		if BSpread and not DecreasedAimLastShot then
				BSpread = math.min(Settings.MaxSpread, BSpread + Settings.AimInaccuracyStepAmount)
				RecoilPower =  math.min(Settings.MaxRecoilPower, RecoilPower + Settings.RecoilPowerStepAmount)
			end
			DecreasedAimLastShot = not DecreasedAimLastShot
			if BSpread >= Settings.MaxSpread then
				OverHeat = true
			end

		wait(FireRate)
	elseif Settings.Mode == "Auto" then
		while MouseHeld and Equipped and not Can_Shoot and Emperrado.Value == false and Ammo.Value > 0 do
			Evt.Atirar:FireServer(FireRate,Anims,ArmaClient)
			for _ = 1, Settings.Bullets do
			coroutine.resume(coroutine.create(function()
			Balinha = CreateBullet(BSpread)
			CastRay(Balinha)
			end))
			end		
			recoil()
			Emperrar()
			if Emperrado.Value == false then
			--EjectShells()
			end
			Ammo.Value = Ammo.Value - 1

			if BSpread and not DecreasedAimLastShot then
				BSpread = math.min(Settings.MaxSpread, BSpread + Settings.AimInaccuracyStepAmount)
				RecoilPower =  math.min(Settings.MaxRecoilPower, RecoilPower + Settings.RecoilPowerStepAmount)
			end
			DecreasedAimLastShot = not DecreasedAimLastShot
			if BSpread >= Settings.MaxSpread then
				OverHeat = true
			end

			wait(FireRate)
		end
	elseif Settings.Mode == "Burst" and Ammo.Value > 0 then
		for i = 1, Settings.BurstShot do
			for _ = 1, Settings.Bullets do
				if MouseHeld and Ammo.Value > 0 and Emperrado.Value == false then
					Evt.Atirar:FireServer(FireRate,Anims,ArmaClient)
					coroutine.resume(coroutine.create(function()
					Balinha = CreateBullet(BSpread)
					CastRay(Balinha)
					end))
					recoil()
					Emperrar()
					if Emperrado.Value == false then
					--EjectShells()
					end
					Ammo.Value = Ammo.Value - 1
				end
			end	

			if BSpread and not DecreasedAimLastShot then
				BSpread = math.min(Settings.MaxSpread, BSpread + Settings.AimInaccuracyStepAmount)
				RecoilPower =  math.min(Settings.MaxRecoilPower, RecoilPower + Settings.RecoilPowerStepAmount)
			end
			DecreasedAimLastShot = not DecreasedAimLastShot
			if BSpread >= Settings.MaxSpread then
				OverHeat = true
			end

			wait(BurstFireRate)
		end
		elseif Settings.Mode == "Bolt-Action" or Settings.Mode == "Pump-Action" and Ammo.Value > 0 and Emperrado.Value == false then
		Evt.Atirar:FireServer(FireRate,Anims,ArmaClient)
		for _ = 1, Settings.Bullets do


		coroutine.resume(coroutine.create(function()
		Balinha = CreateBullet(BSpread)
		CastRay(Balinha)
		end))
			end	
		recoil()
		if (Ammo.Value - 1) > 0 then
		Emperrado.Value = true
		end
		if Emperrado == false then
			--EjectShells()
		end
		Ammo.Value = Ammo.Value - 1
		if BSpread and not DecreasedAimLastShot then
				BSpread = math.min(Settings.MaxSpread, BSpread + Settings.AimInaccuracyStepAmount)
				RecoilPower =  math.min(Settings.MaxRecoilPower, RecoilPower + Settings.RecoilPowerStepAmount)
			end
			DecreasedAimLastShot = not DecreasedAimLastShot
			if BSpread >= Settings.MaxSpread then
				OverHeat = true
			end
		if (Settings.AutoChamber) then
		if Aiming and (Settings.ChamberWhileAim) then
			MouseHeld = false
			Can_Shoot = false
			Reloading = true
			ChamberAnim()
			Sprint()
			Can_Shoot = true
			Reloading = false
		elseif not Aiming then
			MouseHeld = false
			Can_Shoot = false
			Reloading = true
			ChamberAnim()
			Sprint()
			Can_Shoot = true
			Reloading = false
		end
		end
		wait(FireRate)



	elseif Settings.Mode == "Explosive" and GLAmmo.Value > 0 and GLChambered.Value == true and not Correndo then
		GLChambered.Value = false
		GLAmmo.Value = GLAmmo.Value - 1	
		coroutine.resume(coroutine.create(function()
		Launcher()
		end))
	end
	Can_Shoot = true
	Update_Gui()
	end
	end
end)

Mouse.Button1Up:connect(function()
	if Equipped then
		MouseHeld = false
	end
end)

Mouse.WheelForward:connect(function()
if Equipped and not Aiming and not Reloading and not Correndo then
	MouseHeld = false
	if stance == 0 then
		Safe = true
		stance = 1
		Evt.Stance:FireServer(stance,Settings,Anims)
		StanceUp()
	elseif stance == -1 then
		Safe = false
		stance = 0
		Evt.Stance:FireServer(stance,Settings,Anims)
		IdleAnim()
	elseif stance == -2 then
		Safe = true
		stance = -1
		Evt.Stance:FireServer(stance,Settings,Anims)
		StanceDown()
	end
	Update_Gui()
end

if Equipped and Aiming and Sens.Value < 100 then
	Sens.Value = Sens.Value + 5
	Update_Gui()
	game:GetService('UserInputService').MouseDeltaSensitivity = (Sens.Value/100)
end

end)

Mouse.WheelBackward:connect(function()
if Equipped and not Aiming and not Reloading and not Correndo then
	MouseHeld = false
	if stance == 0 then
		Safe = true
		stance = -1
		Evt.Stance:FireServer(stance,Settings,Anims)
		StanceDown()
	elseif stance == -1 then
		Safe = true
		stance = -2
		Evt.Stance:FireServer(stance,Settings,Anims)
		Patrol()
	elseif stance == 1 then
		Safe = false
		stance = 0
		Evt.Stance:FireServer(stance,Settings,Anims)
		IdleAnim()
	end
	Update_Gui()
end

if Equipped and Aiming and Sens.Value > 5 then
	Sens.Value = Sens.Value - 5
	Update_Gui()
	game:GetService('UserInputService').MouseDeltaSensitivity = (Sens.Value/100)
end

end)

Mouse.Button2Down:connect(function()
	if Equipped and stance > -2 and not Aiming and (Camera.Focus.p - Camera.CFrame.p).magnitude < 1 and not Correndo then
		if NVG and ArmaClone.AimPart:FindFirstChild("NVAim") ~= nil and Bipod then
		else
			if Safe then
				Safe = false
				IdleAnim()
				Update_Gui()
			end
			stance = 2
			Evt.Stance:FireServer(stance,Settings,Anims)
			Aiming = true
			game:GetService('UserInputService').MouseDeltaSensitivity = (Sens.Value/100)
			ArmaClone.Handle.AimDown:Play()

if not NVG or ArmaClone.AimPart:FindFirstChild("NVAim") == nil then
	if ArmaClone:FindFirstChild('AimPart2') ~= nil then
		if AimPartMode == 1 then
			tweenFoV(Settings.ChangeFOV[1],120)
			if Settings.FocusOnSight then
					TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.75),{ImageTransparency = 0}):Play()
				else
					TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.3),{ImageTransparency = 1}):Play()
				end
		elseif AimPartMode == 2 then
			tweenFoV(Settings.ChangeFOV[2],120)
			if Settings.FocusOnSight2 then
					TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.75),{ImageTransparency = 0}):Play()
				else
					TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.3),{ImageTransparency = 1}):Play()
				end
		end
	else
		if AimPartMode == 1 then
			tweenFoV(Settings.ChangeFOV[1],120)
			if Settings.FocusOnSight then
					TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.75),{ImageTransparency = 0}):Play()
				else
					TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.3),{ImageTransparency = 1}):Play()
				end
		elseif AimPartMode == 2 then
			tweenFoV(Settings.ChangeFOV[2],120)
			if Settings.FocusOnSight2 then
					TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.75),{ImageTransparency = 0}):Play()
				else
					TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.3),{ImageTransparency = 1}):Play()
				end
			end
		end
	else
		tweenFoV(70,120)
		TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.3),{ImageTransparency = 1}):Play()
	end
end
		elseif Aiming and Equipped  then
			stance = 0
			Evt.Stance:FireServer(stance,Settings,Anims)
			game:GetService('UserInputService').MouseDeltaSensitivity = 1
			ArmaClone.Handle.AimUp:Play()	
			tweenFoV(70,120)
			Aiming = false
			TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.3),{ImageTransparency = 1}):Play()
	end
end)
	
Human.Died:connect(function()
	ResetWorkspace()
	Human:UnequipTools()
	Evt.Rappel.CutEvent:FireServer()
	Unset()
end)


function onStateChanged(_,state)
	if state == Enum.HumanoidStateType.Swimming then
		Nadando = true
	if Equipped then
		Unset()
		Humanoid:UnequipTools()
	end
	else
		Nadando = false
	end

	if ServerConfig.EnableFallDamage then
		if state == Enum.HumanoidStateType.Freefall and not falling then
			falling = true
			local curVel = 0
			local peak = 0
			
			while falling do
				curVel = HumanoidRootPart.Velocity.magnitude
				peak = peak + 1
				wait()
			end
			local damage = (curVel - (ServerConfig.MaxVelocity)) * ServerConfig.DamageMult
			if damage > 5 and peak > 20 then
					local hurtSound = PastaFX.FallDamage:Clone()
					hurtSound.Parent = Player.PlayerGui
					hurtSound.Volume = damage/Human.MaxHealth
					hurtSound:Play()
					Debris:AddItem(hurtSound,hurtSound.TimeLength)
				Evt.Damage:FireServer(Human,damage,0,0)
			end
		elseif state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.Dead then
			falling = false
		end
	end
end

Evt.ServerBullet.OnClientEvent:Connect(function(SKP_arg1,SKP_arg3,SKP_arg4,SKP_arg5,SKP_arg6,SKP_arg7,SKP_arg8,SKP_arg9,SKP_arg10,SKP_arg11,SKP_arg12)
if SKP_arg1 ~= Jogador and SKP_arg1.Character then 
local SKP_01 = SKP_arg3
	local SKP_02 = Instance.new("Part")
	SKP_02.Parent = workspace.ACS_WorkSpace.Server
	SKP_02.Name = SKP_arg1.Name..'_Bullet'
	Debris:AddItem(SKP_02, 5)
	SKP_02.Shape = "Ball"
	SKP_02.Size = Vector3.new(1, 1, 1)
	SKP_02.CanCollide = false
	SKP_02.CFrame = SKP_01
	SKP_02.Transparency = 1

	local SKP_03 = SKP_02:GetMass()
	local SKP_04 = Instance.new('BodyForce', SKP_02)
	
	SKP_04.Force = Vector3.new(0,SKP_03 * (196.2) - SKP_arg5 * (196.2), 0)
	SKP_02.Velocity = SKP_arg7 * SKP_arg6

	local SKP_05 = Instance.new('Attachment', SKP_02)
	SKP_05.Position = Vector3.new(0.1, 0, 0)
	local SKP_06 = Instance.new('Attachment', SKP_02)
	SKP_06.Position = Vector3.new(-0.1, 0, 0)

	
	if SKP_arg4 then
		local SKP_07 = Instance.new('Trail', SKP_02)
		SKP_07.Attachment0 = SKP_05
		SKP_07.Attachment1 = SKP_06
		SKP_07.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0, 0);
				NumberSequenceKeypoint.new(1, 1);
			}
		)
		SKP_07.WidthScale = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 2, 0);
				NumberSequenceKeypoint.new(1, 0);
			}
		)
		SKP_07.Texture = "rbxassetid://232918622"
		SKP_07.TextureMode = Enum.TextureMode.Stretch
		SKP_07.LightEmission = 1
		SKP_07.Lifetime = 0.2
		SKP_07.FaceCamera = true
		SKP_07.Color = ColorSequence.new(SKP_arg8)
	end

	if SKP_arg10 then
	local SKP_08 = Instance.new("BillboardGui", SKP_02)
		SKP_08.Adornee = SKP_02
		local SKP_09 = math.random(375, 475)/10
		SKP_08.Size = UDim2.new(SKP_09, 0, SKP_09, 0)
		SKP_08.LightInfluence = 0
		local SKP_010 = Instance.new("ImageLabel", SKP_08)
		SKP_010.BackgroundTransparency = 1
		SKP_010.Size = UDim2.new(1, 0, 1, 0)
		SKP_010.Position = UDim2.new(0, 0, 0, 0)
		SKP_010.Image = "http://www.roblox.com/asset/?id=1047066405"
		SKP_010.ImageColor3 = SKP_arg11

		SKP_010.ImageTransparency = math.random(2, 5)/15
		
		if SKP_02:FindFirstChild("BillboardGui") ~= nil then
			SKP_02.BillboardGui.Enabled = true
		end
	end

	local SKP_011 = {SKP_arg1.Character,SKP_02,workspace.ACS_WorkSpace}
	while true do
		RS.Heartbeat:wait()
		local SKP_012 = Ray.new(SKP_02.Position, SKP_02.CFrame.LookVector*25)
		local SKP_013, SKP_014 = workspace:FindPartOnRayWithIgnoreList(SKP_012, SKP_011, false, true)
		if SKP_013 then
			game.Debris:AddItem(SKP_02,0)
			break
		end
	end
	game.Debris:AddItem(SKP_02,0)
	return SKP_02
end
end)

Human.StateChanged:connect(onStateChanged)

Evt.ACS_AI.AIBullet.OnClientEvent:Connect(function(SKP_arg1,SKP_arg3,SKP_arg4,SKP_arg5,SKP_arg6,SKP_arg7,SKP_arg8,SKP_arg9,SKP_arg10,SKP_arg11,SKP_arg12)
if SKP_arg1 ~= Jogador then 
local SKP_01 = SKP_arg3
	local SKP_02 = Instance.new("Part")
	SKP_02.Parent = workspace.ACS_WorkSpace.Server
	SKP_02.Name = "AI_Bullet"
	Debris:AddItem(SKP_02, 5)
	SKP_02.Shape = "Ball"
	SKP_02.Size = Vector3.new(1, 1, 1)
	SKP_02.CanCollide = false
	SKP_02.CFrame = SKP_01
	SKP_02.Transparency = 1

	local SKP_03 = SKP_02:GetMass()
	local SKP_04 = Instance.new('BodyForce', SKP_02)
	
	SKP_04.Force = Vector3.new(0,SKP_03 * (196.2) - SKP_arg5 * (196.2), 0)
	SKP_02.Velocity = SKP_arg7 * SKP_arg6

	local SKP_05 = Instance.new('Attachment', SKP_02)
	SKP_05.Position = Vector3.new(0.1, 0, 0)
	local SKP_06 = Instance.new('Attachment', SKP_02)
	SKP_06.Position = Vector3.new(-0.1, 0, 0)

	
	if SKP_arg4 then
		local SKP_07 = Instance.new('Trail', SKP_02)
		SKP_07.Attachment0 = SKP_05
		SKP_07.Attachment1 = SKP_06
		SKP_07.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0, 0);
				NumberSequenceKeypoint.new(1, 1);
			}
		)
		SKP_07.WidthScale = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 2, 0);
				NumberSequenceKeypoint.new(1, 0);
			}
		)
		SKP_07.Texture = "rbxassetid://232918622"
		SKP_07.TextureMode = Enum.TextureMode.Stretch
		SKP_07.LightEmission = 1
		SKP_07.Lifetime = 0.2
		SKP_07.FaceCamera = true
		SKP_07.Color = ColorSequence.new(SKP_arg8)
	end

	if SKP_arg10 then
	local SKP_08 = Instance.new("BillboardGui", SKP_02)
		SKP_08.Adornee = SKP_02
		local SKP_09 = math.random(375, 475)/10
		SKP_08.Size = UDim2.new(SKP_09, 0, SKP_09, 0)
		SKP_08.LightInfluence = 0
		local SKP_010 = Instance.new("ImageLabel", SKP_08)
		SKP_010.BackgroundTransparency = 1
		SKP_010.Size = UDim2.new(1, 0, 1, 0)
		SKP_010.Position = UDim2.new(0, 0, 0, 0)
		SKP_010.Image = "http://www.roblox.com/asset/?id=1047066405"
		SKP_010.ImageColor3 = SKP_arg11

		SKP_010.ImageTransparency = math.random(2, 5)/15
		
		if SKP_02:FindFirstChild("BillboardGui") ~= nil then
			SKP_02.BillboardGui.Enabled = true
		end
	end

	local SKP_011 = {SKP_02,workspace.ACS_WorkSpace}
	while true do
		RS.Heartbeat:wait()
		local SKP_012 = Ray.new(SKP_02.Position, SKP_02.CFrame.LookVector*25)
		local SKP_013, SKP_014 = workspace:FindPartOnRayWithIgnoreList(SKP_012, SKP_011, false, true)
		if SKP_013 then
			game.Debris:AddItem(SKP_02,0)
			break
		end
	end
	game.Debris:AddItem(SKP_02,0)
	return SKP_02
end
end)

Evt.ACS_AI.AIShoot.OnClientEvent:Connect(function(Gun)

	for _, v in pairs(Gun.Muzzle:GetChildren()) do
				if v.Name:sub(1, 7) == "FlashFX" or v.Name:sub(1, 7) == "Smoke" then
					v.Enabled = true
					end
				end

		delay(1 / 30, function()

			for _, v in pairs(Gun.Muzzle:GetChildren()) do
				if v.Name:sub(1, 7) == "FlashFX" or v.Name:sub(1, 7) == "Smoke" then
					v.Enabled = false
				end
			end
		end)		
	
end)

----------------------------------------------------------------------------------------------
------------------------------------[TECLAS]--------------------------------------------------
----------------------------------------------------------------------------------------------

local Laserdebounce = false

Mouse.KeyDown:connect(function(key)
if (key == "v") and Equipped and Settings.FireModes.ChangeFiremode  then
ArmaClone.Handle.SafetyClick:Play()
---Semi Settings---		
			if Settings.Mode == "Semi" and Settings.FireModes.Burst == true then
				Gui.FText.Text = "Burst"
				Settings.Mode = "Burst"
			elseif Settings.Mode == "Semi" and Settings.FireModes.Burst == false and Settings.FireModes.Auto == true then
				Gui.FText.Text = "Auto"
				Settings.Mode = "Auto"
			elseif Settings.Mode == "Semi" and Settings.FireModes.Burst == false and Settings.FireModes.Auto == false and Settings.FireModes.Explosive == true then
				Gui.FText.Text = "Explosive"
				Settings.Mode = "Explosive"
---Burst Settings---
			elseif Settings.Mode == "Burst" and Settings.FireModes.Auto == true then
				Gui.FText.Text = "Auto"
				Settings.Mode = "Auto"
			elseif Settings.Mode == "Burst" and Settings.FireModes.Explosive == true and Settings.FireModes.Auto == false then
				Gui.FText.Text = "Explosive"
				Settings.Mode = "Explosive"
			elseif Settings.Mode == "Burst" and Settings.FireModes.Semi == true and Settings.FireModes.Auto == false and Settings.FireModes.Explosive == false then
				Gui.FText.Text = "Semi"
				Settings.Mode = "Semi"
---Auto Settings---
			elseif Settings.Mode == "Auto" and Settings.FireModes.Explosive == true then
				Gui.FText.Text = "Explosive"
				Settings.Mode = "Explosive"
			elseif Settings.Mode == "Auto" and Settings.FireModes.Semi == true and Settings.FireModes.Explosive == false then
				Gui.FText.Text = "Semi"
				Settings.Mode = "Semi"
			elseif Settings.Mode == "Auto" and Settings.FireModes.Semi == false and Settings.FireModes.Burst == true and Settings.FireModes.Explosive == false then
				Gui.FText.Text = "Burst"
				Settings.Mode = "Burst"
---Explosive Settings---
			elseif Settings.Mode == "Explosive" and Settings.FireModes.Semi == true then
				Gui.FText.Text = "Semi"
				Settings.Mode = "Semi"
			elseif Settings.Mode == "Explosive" and Settings.FireModes.Semi == false and Settings.FireModes.Burst == true  then
				Gui.FText.Text = "Burst"
				Settings.Mode = "Burst"
			elseif Settings.Mode == "Explosive" and Settings.FireModes.Semi == false and Settings.FireModes.Burst == false and Settings.FireModes.Auto == true then
				Gui.FText.Text = "Auto"
				Settings.Mode = "Auto"
			end
		Update_Gui()
end
if (key == "t") and Equipped and (not NVG or ArmaClone.AimPart:FindFirstChild("NVAim") == nil) then
	if Aiming then
		if ArmaClone:FindFirstChild("AimPart2") ~= nil then
			if AimPartMode == 1 then
				AimPartMode = 2
				tweenFoV(Settings.ChangeFOV[2],120)
				if Settings.FocusOnSight2 and Aiming then
					TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.75),{ImageTransparency = 0}):Play()
				else
					TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.3),{ImageTransparency = 1}):Play()
				end
				if Settings.ZoomAnim then
					ZoomAnim()
					Sprint()
				end
			elseif AimPartMode == 2 then
				AimPartMode = 1
				tweenFoV(Settings.ChangeFOV[1],120)
				if Settings.FocusOnSight and Aiming then
					TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.75),{ImageTransparency = 0}):Play()
				else
					TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.3),{ImageTransparency = 1}):Play()
				end
				if Settings.ZoomAnim then
					UnZoomAnim()
					Sprint()
				end
			end
		else
			if AimPartMode == 1 then
				AimPartMode = 2
				tweenFoV(Settings.ChangeFOV[2], 120)
				if Settings.FocusOnSight2 and Aiming then
					TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.75),{ImageTransparency = 0}):Play()
				else
					TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.3),{ImageTransparency = 1}):Play()
				end
				if Settings.ZoomAnim then
					ZoomAnim()
					Sprint()
				end
			elseif AimPartMode == 2 then
				AimPartMode = 1
				tweenFoV(Settings.ChangeFOV[1], 120)
				if Settings.FocusOnSight and Aiming then
					TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.75),{ImageTransparency = 0}):Play()
				else
					TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.3),{ImageTransparency = 1}):Play()
				end
				if Settings.ZoomAnim then
					UnZoomAnim()
					Sprint()
				end
			end
		end
	else
		if AimPartMode == 1 then
			AimPartMode = 2
			if Settings.FocusOnSight2 and Aiming then
					TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.75),{ImageTransparency = 0}):Play()
				else
					TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.3),{ImageTransparency = 1}):Play()
				end
			if Settings.ZoomAnim then
				ZoomAnim()
				Sprint()
			end
		elseif AimPartMode == 2 then
			AimPartMode = 1
			if Settings.FocusOnSight and Aiming then
					TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.75),{ImageTransparency = 0}):Play()
				else
					TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.3),{ImageTransparency = 1}):Play()
				end
			if Settings.ZoomAnim then
				UnZoomAnim()
				Sprint()
			end
		end
	end
end
if (key == "[") and Equipped then
	if Zeroing.Value > Zeroing.MinValue then
		Zeroing.Value = Zeroing.Value - 50
		ArmaClone.Handle.Click:play()
		Update_Gui()
	end
end
if (key == "]" ) and Equipped then
	if Zeroing.Value < Zeroing.MaxValue then
		Zeroing.Value = Zeroing.Value + 50
		ArmaClone.Handle.Click:play()
		Update_Gui()
	end
end
if (key == "r") and Equipped and stance > -2 then
   CancelReload = false
	if StoredAmmo.Value > 0  and Settings.Mode ~= "Explosive" and not Reloading and Settings.ReloadType == 1 then
			if Settings.IncludeChamberedBullet and Ammo.Value == Settings.Ammo + 1 or not Settings.IncludeChamberedBullet and Ammo.Value == Settings.Ammo and Chambered.Value == true then
				return
			end
			MouseHeld = false
			Can_Shoot = false
			Reloading = true	
			if Safe then
				Safe = false
				stance = 0
				Evt.Stance:FireServer(stance,Settings,Anims)
				IdleAnim()
				Update_Gui()
				wait(.25)
			end
				ReloadAnim()	
				if Chambered.Value == false and slideback == true and Settings.FastReload == true then
					ChamberBKAnim()
				elseif Chambered.Value == false and slideback == false and Settings.FastReload == true then
					ChamberAnim()
				end
				Sprint()		
			Update_Gui()
			Can_Shoot = true
			Reloading = false

		elseif StoredAmmo.Value > 0  and Settings.Mode ~= "Explosive" and not Reloading and Settings.ReloadType == 2 then
			if Settings.IncludeChamberedBullet and Ammo.Value == Settings.Ammo + 1 or not Settings.IncludeChamberedBullet and Ammo.Value == Settings.Ammo and Chambered.Value == true or CancelReload then
				Sprint()
				Update_Gui()
				return
			end
				MouseHeld = false
				Can_Shoot = false
				Reloading = true	
			if Safe then
				Safe = false
				stance = 0
				Evt.Stance:FireServer(stance)
				Sprint()
				Update_Gui()
				wait(.25)
			end
				for i = 1,Settings.Ammo - Ammo.Value do
				if StoredAmmo.Value > 0 and not CancelReload and Ammo.Value < Settings.Ammo and not AnimDebounce then
					ShellInsertAnim()			
				end
				end
			if Chambered.Value == false and slideback == true and Settings.FastReload == true then
				ChamberBKAnim()
			elseif Chambered.Value == false and slideback == false and Settings.FastReload == true then
				ChamberAnim()
			end
			Update_Gui()
			Sprint()
			CancelReload = false
			Can_Shoot = true
			Reloading = false

		elseif StoredAmmo.Value > 0  and Settings.Mode ~= "Explosive" and Reloading and Settings.ReloadType == 2 and AnimDebounce then
			if not CancelReload then
					CancelReload = true
					Sprint()
					Update_Gui()
					wait(.25)
				end
		elseif not Reloading and GLAmmo.Value > 0 and Settings.Mode == "Explosive"  and GLChambered.Value == false then
			MouseHeld = false
			Can_Shoot = false
			Reloading = true
				GLReloadAnim()
				GLChambered.Value = true
			Sprint()
			Update_Gui()
			Can_Shoot = true
			Reloading = false
	end
end
if (key == "f") and Equipped and not Reloading and stance > -2  then
			MouseHeld = false
			Can_Shoot = false
			Reloading = true

			if Safe then
				Safe = false
				stance = 0
				Evt.Stance:FireServer(stance,Settings,Anims)
				IdleAnim()
				Update_Gui()
				--wait(.25)
			end

			if not slideback then
				ChamberAnim()
			else
				ChamberBKAnim()
			end	
			Sprint()			
			Update_Gui()		
			Can_Shoot = true
			Reloading = false
end
if (key == "m") and Equipped and Settings.CanCheckMag and not Reloading and stance > -2 then
			MouseHeld = false
			Can_Shoot = false
			Reloading = true

			if Safe then
				Safe = false
				stance = 0
				Evt.Stance:FireServer(stance,Settings,Anims)
				IdleAnim()
				Update_Gui()
				--wait(.25)
			end
			CheckAnim()
			Sprint()			
			Update_Gui()		
			Can_Shoot = true
			Reloading = false
end
if (key == "h") and Equipped and ArmaClone:FindFirstChild("LaserPoint") then


	if ServerConfig.RealisticLaser and ArmaClone.LaserPoint:FindFirstChild("IR") ~= nil then
		if not LaserAtivo and not IRmode then
			LaserAtivo = not LaserAtivo
			IRmode = not IRmode

			if LaserAtivo then

				Evt.SVLaser:FireServer(Vector3.new(0,0,0),1,ArmaClone.LaserPoint.Color,ArmaClient)
				Pointer = Instance.new('Part')
				Pointer.Shape = 'Ball'
				Pointer.Size = Vector3.new(0.2, 0.2, 0.2)
				Pointer.Parent = ArmaClone.LaserPoint
				Pointer.CanCollide = false
				Pointer.Color = ArmaClone.LaserPoint.Color
				Pointer.Material = Enum.Material.Neon
				
				if ArmaClone.LaserPoint:FindFirstChild("IR") ~= nil then
					Pointer.Transparency = 1
				end
				
				LaserSP = Instance.new('Attachment')
				LaserSP.Parent = ArmaClone.LaserPoint				

				LaserEP = Instance.new('Attachment')
				LaserEP.Parent = ArmaClone.LaserPoint
				
				Laser = Instance.new('Beam')
				Laser.Parent = ArmaClone.LaserPoint
				Laser.Transparency = NumberSequence.new(0)
				Laser.LightEmission = 1
				Laser.LightInfluence = 0
				Laser.Attachment0 = LaserSP
				Laser.Attachment1 = LaserEP
				Laser.Color = ColorSequence.new(ArmaClone.LaserPoint.Color,IRmode)
				Laser.FaceCamera = true
				Laser.Width0 = 0.01
				Laser.Width1 = 0.01

				if ServerConfig.RealisticLaser then
					Laser.Enabled = false
				end

			else
				Evt.SVLaser:FireServer(Vector3.new(0,0,0),2,nil,ArmaClient,IRmode)
				Pointer:Destroy()
				LaserSP:Destroy()
				LaserEP:Destroy()
				Laser:Destroy()
			end

			elseif LaserAtivo and IRmode then
			IRmode = not IRmode
		elseif LaserAtivo and not IRmode then
			LaserAtivo = not LaserAtivo

			if LaserAtivo then

				Evt.SVLaser:FireServer(Vector3.new(0,0,0),1,ArmaClone.LaserPoint.Color,ArmaClient)
				Pointer = Instance.new('Part')
				Pointer.Shape = 'Ball'
				Pointer.Size = Vector3.new(0.2, 0.2, 0.2)
				Pointer.Parent = ArmaClone.LaserPoint
				Pointer.CanCollide = false
				Pointer.Color = ArmaClone.LaserPoint.Color
				Pointer.Material = Enum.Material.Neon
				
				if ArmaClone.LaserPoint:FindFirstChild("IR") ~= nil then
					Pointer.Transparency = 1
				end
				
				LaserSP = Instance.new('Attachment')
				LaserSP.Parent = ArmaClone.LaserPoint				

				LaserEP = Instance.new('Attachment')
				LaserEP.Parent = ArmaClone.LaserPoint
				
				Laser = Instance.new('Beam')
				Laser.Parent = ArmaClone.LaserPoint
				Laser.Transparency = NumberSequence.new(0)
				Laser.LightEmission = 1
				Laser.LightInfluence = 0
				Laser.Attachment0 = LaserSP
				Laser.Attachment1 = LaserEP
				Laser.Color = ColorSequence.new(ArmaClone.LaserPoint.Color,IRmode)
				Laser.FaceCamera = true
				Laser.Width0 = 0.01
				Laser.Width1 = 0.01

				if ServerConfig.RealisticLaser then
					Laser.Enabled = false
				end

			else
				Evt.SVLaser:FireServer(Vector3.new(0,0,0),2,nil,ArmaClient,IRmode)
				Pointer:Destroy()
				LaserSP:Destroy()
				LaserEP:Destroy()
				Laser:Destroy()
			end


		end
	else
		LaserAtivo = not LaserAtivo

		if LaserAtivo then

				Evt.SVLaser:FireServer(Vector3.new(0,0,0),1,ArmaClone.LaserPoint.Color,ArmaClient)
				Pointer = Instance.new('Part')
				Pointer.Shape = 'Ball'
				Pointer.Size = Vector3.new(0.2, 0.2, 0.2)
				Pointer.Parent = ArmaClone.LaserPoint
				Pointer.CanCollide = false
				Pointer.Color = ArmaClone.LaserPoint.Color
				Pointer.Material = Enum.Material.Neon
				
				if ArmaClone.LaserPoint:FindFirstChild("IR") ~= nil then
					Pointer.Transparency = 1
				end
				
				LaserSP = Instance.new('Attachment')
				LaserSP.Parent = ArmaClone.LaserPoint				

				LaserEP = Instance.new('Attachment')
				LaserEP.Parent = ArmaClone.LaserPoint
				
				Laser = Instance.new('Beam')
				Laser.Parent = ArmaClone.LaserPoint
				Laser.Transparency = NumberSequence.new(0)
				Laser.LightEmission = 1
				Laser.LightInfluence = 0
				Laser.Attachment0 = LaserSP
				Laser.Attachment1 = LaserEP
				Laser.Color = ColorSequence.new(ArmaClone.LaserPoint.Color,IRmode)
				Laser.FaceCamera = true
				Laser.Width0 = 0.01
				Laser.Width1 = 0.01

				if ServerConfig.RealisticLaser then
					Laser.Enabled = false
				end

			else
				Evt.SVLaser:FireServer(Vector3.new(0,0,0),2,nil,ArmaClient,IRmode)
				Pointer:Destroy()
				LaserSP:Destroy()
				LaserEP:Destroy()
				Laser:Destroy()
			end

	end
	ArmaClone.Handle.Click:play()


end
if (key == "j") and Equipped and ArmaClone:FindFirstChild("FlashPoint") then
	LanternaAtiva = not LanternaAtiva
	ArmaClone.Handle.Click:play()
			if LanternaAtiva then
				Evt.SVFlash:FireServer(true,ArmaClient,ArmaClone.FlashPoint.Light.Angle,ArmaClone.FlashPoint.Light.Brightness,ArmaClone.FlashPoint.Light.Color,ArmaClone.FlashPoint.Light.Range)
				ArmaClone.FlashPoint.Light.Enabled = true
			else
				Evt.SVFlash:FireServer(false,ArmaClient,nil,nil,nil,nil)
				ArmaClone.FlashPoint.Light.Enabled = false
			end
end
if (key == "u") and Equipped and ArmaClone:FindFirstChild("Silenciador") then
	Silencer.Value = not Silencer.Value
	ArmaClone.Handle.Click:play()
			if Silencer.Value == true then
				ArmaClone.Silenciador.Transparency = 0
				ArmaClone.SmokePart.FlashFX.Brightness = 0
				ArmaClone.SmokePart:FindFirstChild("FlashFX[Flash]").Rate = 0

				Evt.SilencerEquip:FireServer(ArmaClient,Silencer.Value)
				
			else
				ArmaClone.Silenciador.Transparency = 1
				ArmaClone.SmokePart.FlashFX.Brightness = 5
				ArmaClone.SmokePart:FindFirstChild("FlashFX[Flash]").Rate = 1000

				Evt.SilencerEquip:FireServer(ArmaClient,Silencer.Value)
			end
end
if (key == "b") and Equipped and BipodEnabled and ArmaClone:FindFirstChild("BipodPoint") then
	Bipod = not Bipod
	if Bipod == true then
		if ArmaClone.BipodPoint:FindFirstChild("BipodDeploy") ~= nil then
			ArmaClone.BipodPoint.BipodDeploy:play()
		end
	else
		if ArmaClone.BipodPoint:FindFirstChild("BipodRetract") ~= nil then
			ArmaClone.BipodPoint.BipodRetract:play()
		end
	end
end
if (key == "n") and Laserdebounce == false then

		if Player.Character then
		local helmet = Player.Character:FindFirstChild("Helmet")
		if helmet then
			local nvg = helmet:FindFirstChild("Up")
			if nvg then
				Laserdebounce = true
				delay(.8,function()
					NVG = not NVG 

		if Aiming and ArmaClone.AimPart:FindFirstChild("NVAim") ~= nil then
		if NVG then
			tweenFoV(70,120)
			TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.3),{ImageTransparency = 1}):Play()
		else
			if AimPartMode == 1 then
			tweenFoV(Settings.ChangeFOV[1],120)
			if Settings.FocusOnSight then
					TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.75),{ImageTransparency = 0}):Play()
				else
					TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.3),{ImageTransparency = 1}):Play()
				end
		elseif AimPartMode == 2 then
			tweenFoV(Settings.ChangeFOV[2],120)
			if Settings.FocusOnSight2 then
					TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.75),{ImageTransparency = 0}):Play()
				else
					TS:Create(StatusClone.Efeitos.Aim,TweenInfo.new(.3),{ImageTransparency = 1}):Play()
				end
			end
		end
	end	
	Laserdebounce = false		
end)
			
				end
			end
		end
	end
end)


--//Client Anims
local Speedo

function IdleAnim(L_442_arg1)
	Anims.IdleAnim(Character, Speedo, {
		AnimBaseW,
		RA,
		LA,
		AnimBase.GripW,
		ArmaClone,
		Left_Weld,
		Right_Weld,
	});
end;

function StanceDown(L_442_arg1)
	Anims.StanceDown(Character, Speedo, {
		AnimBaseW,
		RA,
		LA,
		AnimBase.GripW,
		ArmaClone,
		Left_Weld,
		Right_Weld,
	});
end;

function StanceUp(L_442_arg1)
	Anims.StanceUp(Character, Speedo, {
		AnimBaseW,
		RA,
		LA,
		AnimBase.GripW,
		ArmaClone,
		Left_Weld,
		Right_Weld,
	});
end;

function Patrol(L_442_arg1)
	Anims.Patrol(Character, Speedo, {
		AnimBaseW,
		RA,
		LA,
		AnimBase.GripW,
		ArmaClone,
		Left_Weld,
		Right_Weld,
	});
end;

function SprintAnim(L_442_arg1)
	Anims.SprintAnim(Character, Speedo, {
		AnimBaseW,
		RA,
		LA,
		AnimBase.GripW,
		ArmaClone,
		Left_Weld,
		Right_Weld,
	});
end;

function EquipAnim(L_442_arg1)
AnimDebounce = true
	Can_Shoot = false
	Reloading = true
	Anims.EquipAnim(Character, Speedo, {
		AnimBaseW,
		RA,
		LA,
		AnimBase.GripW,
		ArmaClone,
		Left_Weld,
		Right_Weld,
	});
	Reloading = false
	Can_Shoot = true
AnimDebounce = false
end;

function ChamberAnim(L_442_arg1)
AnimDebounce = true
	Anims.ChamberAnim(Character, Speedo, {
		AnimBaseW,
		RA,
		LA,
		AnimBase.GripW,
		ArmaClone,
		Settings,
		Right_Weld,
		Left_Weld,
	});
		if Ammo.Value > 0 and Chambered.Value ==true and Emperrado.Value == true then
			Emperrado.Value = false
		elseif Ammo.Value > 0 and Chambered.Value == true and Emperrado.Value == false then
			Ammo.Value = Ammo.Value - 1
		end
		slideback = false
		if Ammo.Value > 0 then
			Chambered.Value = true
		end
AnimDebounce = false
end;

function ZoomAnim(L_442_arg1)
	Anims.ZoomAnim(Character, Speedo, {
		AnimBaseW,
		RA,
		LA,
		AnimBase.GripW,
		ArmaClone,
		Settings,
		Left_Weld,
		Right_Weld,
	});
end;

function UnZoomAnim(L_442_arg1)
	Anims.UnZoomAnim(Character, Speedo, {
		AnimBaseW,
		RA,
		LA,
		AnimBase.GripW,
		ArmaClone,
		Settings,
		Left_Weld,
		Right_Weld,
	});
end;

function ChamberBKAnim(L_442_arg1)
AnimDebounce = true
	Anims.ChamberBKAnim(Character, Speedo, {
		AnimBaseW,
		RA,
		LA,
		AnimBase.GripW,
		ArmaClone,
		Settings,
		Left_Weld,
		Right_Weld,
	});
		slideback = false
		if Ammo.Value > 0 then
			Chambered.Value = true
		end
AnimDebounce = false
end;

function CheckAnim(L_442_arg1)
AnimDebounce = true
	CheckMagFunction()
	Anims.CheckAnim(Character, Speedo, {
		AnimBaseW,
		RA,
		LA,
		AnimBase.GripW,
		ArmaClone,
		StoredAmmo,
		Ammo,
		Settings,
		Chambered,
		Left_Weld,
		Right_Weld,
	});
AnimDebounce = false
end;

function ShellInsertAnim(L_442_arg1)
AnimDebounce = true
	Anims.ShellInsertAnim(Character, Speedo, {
		AnimBaseW,
		RA,
		LA,
		AnimBase.GripW,
		ArmaClone,
		StoredAmmo,
		Ammo,
		Settings,
		Chambered,
		Left_Weld,
		Right_Weld,
	});
Evt.Recarregar:FireServer(StoredAmmo.Value,ArmaClient)
AnimDebounce = false
end;

function ReloadAnim(L_442_arg1)
AnimDebounce = true
	Anims.ReloadAnim(Character, Speedo, {
		AnimBaseW,
		RA,
		LA,
		AnimBase.GripW,
		ArmaClone,
		StoredAmmo,
		Ammo,
		Settings,
		Chambered,
		Left_Weld,
		Right_Weld,
	});
Evt.Recarregar:FireServer(StoredAmmo.Value,ArmaClient)
AnimDebounce = false
end;

function GLReloadAnim(L_442_arg1)
AnimDebounce = true
	Anims.GLReloadAnim(Character, Speedo, {
		AnimBaseW,
		RA,
		LA,
		AnimBase.GripW,
		ArmaClone,
		StoredAmmo,
		Ammo,
		Settings,
		Chambered,
		Left_Weld,
		Right_Weld,
	});
Evt.Recarregar:FireServer(StoredAmmo.Value,ArmaClient)
AnimDebounce = false
end;

------------------------------------------------------------
--\Doors Update
------------------------------------------------------------
local DoorsFolder = ACS_Storage:FindFirstChild("Doors")
local CAS = game:GetService("ContextActionService")

local mDistance = 5
local Key = nil

function getNearest()
	local nearest = nil
	local minDistance = mDistance
	local Character = Player.Character or Player.CharacterAdded:Wait()
	
	for I,Door in pairs (DoorsFolder:GetChildren()) do
		if Door.Door:FindFirstChild("Knob") ~= nil then
			local distance = (Door.Door.Knob.Position - Character.Torso.Position).magnitude
		
			if distance < minDistance then
				nearest = Door
				minDistance = distance
			end
		end
	end
	--print(nearest)
	return nearest
end

function Interact(actionName, inputState, inputObj)
	if inputState ~= Enum.UserInputState.Begin then return end
	
	local nearestDoor = getNearest()
	local Character = Player.Character or Player.CharacterAdded:Wait()
	
	if nearestDoor == nil then return end
	
	if (nearestDoor.Door.Knob.Position - Character.Torso.Position).magnitude <= mDistance then
		if nearestDoor ~= nil then
			if nearestDoor:FindFirstChild("RequiresKey") then
				Key = nearestDoor.RequiresKey.Value
			else
				Key = nil
			end
			Evt.DoorEvent:FireServer(nearestDoor,1,Key)
		end
	end
end


function GetNearest(parts, maxDistance,Part)
	local closestPart
	local minDistance = maxDistance
    for _, partToFace in ipairs(parts) do
        local distance = (Part.Position - partToFace.Position).magnitude
        if distance < minDistance then
            closestPart = partToFace
            minDistance = distance
        end
   end
	return closestPart
end

CAS:BindAction("Interact", Interact, false, Enum.KeyCode.G)

Evt.Rappel.PlaceEvent.OnClientEvent:Connect(function(Parte)
	local Alinhar = Instance.new('AlignOrientation')
	Alinhar.Parent = Parte
	Alinhar.PrimaryAxisOnly = true
	Alinhar.RigidityEnabled = true
	Alinhar.Attachment0 = Character.HumanoidRootPart.RootAttachment
	Alinhar.Attachment1 = Camera.BasePart.Attachment
end)

print("ACS 1.7.5")
