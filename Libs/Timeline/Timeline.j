library Timeline requires Lockable, GameTime

//! novjass
//	(INFO)

	Timeline v1.1a
	- by Overfrost


	REQUIRES:
	--------

	library Lockable
	library GameTime

//
//	(API)

	STRUCTS:
	-------

	struct Timeline extends array

		implement Lockable("nothing")

		readonly real start
		real length

		readonly real elapsed
		real remaining

		readonly real delta

		method restart takes nothing returns thistype(this)
		method lengthen takes real addedLength returns thistype(this)

//
//! endnovjass


//
struct Timeline extends array

	//---------
	// fields
	readonly real start
	real length
	//
	private real pMark
	private real pDelta

	//------------------
	// time difference
	method operator elapsed takes nothing returns real
		return GameTime.total - start
	endmethod
	method operator remaining takes nothing returns real
		return start + length - GameTime.total
	endmethod
	//
	method operator remaining= takes real aRemaining returns nothing
		set length = elapsed + aRemaining
	endmethod

	//--------
	// delta
	method operator delta takes nothing returns real
		local real lNow = GameTime.total
		local real lRem = start + length - lNow
		//
		if ((lNow - pMark) > 0) then
			set pDelta = lNow - pMark
			set pMark = lNow
		endif
		//
		if (length == 0 or lRem > 0) then
			return pDelta
		endif
		//
		return pDelta + lRem
	endmethod

	//------------
	// assigners
	method restart takes nothing returns thistype
		set start = GameTime.total
		//
		set pMark = start
		set pDelta = 0
		//
		return this
	endmethod
	//
	method lengthen takes real aLength returns thistype
		set length = length + aLength
		//
		return this
	endmethod

//! runtextmacro LOCKABLE("nothing")
		//
		set start = GameTime.total
		set length = 0
		//
		set pMark = start
		set pDelta = 0
		//
//! runtextmacro LOCKABLE_END()

endstruct


/*	(CHANGELOG)

	v1.1a:
	-----

	- .delta takes .remaining into account

*/

endlibrary
