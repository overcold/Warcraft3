library Lockable requires optional Debug

//! novjass
//
//	(INFO)

	Lockable v2.5a
	- by Overfrost


	REQUIRES:
	--------

	optional library Debug

//
//	(BLOCK API)

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
//	(PP API)

	MODULES:
	-------

	module LockableTempEx


	MACROS:
	------

	textmacro LOCKABLE_STORE takes STORAGE, TO_BE_STORED
	textmacro LOCKABLE_NULL takes STORAGE

//
//! endnovjass


//---------------
// main builder
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

		static if LIBRARY_Debug then
			call Debug.printFunc(lock.name, I2S(lockable_p), 0x00FF00, "-> " + I2S(lockable_p))
		endif

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

		static if LIBRARY_Debug then
			if (destroyed) then
				call Debug.printFunc(unlock.name, I2S(lockable_p), 0xFF0000, "-> " + I2S(lockable_p) + " = destroyed")
			else
				call Debug.printFunc(unlock.name, I2S(lockable_p), 0xFF0000, "-> " + I2S(lockable_p))
			endif
		endif

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
//! textmacro P_LOCKABLE_TEMP takes ID

		//
		private static thistype pgTemp = 0
		//
		static method operator $ID$ takes nothing returns thistype
			return pgTemp
		endmethod
		static method operator $ID$= takes thistype a returns nothing
			if (pgTemp != 0) then
				call pgTemp.unlock()
			endif
			//
			set pgTemp = a
		endmethod

//! endtextmacro
//! runtextmacro P_LOCKABLE_TEMP("temp")

	//--------------
	// initializer
	private static method onInit takes nothing returns nothing
		set lockable_pg[0] = 1
	endmethod

endmodule

//-------------
// extra temp
module LockableTempEx

	//
//! runtextmacro P_LOCKABLE_TEMP("tempEx")

endmodule

//---------
// helper
//! textmacro LOCKABLE_STORE takes VAR, VALUE
		//
		if ($VAR$ != $VALUE$) then
			if ($VAR$ != 0) then
				call $VAR$.unlock()
			endif
			//
			if ($VALUE$ == 0) then
				set $VAR$ = 0
			else
				set $VAR$ = $VALUE$.lock()
			endif
		endif
		//
//! endtextmacro
//! textmacro LOCKABLE_NULL takes VAR
		//
		if ($VAR$ != 0) then
			call $VAR$.unlock()
		endif
		set $VAR$ = 0
		//
//! endtextmacro


/*	(CHANGELOG)

	v2.1a:
	-----

	- added allocate and .deallocate


	v2.2a:
	-----

	- added temp


	v2.3a:
	-----

	- added LOCKABLE_STORE and LOCKABLE_NULL


	v2.4a:
	-----

	- improved how temp works
	- added LockableTempEx


	v2.5a:
	-----

	- added Debug support

*/

endlibrary
