library Color

//! novjass
//	(INFO)

	Color v2.0a
	- by Overfrost

//
//	(API)

	STRUCTS:
	-------

	struct Color extends array

		static method rgb takes integer r, integer g, integer b returns thistype
		static method hsl takes real h, real s, real l returns thistype

		static method operator player[] takes integer playerId returns thistype

		integer r
		integer g
		integer b

		real h
		real s
		real l

		readonly string string

		method operator [] takes string stringToBeColored returns string

		method blend takes thistype top, real alpha returns thistype

//
//! endnovjass


//
globals
	private Color array pgPlayerColor
endglobals
//
private keyword pm
//
private struct ps extends array

	//
	method operator [] takes integer aPlayerId returns Color
		return pgPlayerColor[this + aPlayerId]  // this+ makes it inlines
	endmethod //inlines

endstruct
struct Color extends array

	//
	private static integer array pgGrbPos
	//
	private static string array pgString

	//---------------
	// player color
	static method operator player takes nothing returns ps
		return 0
	endmethod //inlines

	//-----------------
	// rgb macroscope
//! textmacro P_COLOR_MS_RGB takes R, G
		//-------------
		// rgb helper
		private method pgG takes thistype aThis returns integer
			return (this - (aThis/$R$)*$R$)/$G$
		endmethod //inlines
		private method pgB takes thistype aThis returns integer
			return this - (aThis/$G$)*$G$
		endmethod //inlines

		//------
		// rgb
		static method rgb takes integer aR, integer aG, integer aB returns thistype
			return aR*$R$ + aG*$G$ + aB
		endmethod //inlines

		//-------------
		// rgb fields
		method operator r takes nothing returns integer
			return this/$R$
		endmethod //inlines
		method operator g takes nothing returns integer
			return pgG(this)
		endmethod
		method operator b takes nothing returns integer
			return pgB(this)
		endmethod
		//
		method operator r= takes integer aR returns thistype
			return this + (aR - r)*$R$
		endmethod
		method operator g= takes integer aG returns thistype
			return this + (aG - pgG(this))*$G$
		endmethod
		method operator b= takes integer aB returns thistype
			return (this/$G$)*$G$ + aB
		endmethod //inlines
