scope HelloMultipleWorlds initializer pgInit

//
private struct ps extends array

	//
//! textmacro P_CODE_DEMO takes UPPER, LOWER, BOOLEAN, COLOR_HEX
		//
		static method $LOWER$ takes nothing returns boolean
			call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 0x100, "Hello World |cff$COLOR_HEX$" + I2S(Code.invoked) + "$UPPER$|r!")
			//
			return $BOOLEAN$
		endmethod
		//
//! endtextmacro
	//
//! runtextmacro P_CODE_DEMO("A", "a", "false", "ffff00")
//! runtextmacro P_CODE_DEMO("B", "b", "false", "00ffff")
//! runtextmacro P_CODE_DEMO("C", "c", "false", "ff00ff")
//! runtextmacro P_CODE_DEMO("D", "d", "true", "808080")

endstruct

//
private function pgOnStart takes nothing returns nothing
	local Code lMain = Code.create(function ps.c)
	local Code lMirror = Code.create(function ps.a)
	//
	set Code.temp = Code.create(function ps.b)
	set Code.temp = Code.create(function ps.b) /*
		*/ .prepend(lMirror).append(lMirror).merge().append(Code.temp)
	set lMain.precode = Code.temp
	//
	set Code.temp = Code.create(function ps.d).prepend(lMirror).append(lMirror)
	set lMain.postcode = Code.temp
	//
	call lMirror.unlock()
	set Code.temp = 0
	//
	call lMain.invoke().unlock()
	//
	call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 0x100, /*
		*/ "\n|cff0080ffSorry, nothing fancy in these worlds.\nBut you can try to digest what's happening here.\nEnabling Debug library can give more info.|r")
endfunction

//
private function pgInit takes nothing returns nothing
	call TimerStart(CreateTimer(), 1, false, function pgOnStart)
endfunction

endscope
