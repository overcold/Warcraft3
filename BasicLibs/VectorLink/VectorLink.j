library VectorLink requires VectorBase

//! novjass
//	(INFO)

	VectorLink v1.0a
	- by Overfrost

//
//	(API)

	STRUCTS:
	-------

	struct VectorLink extends array

		implement Lockable("nothing")

		readonly static thistype temp

		unit unit
		Vector vector

		thistype link

		readonly x
		readonly y
		readonly z

		readonly s  // spherical radius
		readonly r  // polar radius

		readonly p  // azimuth
		readonly t  // declination

		method bind takes unit u, Vector v, thistype vl returns thistype(this)

//
//! endnovjass


//
struct VectorLink extends array

	//---------
	// fields
	private Vector pVector
	private thistype pLink
	//
	unit unit

	//---------
	// access
//! textmacro P_VECTOR_LINK_FIELD takes ID, TYPE, VAR

		//
		method operator $ID$ takes nothing returns $TYPE$
			return $VAR$
		endmethod
		//
		method operator $ID$= takes $TYPE$ a returns nothing
			if ($VAR$ != 0) then
				call $VAR$.unlock()
			endif
			if (a == 0) then
				set $VAR$ = 0
			else
				set $VAR$ = a.lock()
			endif
		endmethod

//! endtextmacro
	//
//! runtextmacro P_VECTOR_LINK_FIELD("vector", "Vector", "pVector")
//! runtextmacro P_VECTOR_LINK_FIELD("link", "thistype", "pLink")

	//----------------
	// resultant xyz
//! textmacro P_VECTOR_LINK_XYZ takes XYZ, BASE

		//
		method operator $XYZ$ takes nothing returns real
			local real lReal = $BASE$
			//
			if (pVector != 0) then
				set lReal = lReal + pVector.$XYZ$
			endif
			//
			if (pLink != 0) then
				return lReal + pLink.$XYZ$
			endif
			//
			return lReal
		endmethod

//! endtextmacro
	//
//! runtextmacro P_VECTOR_LINK_XYZ("x", "GetUnitX(unit)")
//! runtextmacro P_VECTOR_LINK_XYZ("y", "GetUnitY(unit)")
//! runtextmacro P_VECTOR_LINK_XYZ("z", "GetUnitFlyHeight(unit) + BlzGetLocalUnitZ(unit)")

	//------------------
	// resultant sr/pt
	method operator s takes nothing returns real
		local real lX = x
		local real lY = y
		local real lZ = z
		//
		return SquareRoot(lX*lX + lY*lY + lZ*lZ)
	endmethod
	method operator r takes nothing returns real
		local real lX = x
		local real lY = y
		//
		return SquareRoot(lX*lX + lY*lY)
	endmethod
	//
	method operator p takes nothing returns real
		return Atan2(y, x)
	endmethod
	method operator t takes nothing returns real
		local real lX = x
		local real lY = y
		//
		return Atan2(SquareRoot(lX*lX + lY*lY), z)
	endmethod

	//-----------
	// assigner
	method bind takes unit aUnit, Vector aVector, thistype aLink returns thistype
		set unit = aUnit
		if (aVector >= 0) then
			set vector = aVector
		endif
		if (aLink >= 0) then
			set link = aLink
		endif
		//
		return this
	endmethod

	//-----------
	// lockable
//! runtextmacro LOCKABLE("nothing")
		//
		set pVector = 0
		set pLink = 0
		//
//! runtextmacro LOCKABLE_DESTROY()
		//
		set unit = null
		//
		if (pVector != 0) then
			call pVector.unlock()
		endif
		if (pLink != 0) then
			call pLink.unlock()
		endif
		//
//! runtextmacro LOCKABLE_END()

	//-------
	// temp
	static method operator temp takes nothing returns thistype
		return 0
	endmethod

endstruct

endlibrary
