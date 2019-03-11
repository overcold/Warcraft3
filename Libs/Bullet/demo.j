scope GryfSparkOfLove initializer pgInit

//
globals
	private Bullet pgBullet
	//
	private unit pgSource
endglobals

//
private function pgCreateUnitVector takes integer aId returns Vector
	set bj_lastCreatedUnit = CreateUnit(Player(0), aId, 0, 0, 0)
	call SetUnitInvulnerable(bj_lastCreatedUnit, true)
	//
	return Vector.create().bind(bj_lastCreatedUnit)
endfunction

//
private function pgOnExpire takes nothing returns nothing
	if (pgBullet.advance(15).reached) then
		call Effect.attach("Abilities\\Weapons\\Bolt\\BoltImpact.mdl", pgBullet.target.bound, "origin").unlock()
		//
		set Vector.temp = pgBullet.source.lock().xyz(0, 0, 50).bind(pgSource)  // instead of cloning, reuse it
		set pgSource = pgBullet.target.bound
		//
		set pgBullet.restart(pgBullet.target.debind()).target = Vector.temp
	endif
endfunction

//
private function pgInit takes nothing returns nothing
	set Vector.temp = pgCreateUnitVector('hgry').debind()
	set Vector.temp.z = Vector.temp.z + 50
	set pgSource = bj_lastCreatedUnit
	//
	set Vector.tempEx = pgCreateUnitVector('Ewrd')
	set Vector.tempEx.z = 50
	//
	call SelectHeroSkill(bj_lastCreatedUnit, 'AEbl')
	call BlzSetUnitAbilityCooldown(bj_lastCreatedUnit, 'AEbl', 1, 0)
	call BlzSetUnitAbilityManaCost(bj_lastCreatedUnit, 'AEbl', 1, 0)
	//
	set pgBullet = Bullet.create("Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl", Vector.temp, Vector.tempEx)
	//
	set Vector.temp = 0  // both of these are not really necessary
	set Vector.tempEx = 0
	//
	call TimerStart(CreateTimer(), 0.03125, true, function pgOnExpire)
	//
	call FogEnable(false)
	call FogMaskEnable(false)
endfunction

endscope
