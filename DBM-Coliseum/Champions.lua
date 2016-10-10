local mod	= DBM:NewMod("Champions", "DBM-Coliseum")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 236 $"):sub(12, -3))
mod:SetCreatureID(34458, 34451, 34459, 34448, 34449, 34445, 34456, 34447, 34441, 34454, 34444, 34455, 34450, 34453, 34461, 34460, 34469, 34467, 34468, 34471, 34465, 34466, 34473, 34472, 34470, 34463, 34474, 34475)
--mod:SetEncounterID(1086)--This must never be enabled

mod:RegisterCombat("combat")
mod:RegisterKill("yell", L.AllianceVictory, L.HordeVictory)

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS",
	"SPELL_DAMAGE",
	"SPELL_MISSED",
	"SPELL_AURA_APPLIED",
	"UNIT_DIED"
)

local warnHellfire			= mod:NewSpellAnnounce(65816, 4)
local preWarnBladestorm 	= mod:NewSoonAnnounce(65947, 3)
local warnBladestorm		= mod:NewSpellAnnounce(65947, 4)
local warnHeroism			= mod:NewSpellAnnounce(65983, 3)
local warnBloodlust			= mod:NewSpellAnnounce(65980, 3)
local warnHandofFreedom		= mod:NewTargetAnnounce(66115, 2)
local warnHandofProt		= mod:NewTargetAnnounce(66009, 3)
local warnDivineShield		= mod:NewSpellAnnounce(66010, 3)
local warnIceBlock			= mod:NewSpellAnnounce(65802, 3)
local warnShadowstep		= mod:NewSpellAnnounce(66178, 2)
local warnDeathgrip			= mod:NewTargetAnnounce(66017, 2)
local warnCyclone			= mod:NewTargetAnnounce(65859, 1, nil, false)
local warnSheep				= mod:NewTargetAnnounce(65801, 1, nil, false)

local timerBladestorm		= mod:NewBuffActiveTimer(8, 65947)
local timerShadowstepCD		= mod:NewCDTimer(30, 66178)
local timerDeathgripCD		= mod:NewCDTimer(35, 66017)
local timerBladestormCD		= mod:NewCDTimer(90, 65947)

local specWarnHellfire		= mod:NewSpecialWarningMove(65816)
local specWarnHandofProt	= mod:NewSpecialWarningDispel(66009, "MagicDispeller")
local specWarnDivineShield	= mod:NewSpecialWarningDispel(66010, "MagicDispeller") 
local specWarnIceBlock		= mod:NewSpecialWarningDispel(65802, "MagicDispeller")

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 65816 then
		warnHellfire:Show()
	elseif args.spellId == 65947 then
		warnBladestorm:Show()
		timerBladestorm:Start()
		timerBladestormCD:Start()
		preWarnBladestorm:Schedule(85)
	elseif args.spellId == 65983 then
		warnHeroism:Show()
	elseif args.spellId == 65980 then
		warnBloodlust:Show()
	elseif args.spellId == 66115 and not args:IsDestTypePlayer() then
		warnHandofFreedom:Show(args.destName)
	elseif args.spellId == 66009 then
		warnHandofProt:Show(args.destName)
		specWarnHandofProt:Show(args.destName)
	elseif args.spellId == 66178 then
		warnShadowstep:Show()
        if self:IsDifficulty("heroic25") then
			timerShadowstepCD:Start(20)
		else
			timerShadowstepCD:Start()
		end
	elseif args.spellId == 66017 and args:IsDestTypePlayer() then
		warnDeathgrip:Show(args.destName)
		if self:IsDifficulty("heroic25") then
			timerDeathgripCD:Start(20)
		else
			timerDeathgripCD:Start()
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 66010 then
		warnDivineShield:Show(args.destName)
		specWarnDivineShield:Show(args.destName)
	elseif args.spellId == 65802 then
		warnIceBlock:Show(args.destName)
		specWarnIceBlock:Show(args.destName)
	elseif args.spellId == 65859 and args:IsDestTypePlayer() then
		warnCyclone:Show(args.destName)
	elseif args.spellId == 65801 and args:IsDestTypePlayer() then
		warnSheep:Show(args.destName)
	end
end

function mod:SPELL_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
	if spellId == 65817 and destGUID == UnitGUID("player") and self:AntiSpam() then
		specWarnHellfire:Show()
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 34472 or cid == 34454 then
		timerShadowstepCD:Cancel()
	elseif cid == 34458 or cid == 34461 then
		timerDeathgripCD:Cancel()
	elseif cid == 34475 or cid == 34453 then
		timerBladestormCD:Cancel()
		preWarnBladestorm:Cancel()
	end
end
