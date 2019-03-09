scope WeirdElementalOddityFeatGryf initializer pgInit

//
globals
	private timer pgTimer = CreateTimer()
	//
	private effect pgElec
	private effect pgCold  // note that this one's effect jumps around on its own already
	private effect pgFire
	//
	private VectorLink pgLuna
	private VectorLink pgMoon
	private VectorLink pgLune
	//
	private unit pgGryf  // favorite testing partner
endglobals

//
private function pgOnExpire takes nothing returns nothing
	call pgLuna.link.vector.rotate(0.1, 0)
	//
	call pgLuna.vector.rotate( 0.3, 0.02)
	call pgMoon.vector.rotate( 0.4, 0.03)
	call pgLune.vector.rotate(-0.5, 0.04)
	//
//! textmacro VECTOR_LINK_DEMO_UPDATE takes EFFECT, LINK
		//
		call BlzSetSpecialEffectPosition($EFFECT$, $LINK$.x, $LINK$.y, $LINK$.z)
		//
//! endtextmacro
	//
//! runtextmacro VECTOR_LINK_DEMO_UPDATE("pgElec", "pgLuna")
//! runtextmacro VECTOR_LINK_DEMO_UPDATE("pgCold", "pgMoon")
//! runtextmacro VECTOR_LINK_DEMO_UPDATE("pgFire", "pgLune")
endfunction

//
private function pgFinish takes nothing returns nothing
	call DestroyEffect(pgElec)
	call DestroyEffect(pgCold)
	call DestroyEffect(pgFire)
	//
	call pgLuna.unlock()
	call pgMoon.unlock()
	call pgLune.unlock()
	//
	call PauseTimer(pgTimer)
	call DestroyTimer(pgTimer)
	set pgTimer = null
endfunction

//
private function pgInit takes nothing returns nothing
	local VectorLink lBase
	//
	set pgElec = AddSpecialEffect("Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl", 32256, 32256)
	set pgCold = AddSpecialEffect("Abilities\\Weapons\\ZigguratFrostMissile\\ZigguratFrostMissile.mdl", 32256, 32256)
	set pgFire = AddSpecialEffect("Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl", 32256, 32256)
	//
	set pgGryf = CreateUnit(Player(0), 'hgry', 0, 0, 0)
	//
	set lBase = VectorLink.create().delock().bind(pgGryf, Vector.create().delock().rpz(100, 0, 0), 0)
	//
	set pgLuna = VectorLink.create().bind(null, Vector.create().delock().spt(40, 0, 0), lBase)
	set pgMoon = VectorLink.create().bind(null, Vector.create().delock().rp(60, 0), lBase)
	set pgLune = VectorLink.create().bind(null, Vector.create().delock().rp(50, 3.141592654), lBase)
	//
	call TimerStart(pgTimer, 0.03125, true, function pgOnExpire)
	call TimerStart(CreateTimer(), 60, false, function pgFinish)
	//
	call FogEnable(false)
	call FogMaskEnable(false)
endfunction

endscope
