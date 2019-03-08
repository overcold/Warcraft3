library Lockable

//! novjass
//
//	(INFO)

	Lockable v2.2a
	- by Overfrost

//
//	(PP API)

	MACROS:
	------

	textmacro LOCKABLE takes ARGS

	optional textmacro LOCKABLE_LOCK
	optional textmacro LOCKABLE_DELOCK
	optional textmacro LOCKABLE_UNLOCK
	optional textmacro LOCKABLE_DESTROY
	// all contains:
		local integer locks

	textmacro LOCKABLE_END


	MODULES:
	-------

	optional module LockableLock
	optional module LockableDelock
	optional module LockableUnlock
	optional module LockableDestroy
	// all contains:
		local integer locks

	module LockableEnd

//
//	(OUTPUT)

	MEMBERS:
	-------

	static thistype temp

	readonly boolean destroyed

	static method create takes $ARGS$ returns thistype

	method lock takes nothing returns thistype(this)
	method delock takes nothing returns thistype(this)
	method unlock takes nothing returns thistype(this)

	private static method allocate takes nothing returns thistype
	private method deallocate takes nothing returns boolean

//
//! endnovjass


//
//! textmacro LOCKABLE takes ARGS

		//-------
		// base
		private static thistype array lockable_pg
		private integer lockable_p
		//
		method operator destroyed takes nothing returns boolean
			return lockable_p < 0
		endmethod

		//-------------
		// allocators
		private static method allocate takes nothing returns thistype
			local thistype this = lockable_pg[0]
			//
			if (lockable_pg[this] == 0) then
				set lockable_pg[0] = this + 1
			else
				set lockable_pg[0] = lockable_pg[this]
			endif
			//
			set lockable_p = 0
			//
			return this
		endmethod
		private method deallocate takes nothing returns boolean
			set lockable_p = lockable_p - 1
			//
			if (destroyed) then
				set lockable_pg[this] = lockable_pg[0]
				set lockable_pg[0] = this
				//
				return true
			endif
			//
			return false
		endmethod

		//
		static method create takes $ARGS$ returns thistype
			local thistype this = lockable_pg[0]
			//
//! endtextmacro
//! textmacro LOCKABLE_LOCK
		implement LockableLock
//! endtextmacro
//! textmacro LOCKABLE_DELOCK
		implement LockableDelock
//! endtextmacro
//! textmacro LOCKABLE_UNLOCK
		implement LockableUnlock
//! endtextmacro
//! textmacro LOCKABLE_DESTROY
		implement LockableDestroy
//! endtextmacro
//! textmacro LOCKABLE_END
		implement LockableEnd
//! endtextmacro

//---------------------
// partitioned module
module LockableLock
		//
		if (lockable_pg[this] == 0) then
			set lockable_pg[0] = this + 1
		else
			set lockable_pg[0] = lockable_pg[this]
		endif
		//
		set lockable_p = 0
		//
		return this
	endmethod

	//
	method lock takes nothing returns thistype
		local integer locks = lockable_p + 1
		//
endmodule
module LockableDelock
	implement LockableLock
		//
		set lockable_p = lockable_p + 1
		//
		return this
	endmethod

	method delock takes nothing returns thistype
		local integer locks = lockable_p - 1
		//
endmodule
module LockableUnlock
	implement LockableDelock
		//
		set lockable_p = lockable_p - 1
		//
		return this
	endmethod

	//
	method unlock takes nothing returns thistype
		local integer locks = lockable_p - 1
		//
endmodule
module LockableDestroy
	implement LockableUnlock
		//
		set lockable_p = lockable_p - 1
		//
		if (destroyed) then
			//
endmodule
module LockableEnd
	implement LockableDestroy
			//
			set lockable_pg[this] = lockable_pg[0]
			set lockable_pg[0] = this
		endif
		//
		return this
	endmethod

	//-------
	// temp
	private static thistype pgTemp = 0
	//
	static method operator temp takes nothing returns thistype
		return pgTemp
	endmethod
	static method operator temp= takes thistype a returns nothing
		if (pgTemp == a) then
			return
		elseif (pgTemp != 0) then
			call pgTemp.unlock()
		endif
		//
		set pgTemp = a
	endmethod

	//--------------
	// initializer
	private static method onInit takes nothing returns nothing
		set lockable_pg[0] = 1
	endmethod

endmodule


/*	(CHANGELOG)

	v2.1a:
	-----

	- added allocate and .deallocate


	v2.2a:
	-----

	- added temp

*/

endlibrary
