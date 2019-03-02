library GameTime

//! novjass
//	(INFO)

	GameTime v2.0a
	- by Overfrost

//
//	(API)

	STRUCTS:
	-------

	struct GameTime

		readonly static integer hours
		readonly static integer minutes
		readonly static real seconds
		readonly static real total

		static method getString takes string separator returns string

//
//! endnovjass


//
private function pgPad2 takes integer aInt returns string
	if (aInt > 9) then
		return I2S(aInt)
	endif
	return "0" + I2S(aInt)
endfunction
//
private keyword pm
//
struct GameTime extends array

	//
	private static timer pgTimer = CreateTimer()

	//--------------------------
	// hours, minutes, seconds
	readonly static integer hours = 0
	readonly static integer minutes = 0
	//
	static method operator seconds takes nothing returns real
		return TimerGetElapsed(pgTimer)
	endmethod

	//----------------
	// total seconds
	private static integer pgSeconds = 0
	//
	static method operator total takes nothing returns real
		return pgSeconds + seconds
	endmethod

	//-------------------
	// formatted string
	static method getString takes string aSep returns string
		if (hours > 0) then
			return I2S(hours) + aSep /*
				*/ + pgPad2(minutes) + aSep /*
				*/ + pgPad2(R2I(seconds))
		endif
		return I2S(minutes) + aSep + pgPad2(R2I(seconds))
	endmethod

	//-----------
	// periodic
	private static method pgOnExpire takes nothing returns nothing
		set pgSeconds = pgSeconds + 60
		//
		if (minutes == 59) then
			set minutes = 0
			set hours = hours + 1
		else
			set minutes = minutes + 1
		endif
	endmethod

	implement pm
endstruct
private module pm
	private static method onInit takes nothing returns nothing
		call TimerStart(pgTimer, 60, true, function thistype.pgOnExpire)
	endmethod
endmodule

endlibrary
