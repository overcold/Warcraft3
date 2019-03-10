scope UnusualElementalGryf initializer pgInit

//
globals
	private timer pgTimer = CreateTimer()
	//
	private effect pgElec
	private effect pgCold
	private effect pgFire
	//
	private Vector pgElecV
	private Vector pgColdV
	private Vector pgFireV
	//
	private unit pgGryf  // favorite testing partner
endglobals

//
private function pgOnExpire takes nothing returns nothing
	call pgElecV.linked.rotate(0.1, 0)
	//
	call pgElecV.rotate( 0.3, 0.02)
	call pgColdV.rotate( 0.4, 0.03)
	call pgFireV.rotate(-0.5, 0.04)
	//
//! textmacro P_VECTOR_DEMO_UPDATE takes EFFECT, VECTOR
		//
		call BlzSetSpecialEffectPosition($EFFECT$, $VECTOR$.sum.x, $VECTOR$.sum.y, $VECTOR$.sum.z)
		//
//! endtextmacro
	//
//! runtextmacro P_VECTOR_DEMO_UPDATE("pgElec", "pgElecV")
//! runtextmacro P_VECTOR_DEMO_UPDATE("pgCold", "pgColdV")
//! runtextmacro P_VECTOR_DEMO_UPDATE("pgFire", "pgFireV")
endfunction

//
private function pgFinish takes nothing returns nothing
	call DestroyEffect(pgElec)
	call DestroyEffect(pgCold)
	call DestroyEffect(pgFire)
	//
	call pgElecV.unlock()
	call pgColdV.unlock()
	call pgFireV.unlock()
	//
	call PauseTimer(pgTimer)
	call DestroyTimer(pgTimer)
	set pgTimer = null
endfunction

//
private function pgDebind takes nothing returns nothing
	call pgElecV.linked.linked.debind()
	//
	call TimerStart(GetExpiredTimer(), 10, false, function pgFinish)
endfunction

//
private function pgInit takes nothing returns nothing
	set pgElec = AddSpecialEffect("Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl", 0x8000, 0x8000)
	set pgCold = AddSpecialEffect("Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorTarget.mdl", 0x8000, 0x8000)
	set pgFire = AddSpecialEffect("Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl", 0x8000, 0x8000)
	call BlzSetSpecialEffectScale(pgCold, 0.5)
	//
	set pgGryf = CreateUnit(Player(0), 'hgry', 0, 0, 0)
	//
	set Vector.temp = Vector.create().bind(pgGryf)
	set Vector.temp = Vector.create().link(Vector.temp).polar(100, 0)
	//
	set pgElecV = Vector.create().link(Vector.temp).spheric(40, 0, 0)
	set pgColdV = Vector.create().link(Vector.temp).polar(60, 0)
	set pgFireV = Vector.create().link(Vector.temp).polar(50, Angle.rad.half)
	//
	set Vector.temp = 0  // not actually needed
	//
	call TimerStart(pgTimer, 0.03125, true, function pgOnExpire)
	call TimerStart(CreateTimer(), 30, false, function pgDebind)
	//
	call FogEnable(false)
	call FogMaskEnable(false)
endfunction

endscope
