library Bullet requires Lockable, Vector, Effect

//! novjass
//	(INFO)

	Bullet v1.0a
	- by Overfrost


	REQUIRES:
	--------

	library Lockable
	library Vector
	library Effect

//
//	(API)

	STRUCTS:
	-------

	struct Vector extends array

		implement Lockable("string modelPath, Vector source, Vector target")

		readonly Effect vfx

		readonly Vector source

		readonly Vector disp
		readonly real dist

		Vector target

		method advance takes real distance returns thistype(this)

		method restart takes Vector source returns thistype(this)
		method retarget takes Vector target returns thistype(this)

//
//! endnovjass


//
struct Bullet extends array

	//---------
	// fields
	readonly Effect vfx
	readonly Vector source
	//
	readonly Vector disp
	readonly real dist
	//
	private Vector pTarget
	//
	readonly boolean reached

	//---------
	// target
	method operator target takes nothing returns Vector
		return pTarget
	endmethod
	method operator target= takes Vector aTarget returns nothing
		if (pTarget == aTarget) then
			return
		endif
		//
		call pTarget.unlock()
		//
	//! textmacro P_BULLET_STORE_ZERO takes VAR, VALUE
			//
			if ($VALUE$ == 0) then
				set $VAR$ = Vector.create()
			else
				set $VAR$ = $VALUE$.lock()
			endif
			//
	//! endtextmacro
	//! runtextmacro P_BULLET_STORE_ZERO("pTarget", "aTarget")
	endmethod
	//
	method retarget takes Vector aTarget returns thistype
		if (pTarget == aTarget) then
			return this
		endif
		//
		call pTarget.unlock()
		//
	//! runtextmacro P_BULLET_STORE_ZERO("pTarget", "aTarget")
		//
		return this
	endmethod

	//----------
	// restart
	method restart takes Vector aSource returns thistype
		if (aSource == disp) then
			call source.unlock()
			set source = aSource
			//
			set disp = Vector.create().link(source)
			//
		elseif (aSource == source) then
			set disp.x = 0
			set disp.y = 0
			set disp.z = 0
		else
			call source.unlock()
			//
		//! runtextmacro P_BULLET_STORE_ZERO("source", "aSource")
			//
			set disp.x = 0
			set disp.y = 0
			set disp.z = 0
			//
			set disp.linked = source
		endif
		//
		call vfx.position(source)
		//
		set dist = 0
		set reached = false
		//
		return this
	endmethod

	//----------
	// advance
	method advance takes real aDist returns thistype
		local real lGap = disp.getLength(pTarget)
		//
		if (aDist >= lGap) then
			set reached = true
			set aDist = lGap
		endif
		//
		set Vector.temp = Vector.create().spheric(aDist, /*
			*/ disp.getAzimuth(pTarget), disp.getDecline(pTarget))
		//
		call vfx.position(disp.add(Vector.temp))
		//
		if (aDist > 0) then
			set dist = dist + aDist
		else
			set dist = dist - aDist
		endif
		//
		return this
	endmethod

	//-----------
	// lockable
//! runtextmacro LOCKABLE("string aPath, Vector aSource, Vector aTarget")
		//
		if (aSource == 0) then
			set vfx = Effect.create(aPath).move(0, 0, 0)
			set source = Vector.create()
		else
			set vfx = Effect.create(aPath).position(aSource)
			set source = aSource.lock()
		endif
		//
	//! runtextmacro P_BULLET_STORE_ZERO("pTarget", "aTarget")
		//
		set disp = Vector.create().link(source)
		set dist = 0
		//
		set reached = false
		//
//! runtextmacro LOCKABLE_DESTROY()
		//
		call vfx.unlock()
		call source.unlock()
		call pTarget.unlock()
		call disp.unlock()
		//
//! runtextmacro LOCKABLE_END()

endstruct

endlibrary
