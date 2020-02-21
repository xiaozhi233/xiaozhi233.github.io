SWEP.PrintName = "Chair Shooter"
SWEP.Author = "Duck1yX64"
SWEP.Instructions = "Right mouse to shoot chairs!Left mouse to shoot bullets!"
SWEP.Category = "Duck1yX64's Addons"

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.UseHands = true

SWEP.Primary.ClipSize = 1000
SWEP.Primary.DefaultClip = 8000
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "ar2"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

ShootSound = Sound("Metal.SawbladeStick")

function SWEP:PrimaryAttack()
	if self:Clip1() <= 0 then 
		self:EmitSound("weapons/pistol/pistol_empty.wav")
		return 
	end
	self.Weapon:SetNextPrimaryFire(CurTime()+0.1)
	local bullet = {}
	bullet.Num	= 50
	bullet.Src	= self.Owner:GetShootPos()
	bullet.Dir	= self.Owner:GetAimVector()
	bullet.Spread	= Vector( 0.05, 0.05, 0 )
	bullet.Tracer	= 1
	bullet.Force	= 1
	bullet.TracerName = "Tracer"
	bullet.Damage	= 99999999
	bullet.AmmoType = self.Primary.Ammo
	bullet.HullSize = 1
	self.Owner:FireBullets(bullet)
	self:TakePrimaryAmmo(50)
	self:EmitSound("weapons/airboat/airboat_gun_energy2.wav")
end

function SWEP:SecondaryAttack()
	if self:Clip1() <= 0 then 
		self:EmitSound("weapons/pistol/pistol_empty.wav")
		return 
	end
	self.Weapon:SetNextSecondaryFire(CurTime()+0.1)
	self:ThrowChair("models/props_c17/FurnitureChair001a.mdl")
	self:TakePrimaryAmmo(1)
end

function SWEP:Reload()
	self:EmitSound("weapons/crossbow/reload1.wav")
	self:ThrowChair("models/props_junk/garbage_glassbottle003a.mdl")
	self:DefaultReload( ACT_VM_RELOAD )
end

function SWEP:ThrowChair(model_file)
	self:EmitSound(ShootSound)
	if (CLIENT) then return end
	local ent = ents.Create("prop_physics")
	if (!IsValid(ent)) then return end
	ent:SetModel(model_file)
	ent:SetPos(self.Owner:EyePos()+(self.Owner:GetAimVector() * 18))
	ent:SetAngles(self.Owner:EyeAngles())
	ent:Spawn()
	local phys = ent:GetPhysicsObject()
	if (!IsValid(phys)) then ent:Remove() return end
	local vel = self.Owner:GetAimVector()
	vel = vel * 99999999
	vel = vel + (VectorRand() * 999999)
	phys:SetMass(5000)
	phys:ApplyForceCenter(vel)
	cleanup.Add(self.Owner,"props",ent)
	undo.Create("BLYAT-chair_shooted")
		undo.AddEntity(ent)
		undo.SetPlayer(self.Owner)
	undo.Finish()
end