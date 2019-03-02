library Lockable

//! novjass
//
//	(INFO)

	Lockable v2.0a
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

	textmacro LOCKABLE_END


	MODULES:
	-------

	optional module LockableLock
	optional module LockableDelock
	optional module LockableUnlock
	optional module LockableDestroy

	module LockableEnd

//
//	(OUTPUT)

	METHODS:
	-------

	static method create takes $ARGS$ returns thistype

	method lock takes nothing returns thistype(this)
	method delock takes nothing returns thistype(this)
	method unlock takes nothing returns thistype(this)

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

		//------------
		// allocator
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

	//--------------
	// initializer
	private static method onInit takes nothing returns nothing
		set lockable_pg[0] = 1
	endmethod

endmodule

endlibrary
