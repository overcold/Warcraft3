library OverTime requires Lockable, Code

//! novjass
//	(INFO)

	OverTime v1.0a
	- by Overfrost


	REQUIRES:
	--------

	library Lockable
	library Code

//
//	(API)

	STRUCTS:
	-------

	struct OverTime extends array

		implement Lockable("Code action")

		static method operator code[] takes code actionFunc returns thistype

		static readonly thistype acting

		static readonly real period
		static readonly integer frequency

		Code action

		integer priority

		method prioritize takes integer priority returns thistype(this)

//
//	(CONFIG)

	CONFIG:
	------

	constant real period
	constant integer frequency


	DEFAULT:
	-------

	constant integer priority

//
//! endnovjass


//
private struct Config extends array

	//
	static method operator period takes nothing returns real
		return 0.03125
	endmethod
	//
	static method operator frequency takes nothing returns integer
		return 32
	endmethod

endstruct
//
private struct Default extends array

	//
	static method operator priority takes nothing returns integer
		return 0
	endmethod

endstruct

//
private keyword ps
private keyword pm
//
struct OverTime extends array

	//---------
	// fields
	private static thistype pgActing
	//
	private static thistype array pgNext
	private static thistype array pgPrev
	//
	private Code pAction
	//
	private integer pPriority

	//-------------------
	// period/frequency
	static method operator period takes nothing returns real
		return Config.period
	endmethod
	static method operator frequency takes nothing returns integer
		return Config.frequency
	endmethod

	//-------
	// list
//! textmacro P_OVER_TIME_LIST takes OVER_TIME, PRIORITY
		//
		loop
			set l = pgNext[l]
			exitwhen l.pPriority >= $PRIORITY$ or l == 0
		endloop
		//
		set pgNext[$OVER_TIME$] = l
		set pgPrev[$OVER_TIME$] = pgPrev[l]
		set pgNext[pgPrev[l]] = $OVER_TIME$
		set pgPrev[l] = $OVER_TIME$
		//
//! endtextmacro
//! textmacro P_OVER_TIME_UNLIST takes OVER_TIME
		//
		set pgNext[pgPrev[$OVER_TIME$]] = pgNext[$OVER_TIME$]
		set pgPrev[pgNext[$OVER_TIME$]] = pgPrev[$OVER_TIME$]
		//
//! endtextmacro

	//---------
	// action
	method operator action takes nothing returns Code
		return pAction
	endmethod
	method operator action= takes Code aAction returns nothing
		if pAction != aAction then
			call pAction.unlock()
			set pAction = aAction.lock()
		endif
	endmethod

	//-----------
	// priority
	method operator priority takes nothing returns integer
		return pPriority
	endmethod
	method operator priority= takes integer aPriority returns nothing
		local thistype l = 0
		//
		set pPriority = aPriority
		//
	//! runtextmacro P_OVER_TIME_UNLIST("this")
	//! runtextmacro P_OVER_TIME_LIST("this", "aPriority")
	endmethod
	method prioritize takes integer aPriority returns thistype
		local thistype l = 0
		//
		set pPriority = aPriority
		//
	//! runtextmacro P_OVER_TIME_UNLIST("this")
	//! runtextmacro P_OVER_TIME_LIST("this", "aPriority")
		//
		return this
	endmethod

	//---------
	// acting
	static method operator acting takes nothing returns thistype
		return pgActing
	endmethod

	//-----------
	// lockable
//! runtextmacro LOCKABLE("Code aAction")
		//
		local thistype l = 0
		//
		set pAction = aAction.lock()
		//
		set pPriority = Default.priority
		//
	//! runtextmacro P_OVER_TIME_LIST("this", "Default.priority")
		//
//! runtextmacro LOCKABLE_DESTROY()
		//
		call pAction.unlock()
		//
	//! runtextmacro P_OVER_TIME_UNLIST("this")
		//
//! runtextmacro LOCKABLE_END()

	//-------
	// code
	static method operator code takes nothing returns ps
		return 0
	endmethod

	//-----------
	// periodic
	private static method pgOnExpire takes nothing returns nothing
		local thistype l = 0
		//
		loop
			set l = pgNext[l]
			exitwhen l == 0
			//
			set pgActing = l
			call l.pAction.invoke()
		endloop
	endmethod

	implement pm
endstruct
private struct ps extends array

	//
	method operator [] takes code aFunc returns OverTime
		return this + OverTime.create(Code.create(aFunc).delock())
	endmethod

endstruct
private module pm

	//
	private static method onInit takes nothing returns nothing
		call TimerStart(CreateTimer(), Config.period, true, function thistype.pgOnExpire)
	endmethod

endmodule

endlibrary
