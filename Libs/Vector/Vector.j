library Vector requires Lockable, Angle

//! novjass
//	(INFO)

	Vector v2.1a
	- by Overfrost


	REQUIRES:
	--------

	library Lockable
	library Angle

//
//	(API)

	STRUCTS:
	-------

	struct Vector extends array

		implement Lockable("nothing")
		implement LockableTempEx

		static method operator unit[] takes unit u returns thistype

		method clone takes nothing returns thistype

		real x
		real y
		real z

		method xyz takes real x, real y, real z returns thistype(this)
		method xy takes real x, real y returns thistype(this)

		real s  // spherical radius
		real r  // polar radius

		real p  // azimuth
		real t  // declination

		method spheric takes real s, real p, real t returns thistype(this)
		method cylindric takes real r, real p, real z returns thistype(this)
		method polar takes real r, real p returns thistype(this)

		boolean inverted

		method revert takes nothing returns thistype(this)
		method invert takes nothing returns thistype(this)
		method transvert takes nothing returns thistype(this)

		method add takes thistype addend returns thistype(this)
		method sub takes thistype subtrahend returns thistype(this)

		method flip takes nothing returns thistype(this)
		method scale takes real factor returns thistype(this)

		method rotate takes real p, real t returns thistype(this)

		unit bound

		method bind takes unit toBindWith returns thistype(this)
		method debind takes nothing returns thistype(this)
		method unbind takes nothing returns thistype(this)

		thistype linked

		method link takes thistype toLinkWith returns thistype(this)
		method delink takes nothing returns thistype(this)
		method unlink takes nothing returns thistype(this)

		method copy takes thistype toBeCopied returns thistype(this)

		keyword sum
		// contains:

			readonly real x
			readonly real y
			readonly real z

			readonly real s  // spherical radius
			readonly real r  // polar radius

			readonly real p  // azimuth
			readonly real t  // declination

			method clone takes nothing returns thistype

			method getDelta takes thistype target returns thistype


//
//! endnovjass


//
private keyword psUnit
private keyword psSum
//
struct Vector extends array

	//--------------
	// base fields
	real x
	real y
	real z
	//
	boolean inverted

	//-------------
	// macroscope
