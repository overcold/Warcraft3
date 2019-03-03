scope RainbowHeatSpammer initializer pgInit

//
globals
	private timer pgTimer = CreateTimer()
	//
	private integer pgHue = 0
endglobals

//
private function pgGradText takes real aHue returns string
	local Color lBase = Color.hsl(aHue, 1, 0.5)
	local Color lTop  = Color.hsl(aHue + 60, 1, 0.5)
	//
	local string lString = ""
	local integer lInt = 9
	loop
		//
		set lString = lBase.blend(lTop, lInt*.05)["!"] + lString
		//
		exitwhen lInt == 0
		set lInt = lInt - 1
	endloop
	//
	loop
		//
		set lString = lString + lBase.blend(lTop, 0.5 + lInt*.05)["!"]
		//
		exitwhen lInt == 9
		set lInt = lInt + 1
	endloop
	//
	return lString
endfunction

//
private function pgOnExpire takes nothing returns nothing
	call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, pgGradText(pgHue) /*
		*/ + pgGradText(pgHue +  60) + pgGradText(pgHue + 120))
	set pgHue = pgHue + 2
endfunction

//
private function pgInit takes nothing returns nothing
	call TimerStart(pgTimer, 0.03125, true, function pgOnExpire)
endfunction

endscope
