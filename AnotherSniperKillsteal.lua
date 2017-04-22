--Author: spiregor
local AnotherAutoAssassinate = {}

AnotherAutoAssassinate.IsToggled = Menu.AddOption( {"Hero Specific","Sniper"}, "Another Auto Assassinate", "Auto use ultimate if target killable")
AnotherAutoAssassinate.sleepers = {}
AnotherAutoAssassinate.Modifiers = { [0] = "modifier_medusa_stone_gaze_stone", [1] = "modifier_winter_wyvern_winters_curse", [2] = "modifier_item_lotus_orb_active", [3] = "modifier_templar_assassin_refraction_absorb", [4] = "modifier_item_blade_mail_reflect", [5] = "modifier_nyx_assassin_spiked_carapace" }

function AnotherAutoAssassinate.OnUpdate()
    local hero = Heroes.GetLocal()
	local player = Players.GetLocal()
	if not hero or not Menu.IsEnabled(AnotherAutoAssassinate.IsToggled) or not AnotherAutoAssassinate.SleepCheck(0.1, "updaterate") or not Entity.IsAlive(hero) then return end
	local Ultimate = NPC.GetAbility(hero, "sniper_assassinate")
	if not Ultimate or not Ability.IsReady(Ultimate) or not Ability.IsCastable(Ultimate, Ability.GetManaCost(Ultimate)) then return end
	local target = AnotherAutoAssassinate.FindTarget(hero, Ultimate)
	if not target then return end
	Ability.CastTarget(Ultimate, target)	
	AnotherAutoAssassinate.Sleep(0.1, "updaterate");
end

function AnotherAutoAssassinate.FindTarget(me, ability)
    local hero = Heroes.GetLocal()
    local Ultimate = NPC.GetAbility(hero, "sniper_assassinate")
    local UltimateLevel = Ability.GetLevel(Ultimate)
	local UltimateDamage = (UltimateLevel > 0) and 320+165*(UltimateLevel-1) or 0
	
	local dagondmg = UltimateDamage + UltimateDamage * (Hero.GetIntellectTotal(me) / 16 / 100)
	local entities = Heroes.GetAll()
	for index, ent in pairs(entities) do
		local enemyhero = Heroes.Get(index)
		if not Entity.IsSameTeam(me, enemyhero) and not NPC.IsLinkensProtected(enemyhero) and not NPC.IsIllusion(enemyhero) and NPC.IsEntityInRange(me, enemyhero, Ability.GetCastRange(ability) + NPC.GetCastRangeBonus(me)) and not NPC.IsEntityInRange(me, enemyhero, NPC.GetAttackRange(me)) then
			local totaldmg = (1 - NPC.GetMagicalArmorValue(enemyhero)) * dagondmg
			local isValid = AnotherAutoAssassinate.CheckForModifiers(enemyhero)
			if Entity.GetHealth(enemyhero) < totaldmg and isValid then return enemyhero end
		end
	end
end

function AnotherAutoAssassinate.CheckForModifiers(target)
	for i=0,5 do
		if NPC.HasModifier(target, AnotherAutoAssassinate.Modifiers[i]) then
			return false
		end
	end
	return true
end

function AnotherAutoAssassinate.SleepCheck(delay, id)
	if not AnotherAutoAssassinate.sleepers[id] or (os.clock() - AnotherAutoAssassinate.sleepers[id]) > delay then
		return true
	end
	return false
end

function AnotherAutoAssassinate.Sleep(delay, id)
	if not AnotherAutoAssassinate.sleepers[id] or AnotherAutoAssassinate.sleepers[id] < os.clock() + delay then
		AnotherAutoAssassinate.sleepers[id] = os.clock() + delay
	end
end

return AnotherAutoAssassinate