//! textmacro MS_VECTOR_BASE takes S, R, P, T

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
				return $P$ + Angle.rad.half
			endif
			return $P$
		endmethod
		method operator t takes nothing returns real
			if (inverted) then
				return Angle.rad.full - $T$
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
//! runtextmacro MS_VECTOR_BASE("SquareRoot(x*x + y*y + z*z)", "SquareRoot(x*x + y*y)", "Atan2(y, x)", "Atan2(SquareRoot(x*x + y*y), z)")
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
	//! textmacro P_VECTOR_INVERT takes T
			//
			set $T$ = Angle.rad.normalize($T$, true)
			//
			if ($T$ > Angle.rad.half) then
				set inverted = true
			else
				set inverted = false
			endif
			//
	//! endtextmacro
	//! runtextmacro P_VECTOR_INVERT("aT")
	endmethod

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
	method spheric takes real aS, real aP, real aT returns thistype
		set x = aS*Sin(aT)*Cos(aP)
		set y = aS*Sin(aT)*Sin(aP)
		set z = aS*Cos(aT)
		//
	//! runtextmacro P_VECTOR_INVERT("aT")
		//
		return this
	endmethod
	//
	method cylindric takes real aR, real aP, real aZ returns thistype
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
	method polar takes real aR, real aP returns thistype
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
		set inverted = true
		//
		return this
	endmethod
	method transvert takes nothing returns thistype
		set inverted = not inverted
		//
		return this
	endmethod

	//-------------
	// operations
	method add takes thistype aVector returns thistype
	//! textmacro P_VECTOR_ADD takes VECTOR, POS, NEG
		if ($VECTOR$ > 0) then
			set x = x $POS$ $VECTOR$.x
			set y = y $POS$ $VECTOR$.y
			set z = z $POS$ $VECTOR$.z
		else
			set $VECTOR$ = -$VECTOR$
			//
			set x = x $NEG$ $VECTOR$.x
			set y = y $NEG$ $VECTOR$.y
			set z = z $NEG$ $VECTOR$.z
		endif
	//! endtextmacro
	//! runtextmacro P_VECTOR_ADD("aVector", "+", "-")
		//
		return this
	endmethod
	method sub takes thistype aVector returns thistype
	//! runtextmacro P_VECTOR_ADD("aVector", "-", "+")
		//
		return this
	endmethod
	//
	method scale takes real aScale returns thistype
		set x = x*aScale
		set y = y*aScale
		set z = z*aScale
		//
		return this
	endmethod
	method flip takes nothing returns thistype
		return scale(-1)
	endmethod
	//
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

	//-------
	// copy
	method copy takes thistype aVector returns thistype
		set x = aVector.x
		set y = aVector.y
		set z = aVector.z
		//
		set inverted = aVector.inverted
		//
		set bound = aVector.bound
		//
		if (aVector.pLinked == 0) then
			set pLinked = 0
		elseif (aVector.pLinked > 0) then
			set pLinked = aVector.pLinked.lock()
		else
			set pLinked = -(thistype(-aVector.pLinked).lock())
		endif
		//
		return this
	endmethod

	//--------------------
	// relational fields
	unit bound
	//
	private thistype pLinked

	//-------
	// bind
	method bind takes unit aUnit returns thistype
		set bound = aUnit
		//
		return this
	endmethod
	method unbind takes nothing returns thistype
		return bind(null)
	endmethod
	//
	method debind takes nothing returns thistype
		set x = x + GetUnitX(bound)
		set y = y + GetUnitY(bound)
		set z = z + GetUnitFlyHeight(bound) + BlzGetLocalUnitZ(bound)
		//
		set bound = null
		//
		return this
	endmethod

	//-------
	// link
	method operator linked takes nothing returns thistype
		return pLinked
	endmethod
	method operator linked= takes thistype aVector returns nothing
	//! textmacro P_VECTOR_LINK takes VECTOR, RETURN
			//
			if (pLinked == $VECTOR$) then
				return $RETURN$
				//
			elseif (pLinked == -$VECTOR$) then
				set pLinked = $VECTOR$
				return $RETURN$
				//
			elseif (pLinked > 0) then
				call pLinked.unlock()
			elseif (pLinked < 0) then
				call thistype(-pLinked).unlock()
			endif
			//
			if ($VECTOR$ > 0) then
				set pLinked = $VECTOR$.lock()
			elseif ($VECTOR$ < 0) then
				set pLinked = -(thistype(-$VECTOR$).lock())
			else
				set pLinked = 0
			endif
			//
	//! endtextmacro
	//! runtextmacro P_VECTOR_LINK("aVector", "")
	endmethod
	//
	method link takes thistype aVector returns thistype
	//! runtextmacro P_VECTOR_LINK("aVector", "this")
		//
		return this
	endmethod
	method unlink takes nothing returns thistype
	//! textmacro P_VECTOR_UNLINK
			//
			if (pLinked > 0) then
				call pLinked.unlock()
			elseif (pLinked < 0) then
				call thistype(-pLinked).unlock()
			endif
			set pLinked = 0
			//
	//! endtextmacro
	//! runtextmacro P_VECTOR_UNLINK()
		//
		return this
	endmethod
	//
	method delink takes nothing returns thistype
		local thistype lLinked = pLinked
		//
		loop
			exitwhen lLinked == 0
			//
		//! textmacro P_VECTOR_ADD_LINKED takes VECTOR, LINKED, POS, NEG
				//
				if ($LINKED$ > 0) then
					set $VECTOR$.x = $VECTOR$.x $POS$ (Vector($LINKED$).x + GetUnitX(Vector($LINKED$).bound))
					set $VECTOR$.y = $VECTOR$.y $POS$ (Vector($LINKED$).y + GetUnitY(Vector($LINKED$).bound))
					set $VECTOR$.z = $VECTOR$.z $POS$ (Vector($LINKED$).z + GetUnitFlyHeight(Vector($LINKED$).bound) + BlzGetLocalUnitZ(Vector($LINKED$).bound))
				else
					set $LINKED$ = -$LINKED$
					set $VECTOR$.x = $VECTOR$.x $NEG$ (Vector($LINKED$).x + GetUnitX(Vector($LINKED$).bound))
					set $VECTOR$.y = $VECTOR$.y $NEG$ (Vector($LINKED$).y + GetUnitY(Vector($LINKED$).bound))
					set $VECTOR$.z = $VECTOR$.z $NEG$ (Vector($LINKED$).z + GetUnitFlyHeight(Vector($LINKED$).bound) + BlzGetLocalUnitZ(Vector($LINKED$).bound))
				endif
				//
		//! endtextmacro
		//! runtextmacro P_VECTOR_ADD_LINKED("this", "lLinked", "+", "-")
			//
			set lLinked = lLinked.pLinked
		endloop
		//
	//! runtextmacro P_VECTOR_UNLINK()
		//
		return this
	endmethod

	//------------
	// resultant
	method operator sum takes nothing returns psSum
		return this
	endmethod

	//-----------
	// lockable
