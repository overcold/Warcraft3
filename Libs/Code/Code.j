library Code requires Lockable

//! novjass
//	(INFO)

	Code v1.0a
	- by Overfrost


	REQUIRES:
	--------

	library Lockable

//
//	(API)

	STRUCTS:
	-------

	struct Code extends array

		implement Lockable("code c")

		method clone takes nothing returns thistype

		static thistype invoked

		readonly boolexpr expr

		method invoke takes nothing returns thistype(this)

		thistype precode
		thistype postcode

		method prepend takes thistype toPrepend returns thistype(this)
		method append takes thistype toAppend returns thistype(this)

		method merge takes nothing returns thistype(this)

//
//! endnovjass


//
struct Code extends array

	//---------
	// fields
	private static trigger pgTrig = CreateTrigger()
	private static thistype pgInvoked
	//
	readonly boolexpr expr
	private boolean pDestroy
	//
	private thistype pLeft
	private thistype pRight

	//-------------
	// appendages
	method operator precode takes nothing returns thistype
		return pLeft
	endmethod
	method operator postcode takes nothing returns thistype
		return pRight
	endmethod
	//
	method operator precode= takes thistype aLeft returns nothing
	//! runtextmacro LOCKABLE_STORE("pLeft", "aLeft")
	endmethod
	method operator postcode= takes thistype aRight returns nothing
	//! runtextmacro LOCKABLE_STORE("pRight", "aRight")
	endmethod
	//
	method prepend takes thistype aLeft returns thistype
	//! runtextmacro LOCKABLE_STORE("pLeft", "aLeft")
		//
		return this
	endmethod
	method append takes thistype aRight returns thistype
	//! runtextmacro LOCKABLE_STORE("pRight", "aRight")
		//
		return this
	endmethod

	//--------
	// merge
//! textmacro P_CODE_LOOP
		//
		local thistype array lNode
		local boolean array lSwitch
		local integer l = 0
		//
		set lNode[0] = this
		//
		loop
			if (not lSwitch[l]) then
				if (pLeft != 0 and not lSwitch[l + 1]) then
					set this = pLeft
					set l = l + 1
					set lNode[l] = this
				else
					//
//! endtextmacro
//! textmacro P_CODE_LOOP_END
					//
					set lSwitch[l] = true
				endif
				//
			elseif (pRight != 0) then
				set this = pRight
				set l = l + 1
				set lNode[l] = this
				set lSwitch[l] = false
			else
				loop
					set lSwitch[l + 1] = false
					set l = l - 1
					//
					exitwhen (l < 0) or (not lSwitch[l])
				endloop
				//
				exitwhen l < 0
				//
				set this = lNode[l]
			endif
		endloop
		//
		set this = lNode[0]
		//
//! endtextmacro
	//
	method merge takes nothing returns thistype
		local boolexpr lExpr = null
		local boolexpr lTemp
		//
	//! runtextmacro P_CODE_LOOP()
			//
			set lTemp = Or(lExpr, expr)
			call DestroyBoolExpr(lExpr)
			set lExpr = lTemp
			//
	//! runtextmacro P_CODE_LOOP_END()
		//
	//! runtextmacro LOCKABLE_NULL("pLeft")
	//! runtextmacro LOCKABLE_NULL("pRight")
		//
		if (pDestroy) then
			call DestroyBoolExpr(expr)
		else
			set pDestroy = true
		endif
		set expr = lExpr
		//
		set lExpr = null
		set lTemp = null
		//
		return this
	endmethod

	//---------
	// invoke
	static method operator invoked takes nothing returns thistype
		return pgInvoked
	endmethod
	method invoke takes nothing returns thistype
		local boolean lExit
		//
	//! runtextmacro P_CODE_LOOP()
			//
			set pgInvoked = this
			//
			call TriggerAddCondition(pgTrig, expr)
			set lExit = TriggerEvaluate(pgTrig)
			call TriggerClearConditions(pgTrig)
			//
			exitwhen lExit
			//
	//! runtextmacro P_CODE_LOOP_END()
		//
		return this
	endmethod

	//-----------
	// lockable
//! runtextmacro LOCKABLE("code aFunc")
		//
		set expr = Condition(aFunc)
		set pDestroy = false
		//
		set pLeft = 0
		set pRight = 0
		//
//! runtextmacro LOCKABLE_DESTROY()
		//
		if (pDestroy) then
			call DestroyBoolExpr(expr)
		endif
		set expr = null
		//
	//! runtextmacro LOCKABLE_NULL("pLeft")
	//! runtextmacro LOCKABLE_NULL("pRight")
		//
//! runtextmacro LOCKABLE_END()

	//--------
	// clone
	method clone takes nothing returns thistype
		local thistype lClone = allocate()
		//
		if (pDestroy) then
			set lClone.expr = Or(expr, null)
			set lClone.pDestroy = true
		else
			set lClone.expr = expr
			set lClone.pDestroy = false
		endif
		//
	//! runtextmacro LOCKABLE_STORE("lClone.pLeft", "pLeft")
	//! runtextmacro LOCKABLE_STORE("lClone.pRight", "pRight")
		//
		return lClone
	endmethod

endstruct

endlibrary