//! endtextmacro
//! runtextmacro P_COLOR_MS_RGB("0x10000", "0x100")

	//--------------
	// hsl helpers
	private method operator pMax takes nothing returns integer
		local integer l0 = r
		local integer l1 = pgG(this)
		//
		if (l1 > l0) then
			set l0 = l1
		endif
		//
		set l1 = pgB(this)
		if (l1 > l0) then
			return l1
		endif
		//
		return l0
	endmethod
	private method operator pMin takes nothing returns integer
		local integer l0 = r
		local integer l1 = pgG(this)
		//
		if (l1 < l0) then
			set l0 = l1
		endif
		//
		set l1 = pgB(this)
		if (l1 < l0) then
			return l1
		endif
		//
		return l0
	endmethod
	private method operator pSum takes nothing returns integer
		local integer lMax = r
		local integer lMin = pgG(this)
		local integer lB = pgB(this)
		//
		if (lMax < lMin) then
			set lMax = lMin
			set lMin = r //quick
		endif
		//
		if (lMax < lB) then
			return lB + lMin
		elseif (lMin > lB) then
			return lB + lMax
		endif
		//
		return lMax + lMin
	endmethod

	//-------------
	// hsl to rgb
	// - optimized algorithm by Overfrost
	//  (prioritizes speed, not readability nor shortness, but preserves accuracy)
	static method hsl takes real aH, real aS, real aL returns thistype
		local thistype this
		//
		local real lThird
		//
		local integer lChroma
		//
		set aH = aH*.016666667 - R2I(aH*.002777778)*6  // 1.66e-2 = 1/60, 2.77e-3 = 1/360
		set lThird = aH - R2I(aH*.5)*2
		//
		if (aL > 0.5) then
			set lChroma = R2I((1 - aL)*0x1FE*aS)
		else
			set lChroma = R2I(0x1FE*aL*aS)
		endif
		//
	//! textmacro P_COLOR_HSL_CORE takes H, MIN
			//
			set this = $MIN$*0x10101  // min
			//
			if (lThird > 1) then  // mid
				set this = this + R2I((2 - lThird)*lChroma)*pgGrbPos[R2I($H$)]
			else
				set this = this + R2I(lThird*lChroma)*pgGrbPos[R2I($H$)]
			endif
			//
			return this + lChroma*pgGrbPos[R2I($H$) + 1 - 2*R2I(lThird)]  // max
			//
	//! endtextmacro
	//! runtextmacro P_COLOR_HSL_CORE("aH", "R2I(aL*0xFF - lChroma*.5)")
	endmethod

	//-------------
	// hsl fields
	method operator h takes nothing returns real
		local real lG = pgG(this)
		local real lB = pgB(this)
		//
		set lB = Atan2((lG - lB)*.866025404, r - (lG + lB)*.5)*57.29577951  // .866025404 = squareRoot(3)/2, 57.29577951 = 180/PI
		if (lB < 0) then
			return lB + 360
		endif
		return lB
	endmethod
	method operator s takes nothing returns real
		local integer lMax = pMax
		local integer lMin = pMin
		//
		local real l2L
		//
		if (lMax == lMin) then
			return 0.
		endif
		//
		set l2L = lMax + lMin
		if (l2L > 0xFF) then
			return (lMax - lMin)/(0x1FE - l2L)
		endif
		return (lMax - lMin)/l2L
	endmethod
	method operator l takes nothing returns real
		return pSum*.001960784  // 1.96e-3 = 1/255 * 1/2
	endmethod //inlines
	//
	method operator h= takes real aH returns thistype
		local integer lMin = pMin
		local integer lChroma = pMax - lMin
		//
		local real lThird
		//
		set aH = aH*.016666667 - R2I(aH*.002777778)*6
		set lThird = aH - R2I(aH*.5)*2
		//
	//! runtextmacro P_COLOR_HSL_CORE("aH", "lMin")
	endmethod
	method operator s= takes real aS returns thistype
		local real lH = h*.016666667
		local real lThird = lH - R2I(lH*.5)*2
		//
		local integer l2L = pSum
		local integer lChroma
		//
		if (l2L > 0xFF) then
			set lChroma = R2I((0x1FE - l2L)*aS)
		else
			set lChroma = R2I(l2L*aS)
		endif
		//
	//! runtextmacro P_COLOR_HSL_CORE("lH", "(l2L - lChroma)/2")
	endmethod
	method operator l= takes real aL returns thistype
		local real lH = h*.016666667
		local real lThird = lH - R2I(lH*.5)*2
		//
		local integer lChroma
		//
		if (aL > 0.5) then
			set lChroma = R2I((1 - aL)*0x1FE*s)
		else
			set lChroma = R2I(0x1FE*aL*s)
		endif
		//
	//! runtextmacro P_COLOR_HSL_CORE("lH", "R2I(aL*0xFF - lChroma*.5)")
	endmethod

	//--------------------
	// string macroscope
//! textmacro P_COLOR_MS_STRING takes HEX_STRING
		//-------------
		// hex string
		method operator string takes nothing returns string
			return $HEX_STRING$
		endmethod

		//-------------------
		// string colorizer
		method operator [] takes string aString returns string
			return "|cff" + $HEX_STRING$ + aString + "|r"
		endmethod
//! endtextmacro
//! runtextmacro P_COLOR_MS_STRING("pgString[r] + pgString[pgG(this)] + pgString[pgB(this)]")

	//----------
	// blender
	method blend takes thistype aTop, real aAlpha returns thistype
		local real lBeta = 1 - aAlpha
		//
		return rgb(R2I(r*lBeta + aTop.r*aAlpha), R2I(pgG(this)*lBeta + aTop.pgG(aTop)*aAlpha), R2I(pgB(this)*lBeta + aTop.pgB(aTop)*aAlpha))
	endmethod

	implement pm