//! runtextmacro LOCKABLE("nothing")
		//
		set x = 0
		set y = 0
		set z = 0
		//
		set inverted = false
		//
		set pLinked = 0
		//
//! runtextmacro LOCKABLE_DESTROY()
		//
		set bound = null
		//
	//! runtextmacro P_VECTOR_UNLINK()
		//
//! runtextmacro LOCKABLE_END()

	//------------
	// from unit
	static method operator unit takes nothing returns psUnit
		return 0
	endmethod

	//--------
	// clone
	method clone takes nothing returns thistype
		local thistype lClone = allocate()
		//
		set lClone.x = x
		set lClone.y = y
		set lClone.z = z
		//
		set lClone.inverted = inverted
		//
		set lClone.bound = bound
		//
		if (pLinked == 0) then
			set lClone.pLinked = 0
		elseif (pLinked > 0) then
			set lClone.pLinked = pLinked.lock()
		else
			set lClone.pLinked = -(thistype(-pLinked).lock())
		endif
		//
		return lClone
	endmethod

	implement LockableTempEx
endstruct
private struct psUnit extends array

	//
	method operator [] takes unit aUnit returns Vector
		set this = Vector.create()
		//
		set Vector(this).x = GetUnitX(aUnit)
		set Vector(this).y = GetUnitY(aUnit)
		set Vector(this).z = GetUnitFlyHeight(aUnit) + BlzGetLocalUnitZ(aUnit)
		//
		return this
	endmethod

endstruct
private struct psSum extends array

	//----------------
	// resultant xyz
//! textmacro P_VECTOR_SUM_XYZ takes XYZ, UNIT_XYZ

		//
		method operator $XYZ$ takes nothing returns real
			local real lReal = 0
			//
			loop
				if (this > 0) then
					set lReal = lReal + Vector(this).$XYZ$ + $UNIT_XYZ$
				else
					set this = -this
					set lReal = lReal - (Vector(this).$XYZ$ + $UNIT_XYZ$)
				endif
				//
				set this = Vector(this).linked
				exitwhen this == 0
			endloop
			//
			return lReal
		endmethod

//! endtextmacro
	//
//! runtextmacro P_VECTOR_SUM_XYZ("x", "GetUnitX(Vector(this).bound)")
//! runtextmacro P_VECTOR_SUM_XYZ("y", "GetUnitY(Vector(this).bound)")
//! runtextmacro P_VECTOR_SUM_XYZ("z", "GetUnitFlyHeight(Vector(this).bound) + BlzGetLocalUnitZ(Vector(this).bound)")

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

	//------------------
	// resultant clone
	method clone takes nothing returns Vector
		local Vector lClone = Vector.create()
		//
		loop
		//! runtextmacro P_VECTOR_ADD_LINKED("lClone", "this", "+", "-")
			//
			set this = Vector(this).linked
			exitwhen this == 0
		endloop
		//
		return lClone
	endmethod

	//--------
	// delta
	method getDelta takes Vector aTarget returns Vector
		local Vector lDelta = Vector.create()
		//
		local real lFlip
		//
		loop
		//! runtextmacro P_VECTOR_ADD_LINKED("lDelta", "this", "-", "+")
			//
			set this = Vector(this).linked
			exitwhen this == 0
		endloop
		//
		if (aTarget > 0) then
			set lFlip = 1
		else
			set lFlip = -1
		endif
		//
		loop
			exitwhen aTarget == 0
			//
		//! runtextmacro P_VECTOR_ADD_LINKED("lDelta", "aTarget", "+ lFlip*", "- lFlip*")
			//
			set aTarget = aTarget.linked
		endloop
		//
		return lDelta
	endmethod

endstruct


/*	(CHANGELOG)

	v1.1a:
	-----

	- added unit[]


	v1.2a:
	-----

	- optimized .unlink and .clone
	- added .debind and .delink


	v1.3a:
	-----

	- added .getLength and .getRadius
	- added .getAzimuth and .getDecline


	v1.3b:
	-----

	- improved the output of .getLength and similar methods when processing negative target


	v1.3c:
	-----

	- implemented LockableTempEx


	v1.3d:
	-----

	- fixed .getAzimuth and .getDecline


	v2.0a:
	-----

	- replaced .getX methods with .getDelta


	v2.1a:
	-----

	- added .copy

*/

endlibrary
