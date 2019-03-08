scope UnidentifiedFlyingOrbiter initializer pgInit

//
globals
	private constant real RHO = 400
	private constant real Z = 300
	//
	private integer pgCount
	private Effect array pgX
	//
	private real pgAngle = 0
endglobals

//
private function pgOnExpire takes nothing returns nothing
	local integer lInt = pgCount
	local real lX
	local real lY
	//
	set pgAngle = pgAngle + 0.05
	set lX = RHO*Cos(pgAngle)
	set lY = RHO*Sin(pgAngle)
	//
	loop
		exitwhen lInt == 0
		set lInt = lInt - 1
		//
		set pgX[lInt].move(lX, lY, Z).yaw = pgAngle + Angle.rad.quarter
		set pgX[lInt].roll = pgX[lInt].roll + 0.2 - 0.4*(lInt - (lInt/2)*2)
		//
		set pgX[lInt].color = Color.hsl(Angle.rad2deg(pgAngle) + lInt*Angle.deg.full/pgCount, 1, 0.5)
	endloop
endfunction

//
private function pgInit takes nothing returns nothing
	local integer lInt = 5
	//
	set pgCount = lInt
	//
	loop
		exitwhen lInt == 0
		set lInt = lInt - 1
		//
		set pgX[lInt] = Effect.create("Abilities\\Weapons\\WingedSerpentMissile\\WingedSerpentMissile.mdl").move(RHO, 0, Z)
		//
		set pgX[lInt].yaw = Angle.rad.quarter
		set pgX[lInt].roll = lInt*Angle.rad.full/pgCount
		//
		set pgX[lInt].color = Color.hsl(lInt*Angle.deg.full/pgCount, 1, 0.5)
		set pgX[lInt].scale = 1.5 + (1/(lInt + 0.5))
	endloop
	//
	call TimerStart(CreateTimer(), 0.03125, true, function pgOnExpire)
	//
	call FogEnable(false)
	call FogMaskEnable(false)
endfunction

endscope
