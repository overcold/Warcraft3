library Angle

//! novjass
//	(INFO)

	Angle v1.0a
	- by Overfrost

//
//	(API)

	STRUCTS:
	-------

	struct Angle extends array

		static method rad2deg takes real rad returns real
		static method deg2rad takes real deg returns real

		static keyword rad
		// contains:

			constant real full = 2*PI
			constant real half = PI
			constant real quarter = PI/2

			static method normalize takes real rad, boolean isPositiveOnly returns real


		static keyword deg
		// contains:

			constant real full = 360
			constant real half = 180
			constant real quarter = 90

			static method normalize takes real deg, boolean isPositiveOnly returns real

//
//! endnovjass


//
private struct psRad extends array

	//-----------------
	// shared members
//! textmacro P_ANGLE_SHARED takes FULL, HALF, QUARTER, FULL_FACTOR

		//------------
		// constants
		static method operator full takes nothing returns real
			return $FULL$
		endmethod
		static method operator half takes nothing returns real
			return $HALF$
		endmethod
		static method operator quarter takes nothing returns real
			return $QUARTER$
		endmethod

		//-------------
		// normalizer
		static method normalize takes real a, boolean aPositive returns real
			set a = a - R2I(a*$FULL_FACTOR$)*$FULL$
			//
			if (aPositive) then
				if (a < 0) then
					return a + $FULL$
				endif
			else
				if (a > $HALF$) then
					return a - $FULL$
				elseif (a < -$HALF$) then
					return a + $FULL$
				endif
			endif
			//
			return a
		endmethod

//! endtextmacro
//! runtextmacro P_ANGLE_SHARED("6.283185307", "3.141592654", "1.570796327", ".159154943")

endstruct
private struct psDeg extends array

	//-----------------
	// shared members
//! runtextmacro P_ANGLE_SHARED("360.", "180.", "90.", ".002777778")

endstruct
struct Angle extends array

	//---------
	// childs
	static method operator rad takes nothing returns psRad
		return 0
	endmethod
	static method operator deg takes nothing returns psDeg
		return 0
	endmethod

	//-------------
	// converters
	static method rad2deg takes real aRad returns real
		return aRad*57.29577951
	endmethod
	static method deg2rad takes real aDeg returns real
		return aDeg*.017453293
	endmethod

endstruct

endlibrary
