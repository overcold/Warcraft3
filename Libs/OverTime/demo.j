scope CursedEliteTaurenChieftain initializer pgInit

//
globals
	private unit pgETC
	private real pgLifeFraction
	//
	private effect pgCurseMark = null
endglobals

//
private struct ps extends array

	//
	private static Code pgAction
	//
	private effect pVfx
	private integer pTick

	//
	private static method pgOverTime takes nothing returns boolean
		local thistype this = OverTime.acting
		//
		set pTick = pTick + 1
		//
		if (IsUnitType(pgETC, UNIT_TYPE_DEAD)) then
			set pTick = OverTime.frequency*7
		else
			call SetWidgetLife(pgETC, GetWidgetLife(pgETC) + pgLifeFraction*.25*OverTime.period)
		endif
		//
		if (pTick == OverTime.frequency*7) then
			call DestroyEffect(pVfx)
			set pVfx = null
			//
			call OverTime.acting.unlock()
		endif
		//
		return false
	endmethod

	//
	static method onCast takes nothing returns boolean
		local thistype this = OverTime.create(pgAction).prioritize(-1)
		//
		set pVfx = AddSpecialEffectTarget("Abilities\\Spells\\NightElf\\Rejuvenation\\RejuvenationTarget.mdl", /*
			*/ pgETC, "chest")
		set pTick = 0
		//
		return false
	endmethod

	//
	private static method onInit takes nothing returns nothing
		set pgAction = Code.create(function thistype.pgOverTime)
	endmethod

endstruct

//
private function pgCurse takes nothing returns boolean
	if (not IsUnitType(pgETC, UNIT_TYPE_DEAD)) then
		if (pgCurseMark == null) then
			set pgCurseMark = AddSpecialEffectTarget("Abilities\\Spells\\Other\\Doom\\DoomTarget.mdl", /*
				*/ pgETC, "origin")
		endif
		//
		call UnitDamageTarget(pgETC, pgETC, pgLifeFraction*OverTime.period, true, false, /*
			*/ ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNIVERSAL, WEAPON_TYPE_WHOKNOWS)
	elseif (pgCurseMark != null) then
		call BlzSetSpecialEffectColor(pgCurseMark, 0, 0, 0)
		call BlzSetSpecialEffectAlpha(pgCurseMark, 0)
		call DestroyEffect(pgCurseMark)
		set pgCurseMark = null
	endif
	//
	return false
endfunction

//
private function pgInit takes nothing returns nothing
	local trigger lTrig = CreateTrigger()
	//
	set pgETC = CreateUnit(Player(0), 'Otch', 0, 0, 0)
	call BlzSetHeroProperName(pgETC, "E.T.C.")
	//
	call SelectHeroSkill(pgETC, 'AOws')
	call BlzSetUnitAbilityCooldown(pgETC, 'AOws', 1, 0)
	call BlzSetUnitAbilityManaCost(pgETC, 'AOws', 1, 0)
	//
	call UnitAddAbility(pgETC, 'ACrn')
	call BlzSetUnitAbilityCooldown(pgETC, 'ACrn', 1, 0)
	//
	set pgLifeFraction = GetUnitState(pgETC, UNIT_STATE_MAX_LIFE)*.07
	//
	call OverTime.create(Code.create(function pgCurse))
	//
	call TriggerRegisterUnitEvent(lTrig, pgETC, EVENT_UNIT_SPELL_EFFECT)
	call TriggerAddCondition(lTrig, Condition(function ps.onCast))
	set lTrig = null
	//
	call FogEnable(false)
	call FogMaskEnable(false)
endfunction

endscope
