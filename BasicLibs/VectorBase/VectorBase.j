library VectorBase requires Lockable

//! novjass
//	(INFO)

	VectorBase v5.0a
	- by Overfrost


	REQUIRES:
	--------

	library Lockable

//
//	(PP API)

	MODULES:
	-------

	module VectorBase
	module VectorExt


	MACROS:
	------

	textmacro VECTOR_BASE_RESET takes INSTANCE returns (statements)

//
//	(OUTPUT)

	VectorBase:
	----------

	real x
	real y
	real z

	real s  // spherical radius
	real r  // polar radius

	real p  // azimuth
	real t  // declination

	boolean inverted


	VectorExt:
	---------

	implement VectorBase

	method xyz takes real x, real y, real z returns thistype(this)
	method spt takes real s, real p, real t returns thistype(this)
	method rpz takes real r, real p, real z returns thistype(this)

	method xy takes real x, real y returns thistype(this)
	method rp takes real r, real p returns thistype(this)

	method revert takes nothing returns thistype(this)
	method invert takes nothing returns thistype(this)

	method rotate takes real p, real t returns thistype(this)

//
//	(API)

	STRUCTS:
	-------

    struct Vector extends array

		implement Lockable("nothing")

        implement VectorExt

		readonly static thistype temp

//
//! endnovjass


//--------------
// auxiliaries
private function pgStdRad takes real r0, real r1 returns real
	return r0 - R2I(r1*.159154943)*6.283185307  // .159154943 = 1/(2*PI)
endfunction

//
module VectorBase

	//----------------
    // stored fields
    real x
    real y
    real z
	//
	boolean inverted

	//-------------
	// macroscope
//! textmacro P_VECTOR_BASE_MACROSCOPE takes S, R, P, T

		//----------------
		// pseudo fields
		method operator s takes nothing returns real
			return $S$
		endmethod
		method operator r takes nothing returns real
			return $R$
		endmethod
		//
		method operator p takes nothing returns real
			if (inverted) then
				return $P$ + 3.141592654
			endif
			return $P$
		endmethod
		method operator t takes nothing returns real
			if (inverted) then
				return 6.283185307 - $T$
			endif
			return $T$
		endmethod

		//----------------------
		// magnitude assigners
		method operator s= takes real aS returns nothing
			local real lP = $P$
			local real lT = $T$
			//
			set x = aS*Sin(lT)*Cos(lP)
			set y = aS*Sin(lT)*Sin(lP)
			set z = aS*Cos(lT)
		endmethod
		method operator r= takes real aR returns nothing
			local real lS = $S$
			local real lP = $P$
			//
			set x = aR*Cos(lP)
			set y = aR*Sin(lP)
			set z = SquareRoot(lS*lS - aR*aR)
		endmethod

		//----------------------
		// direction assigners
		method operator p= takes real aP returns nothing
			local real lR = $R$
			//
			if (inverted) then
				set x = -lR*Cos(aP)
				set y = -lR*Sin(aP)
			else
				set x = lR*Cos(aP)
				set y = lR*Sin(aP)
			endif
		endmethod
		method operator t= takes real aT returns nothing
			local real lS = $S$
			local real lP = $P$
			//
//! endtextmacro
//! runtextmacro P_VECTOR_BASE_MACROSCOPE("SquareRoot(x*x + y*y + z*z)", "SquareRoot(x*x + y*y)", "Atan2(y, x)", "Atan2(SquareRoot(x*x + y*y), z)")
		//
		if (inverted) then
			set x = -lS*Sin(aT)*Cos(lP)
			set y = -lS*Sin(aT)*Sin(lP)
		else
			set x = lS*Sin(aT)*Cos(lP)
			set y = lS*Sin(aT)*Sin(lP)
		endif
        set z = lS*Cos(aT)
		//
	//! textmacro P_VECTOR_BASE_INVERT takes T
			//
			set $T$ = $T$ - R2I($T$*.159154943)*6.283185307  // .159154943 = 1/(2*PI)
			if ($T$ < 0) then
				set $T$ = $T$ + 6.283185307
			endif
			//
			if ($T$ > 3.141592654) then
				set inverted = true
			else
				set inverted = false
			endif
			//
	//! endtextmacro
	//! runtextmacro P_VECTOR_BASE_INVERT("aT")
    endmethod

endmodule
module VectorExt
    implement VectorBase

	//---------------------
    // 3d multi-assigners
    method xyz takes real aX, real aY, real aZ returns thistype
        set x = aX
        set y = aY
        set z = aZ
        //
        return this
    endmethod
    //
    method spt takes real aS, real aP, real aT returns thistype
		set x = aS*Sin(aT)*Cos(aP)
		set y = aS*Sin(aT)*Sin(aP)
		set z = aS*Cos(aT)
        //
	//! runtextmacro P_VECTOR_BASE_INVERT("aT")
		//
        return this
    endmethod
    //
    method rpz takes real aR, real aP, real aZ returns thistype
		set x = aR*Cos(aP)
		set y = aR*Sin(aP)
		set z = aZ
		//
        return this
    endmethod

	//---------------------
    // 2d multi-assigners
    method xy takes real aX, real aY returns thistype
        set x = aX
        set y = aY
        //
        return this
    endmethod
    //
    method rp takes real aR, real aP returns thistype
		set x = aR*Cos(aP)
		set y = aR*Sin(aP)
        //
        return this
    endmethod

	//----------------------------
	// inversion quick-assigners
	method revert takes nothing returns thistype
		set inverted = false
		//
		return this
	endmethod
	method invert takes nothing returns thistype
		set inverted = not inverted
		//
		return this
	endmethod

	//----------
    // rotator
    method rotate takes real aP, real aT returns thistype
        local real lZ = z
        local real lR = SquareRoot(x*x + y*y)
		//
		set aP = Atan2(y, x) + aP
		if (inverted) then
			set aT = -aT
		endif
		//
		set  z = lZ*Cos(aT) - lR*Sin(aT)
		set lR = lZ*Sin(aT) + lR*Cos(aT)
        //
		set x = lR*Cos(aP)
		set y = lR*Sin(aP)
		//
		if (lR < 0) then
			set inverted = not inverted
		endif
		//
		return this
    endmethod

endmodule

//
//! textmacro VECTOR_BASE_RESET takes INSTANCE
		//
		set $INSTANCE$.x = 0
		set $INSTANCE$.y = 0
		set $INSTANCE$.z = 0
		//
		set $INSTANCE$.inverted = false
		//
//! endtextmacro

//
struct Vector extends array
    implement VectorExt

	//-----------
	// lockable
//! runtextmacro LOCKABLE("nothing")
	//! runtextmacro VECTOR_BASE_RESET("this")
//! runtextmacro LOCKABLE_END()

	//----------------
	// temp instance
	static method operator temp takes nothing returns thistype
		return 0
	endmethod //inlines

endstruct


/*	(CHANGELOG)

	v5.0a:
	-----

	- removed unit2 and unit3
	- optimized .p= and .t= a little
	- optimized .rotate

*/

endlibrary
