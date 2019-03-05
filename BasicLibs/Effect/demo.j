scope UnidentifiedFlyingOrbiter initializer pgInit

//
globals
	private constant real RHO = 300
	private constant real Z = 300
	private constant real OMEGA = 0.05
	//
	private integer pgCount
	private Effect array pgX
	private real pgAngle = 0
endglobals

//
private function pgOnExpire takes nothing returns nothing
	local integer lInt = pgCount
	local real lX
	local real lY
	//
	set pgAngle = pgAngle + OMEGA
	set lX = RHO*Cos(pgAngle)
	set lY = RHO*Sin(pgAngle)
	//
	loop
		exitwhen lInt == 0
		set lInt = lInt - 1
		//
		set pgX[lInt].move(lX, lY, Z).yaw = pgX[lInt].yaw + OMEGA
		set pgX[lInt].roll = pgX[lInt].roll + 0.05
	endloop
endfunction

//
private function pgInit takes nothing returns nothing
	local integer lInt = 3
	set pgCount = lInt
	loop
		exitwhen lInt == 0
		set lInt = lInt - 1
		//
		set pgX[lInt] = Effect.create("Abilities\\Weapons\\WingedSerpentMissile\\WingedSerpentMissile.mdl").move(RHO, 0, Z)
		set pgX[lInt].yaw = 1.570796327
		set pgX[lInt].roll = lInt*6.283185307/pgCount
	endloop
	//
	call TimerStart(CreateTimer(), 0.03125, true, function pgOnExpire)
	//
	call FogEnable(false)
	call FogMaskEnable(false)
endfunction

endscope
