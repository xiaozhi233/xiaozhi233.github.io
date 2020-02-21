
AddCSLuaFile()

SWEP.PrintName = "杀人包"
SWEP.Author = "NeoSource"
SWEP.Purpose = "左键杀别人 右键杀自己"
SWEP.AdminOnly = true

SWEP.Slot = 5
SWEP.SlotPos = 3

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/weapons/c_medkit.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_medkit.mdl" )
SWEP.ViewModelFOV = 54
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

local HealSound = Sound( "HealthKit.Touch" )
local DenySound = Sound( "WallHealth.Deny" )

function SWEP:Initialize()

	self:SetHoldType( "slam" )

	if ( CLIENT ) then return end

	timer.Create( "medkit_ammo" .. self:EntIndex(), 1, 0, function()
		if ( self:Clip1() < self.MaxAmmo ) then self:SetClip1( math.min( self:Clip1() + 2, self.MaxAmmo ) ) end
	end )

end

function SWEP:PrimaryAttack()

	if ( CLIENT ) then return end

	if ( self.Owner:IsPlayer() ) then
		self.Owner:LagCompensation( true )
	end

	local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 12800,
		filter = self.Owner
	} )

	if ( self.Owner:IsPlayer() ) then
		self.Owner:LagCompensation( false )
	end

	local ent = tr.Entity

	if ( IsValid( ent ) && ( ent:IsPlayer() or ent:IsNPC() or ent:Health()!=0 ) ) then
        if SERVER then
		local dmg = DamageInfo()
    dmg:SetAttacker(self.Owner)
	dmg:SetInflictor(self)
	dmg:SetDamage(114.514)
    dmg:SetDamageType(bit.bor(DMG_BLAST,DMG_AIRBOAT))
		ent:TakeDamageInfo(dmg)
		end
		ent:EmitSound( HealSound )
self:SetNextPrimaryFire( CurTime() + 0.001 )
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		-- Even though the viewmodel has looping IDLE anim at all times, we need this to make fire animation work in multiplayer
		timer.Create( "weapon_idle" .. self:EntIndex(), self:SequenceDuration(), 0.01, function() if ( IsValid( self ) ) then self:SendWeaponAnim( ACT_VM_IDLE ) end end )

	else

		---self.Owner:EmitSound( DenySound )
		self:SetNextPrimaryFire( CurTime() + 0.001 )

	end

end

function SWEP:SecondaryAttack()

	if ( CLIENT ) then return end

	local ent = self.Owner
   if SERVER then
	local dmg = DamageInfo()
    dmg:SetAttacker(self.Owner)
	dmg:SetInflictor(self)
	dmg:SetDamage(191.9810)
    dmg:SetDamageType(bit.bor(DMG_BLAST,DMG_AIRBOAT))
		ent:TakeDamageInfo(dmg)
        end
		
		ent:EmitSound( HealSound )

		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

		self:SetNextSecondaryFire( CurTime() + 0.05 )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		timer.Create( "weapon_idle" .. self:EntIndex(), self:SequenceDuration(), 0.01, function() if ( IsValid( self ) ) then self:SendWeaponAnim( ACT_VM_IDLE ) end end )


 
end

function SWEP:OnRemove()

	timer.Stop( "medkit_ammo" .. self:EntIndex() )
	timer.Stop( "weapon_idle" .. self:EntIndex() )

end

function SWEP:Holster()

	timer.Stop( "weapon_idle" .. self:EntIndex() )

	return true

end
