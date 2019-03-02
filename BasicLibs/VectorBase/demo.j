scope WeirdElementalOddity initializer pgInit

//
globals
    private timer pgTimer = CreateTimer()
    //
    private effect pgElec
    private effect pgCold  // note that this one's effect jumps around on its own already
    private effect pgFire
    //
    private Vector pgBase
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
    set pgBase.t = pgBase.t + 0.02
    set pgBase.p = pgBase.p + 0.3
    //
    call pgMoon.rotate( 0.4, 0.03)  // these and above produce the same result
    call pgLune.rotate(-0.5, 0.04)
    //
    call BlzSetSpecialEffectPosition(pgElec, pgBase.x + Vector.temp.x, pgBase.y + Vector.temp.y, pgBase.z + 200)
    call BlzSetSpecialEffectPosition(pgCold, pgMoon.x + Vector.temp.x, pgMoon.y + Vector.temp.y, pgMoon.z + 200)
    call BlzSetSpecialEffectPosition(pgFire, pgLune.x + Vector.temp.x, pgLune.y + Vector.temp.y, pgLune.z + 200)
endfunction

//
private function pgInit takes nothing returns nothing
    set pgElec = AddSpecialEffect("Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl", 32256, 32256)
    set pgCold = AddSpecialEffect("Abilities\\Weapons\\ZigguratFrostMissile\\ZigguratFrostMissile.mdl", 32256, 32256)
    set pgFire = AddSpecialEffect("Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl", 32256, 32256)
    //
    set pgBase = Vector.create().spt(40, 0, 0)
    set pgMoon = Vector.create().rp(60, 0)
    set pgLune = Vector.create().rp(50, 3.141592654)
    //
    call TimerStart(pgTimer, 0.03125, true, function pgOnExpire)
    //
    call FogEnable(false)
    call FogMaskEnable(false)
endfunction

endscope
