scope WeirdElementalOddity initializer pgInit

//
globals
	private timer pgTimer = CreateTimer()
	//
	private effect pgElec
	private effect pgCold  // note that this one's effect jumps around on its own already
	private effect pgFire
	//
	private Vector pgLuna
	private Vector pgMoon
	private Vector pgLune
	//
	private real pgPhi = 0
endglobals

//
private function pgOnExpire takes nothing returns nothing
	set pgPhi = pgPhi + 0.01
	call Vector.temp.rpz(400, pgPhi, 0)
	//
	set pgLuna.t = pgLuna.t + 0.02
	set pgLuna.p = pgLuna.p + 0.3
	//
	call pgMoon.rotate( 0.4, 0.03)  // these and above produce the same result
	call pgLune.rotate(-0.5, 0.04)
	//
//! textmacro VECTOR_BASE_DEMO_UPDATE takes EFFECT, VECTOR
		//
		call BlzSetSpecialEffectPosition($EFFECT$, $VECTOR$.x + Vector.temp.x, $VECTOR$.y + Vector.temp.y, $VECTOR$.z + 200)
		//
//! endtextmacro
	//
//! runtextmacro VECTOR_BASE_DEMO_UPDATE("pgElec", "pgLuna")
//! runtextmacro VECTOR_BASE_DEMO_UPDATE("pgCold", "pgMoon")
//! runtextmacro VECTOR_BASE_DEMO_UPDATE("pgFire", "pgLune")
endfunction

//
private function pgInit takes nothing returns nothing
	set pgElec = AddSpecialEffect("Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl", 32256, 32256)
	set pgCold = AddSpecialEffect("Abilities\\Weapons\\ZigguratFrostMissile\\ZigguratFrostMissile.mdl", 32256, 32256)
	set pgFire = AddSpecialEffect("Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl", 32256, 32256)
	//
	set pgLuna = Vector.create().spt(40, 0, 0)
	set pgMoon = Vector.create().rp(60, 0)
	set pgLune = Vector.create().rp(50, 3.141592654)
	//
	call TimerStart(pgTimer, 0.03125, true, function pgOnExpire)
	//
	call FogEnable(false)
	call FogMaskEnable(false)
endfunction

endscope