endstruct
private module pm

	//--------------
	// initializer
	private static method onInit takes nothing returns nothing
		local integer lInt = 1
		loop
			//
			set pgGrbPos[lInt*3    ] = 0x100
			set pgGrbPos[lInt*3 + 1] = 0x10000
			set pgGrbPos[lInt*3 + 2] = 0x1
			//
			exitwhen lInt == 0
			set lInt = 0  // only loops twice
		endloop
		//
		// Credits to Vexorian. From his ARGB, re-optimized:
	//! textmacro P_COLOR_HEX_STRING takes L0, R0, H0, L1, R1, H1
			//
			loop
				//
				set pgString[lInt      + $L0$] = "$H0$" + pgString[lInt + $L0$]
				set pgString[lInt*0x10 + $R0$] = pgString[lInt*0x10 + $R0$] + "$H0$"
				//
				exitwhen lInt == 0xF
				set lInt = lInt + 1
			endloop
			//
			loop
				//
				set pgString[lInt      + $L1$] = "$H1$" + pgString[lInt + $L1$]
				set pgString[lInt*0x10 + $R1$] = pgString[lInt*0x10 + $R1$] + "$H1$"
				//
				exitwhen lInt == 0
				set lInt = lInt - 1
			endloop
			//
	//! endtextmacro
		//
	//! runtextmacro P_COLOR_HEX_STRING("0x00", "0x0", "0",  "0x80", "0x8", "8")
	//! runtextmacro P_COLOR_HEX_STRING("0x10", "0x1", "1",  "0x90", "0x9", "9")
	//! runtextmacro P_COLOR_HEX_STRING("0x20", "0x2", "2",  "0xA0", "0xA", "a")
	//! runtextmacro P_COLOR_HEX_STRING("0x30", "0x3", "3",  "0xB0", "0xB", "b")
		//
	//! runtextmacro P_COLOR_HEX_STRING("0x40", "0x4", "4",  "0xC0", "0xC", "c")
	//! runtextmacro P_COLOR_HEX_STRING("0x50", "0x5", "5",  "0xD0", "0xD", "d")
	//! runtextmacro P_COLOR_HEX_STRING("0x60", "0x6", "6",  "0xE0", "0xE", "e")
	//! runtextmacro P_COLOR_HEX_STRING("0x70", "0x7", "7",  "0xF0", "0xF", "f")
		//
		// Credits to Raen7 for his PlayerColor compilation
		set pgPlayerColor[ 0] = 0xFF0303  // red
		set pgPlayerColor[ 1] = 0x0042FF  // blue
		set pgPlayerColor[ 2] = 0x1CE6B9  // teal
		set pgPlayerColor[ 3] = 0x540081  // purple
		//
		set pgPlayerColor[ 4] = 0xFFFC00  // yellow
		set pgPlayerColor[ 5] = 0xFE8A0E  // orange
		set pgPlayerColor[ 6] = 0x20C000  // green
		set pgPlayerColor[ 7] = 0xE55BB0  // pink
		//
		set pgPlayerColor[ 8] = 0x959697  // gray
		set pgPlayerColor[ 9] = 0x7EBFF1  // lightBlue
		set pgPlayerColor[10] = 0x106246  // darkGreen
		set pgPlayerColor[11] = 0x4A2A04  // brown
		//
		set pgPlayerColor[12] = 0x9B0000  // maroon
		set pgPlayerColor[13] = 0x0000C3  // navy
		set pgPlayerColor[14] = 0x00EAFF  // turquoise
		set pgPlayerColor[15] = 0xBE00FE  // violet
		//
		set pgPlayerColor[16] = 0xEBCD87  // wheat
		set pgPlayerColor[17] = 0xF8A48B  // peach
		set pgPlayerColor[18] = 0xBFFF80  // mint
		set pgPlayerColor[19] = 0xDCB9EB  // lavender
		//
		set pgPlayerColor[20] = 0x282828  // coal
		set pgPlayerColor[21] = 0xEBF0FF  // snow
		set pgPlayerColor[22] = 0x00781E  // emerald
		set pgPlayerColor[23] = 0xA46F33  // peanut
	endmethod

endmodule

endlibrary
