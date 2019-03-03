library Effect requires Lockable, Color

//! novjass
//	(INFO)

	Effect v1.0a
	- by Overfrost


	REQUIRES:
	--------

	library Lockable
	library Color

//
//	(API)

	STRUCTS:
	-------

	struct Effect extends array

		implement Lockable

		static method create takes string modelPath returns thistype
		static method attach takes string modelPath, widget w, string attachPoint returns thistype

		readonly widget widget

		Color color
		integer alpha
		player owner

		method colorize takes Color color, integer alpha, player owner returns thistype(this)

		real scale
		real speed

		readonly boolean hidden

		method hide takes nothing returns thistype(this)
		method unhide takes nothing returns thistype(this)

		real yaw
		real pitch
		real roll

		method orient takes real yaw, real pitch, real roll returns thistype(this)

		real x
		real y
		real z

		real height

		method move takes real x, real y, real z returns thistype(this)

		method animate takes animtype animation returns thistype(this)

		method addAnimTag takes subanimtype animTag returns thistype(this)
		method removeAnimTag takes subanimtype animTag returns thistype(this)
		method clearAnimTags takes nothing returns thistype(this)

//
//! endnovjass


struct Effect extends array

	//---------
	// fields
	private effect pEffect
	//
	private Color pColor
	private integer pAlpha
	private player pOwner
	//
	private real pScale
	private real pSpeed
	//
	private integer pHide
	//
	private real pYaw  // wc3: roll
	private real pPitch
	private real pRoll  // wc3: yaw
	//
	private real pX
	private real pY
	private real pZ
	//
	private real pHeight
	//
	readonly widget widget

	//--------
	// color
	method operator color takes nothing returns Color
		return pColor
	endmethod
	method operator alpha takes nothing returns integer
		return pAlpha
	endmethod
	method operator owner takes nothing returns player
		return pOwner
	endmethod
	//
	method operator color= takes Color aColor returns nothing
		call BlzSetSpecialEffectColor(pEffect, aColor.r, aColor.g, aColor.b)
		set pColor = aColor
	endmethod
	method operator alpha= takes integer aAlpha returns nothing
		if (pHide == 0 or widget != null) then
			call BlzSetSpecialEffectAlpha(pEffect, aAlpha)
		endif
		set pAlpha = aAlpha
	endmethod
	method operator owner= takes player aOwner returns nothing
		call BlzSetSpecialEffectColorByPlayer(pEffect, aOwner)
		set pOwner = aOwner
	endmethod
	//
	method colorize takes Color aColor, integer aAlpha, player aOwner returns thistype
		call BlzSetSpecialEffectColor(pEffect, aColor.r, aColor.g, aColor.b)
		call BlzSetSpecialEffectAlpha(pEffect, aAlpha)
		call BlzSetSpecialEffectColorByPlayer(pEffect, aOwner)
		//
		set pColor = aColor
		set pAlpha = aAlpha
		set pOwner = aOwner
		//
		return this
	endmethod

	//---------
	// scales
	method operator scale takes nothing returns real
		return pScale
	endmethod
	method operator speed takes nothing returns real
		return pSpeed
	endmethod
	//
	method operator scale= takes real aScale returns nothing
		call BlzSetSpecialEffectScale(pEffect, aScale)
		set pScale = aScale
	endmethod
	method operator speed= takes real aSpeed returns nothing
		call BlzSetSpecialEffectTimeScale(pEffect, aSpeed)
		set pSpeed = aSpeed
	endmethod

	//-------
	// hide
	method operator hidden takes nothing returns boolean
		return pHide > 0
	endmethod
	//
	method hide takes nothing returns thistype
		if (pHide == 0) then
			if (widget == null) then
				call BlzSetSpecialEffectPosition(pEffect, 0x8000, 0x8000, 0)
			else
				call BlzSetSpecialEffectAlpha(pEffect, 0)
			endif
		endif
		set pHide = pHide + 1
		//
		return this
	endmethod
	method unhide takes nothing returns thistype
		if (pHide > 0) then
			set pHide = pHide - 1
			if (pHide == 0) then
				if (widget == null) then
					call BlzSetSpecialEffectPosition(pEffect, pX, pY, pZ + pHeight)
				else
					call BlzSetSpecialEffectAlpha(pEffect, pAlpha)
				endif
			endif
		endif
		//
		return this
	endmethod

	//--------------
	// orientation
//! textmacro P_EFFECT_MS_ORIENTATION takes ROLL, PITCH

		//
		method operator yaw takes nothing returns real
			return pYaw
		endmethod
		method operator pitch takes nothing returns real
			return pPitch
		endmethod
		method operator roll takes nothing returns real
			return pRoll
		endmethod
		//
		method operator yaw= takes real aYaw returns nothing
			set pYaw = aYaw
			call BlzSetSpecialEffectOrientation(pEffect, $ROLL$, $PITCH$, aYaw)
		endmethod
		method operator pitch= takes real aPitch returns nothing
			set pPitch = aPitch
			call BlzSetSpecialEffectOrientation(pEffect, $ROLL$, $PITCH$, pYaw)
		endmethod
		method operator roll= takes real aRoll returns nothing
			set pRoll = aRoll
			call BlzSetSpecialEffectOrientation(pEffect, $ROLL$, $PITCH$, pYaw)
		endmethod
		//
		method orient takes real aYaw, real aPitch, real aRoll returns thistype
			set pYaw = aYaw
			set pPitch = aPitch
			set pRoll = aRoll
			//
			call BlzSetSpecialEffectOrientation(pEffect, $ROLL$, $PITCH$, aYaw)
			//
			return this
		endmethod

//! endtextmacro
//! runtextmacro P_EFFECT_MS_ORIENTATION("pRoll*Cos(pYaw) - pPitch*Sin(pYaw)", "pRoll*Sin(pYaw) + pPitch*Cos(pYaw)")

	//-----------
	// position
//! textmacro P_EFFECT_XYZ takes XYZ0, XYZ1, EXTRAS

		//
		method operator $XYZ0$ takes nothing returns real
			return p$XYZ1$
		endmethod
		method operator $XYZ0$= takes real a returns nothing
			if (pHide == 0) then
				call BlzSetSpecialEffect$XYZ1$(pEffect, a $EXTRAS$)
			endif
			set p$XYZ1$ = a
		endmethod

//! endtextmacro
	//
//! runtextmacro P_EFFECT_XYZ("x", "X", "")
//! runtextmacro P_EFFECT_XYZ("y", "Y", "")
//! runtextmacro P_EFFECT_XYZ("z", "Z", "+ pHeight")
	//
	method move takes real aX, real aY, real aZ returns thistype
		call BlzSetSpecialEffectPosition(pEffect, aX, aY, aZ + pHeight)
		//
		set pX = aX
		set pY = aY
		set pZ = aZ
		//
		return this
	endmethod

	//---------
	// height
	method operator height takes nothing returns real
		return pHeight
	endmethod
	method operator height= takes real aHeight returns nothing
		call BlzSetSpecialEffectZ(pEffect, pZ + aHeight)
		set pHeight = aHeight
	endmethod

	//------------
	// animation
	method animate takes animtype aAnim returns thistype
		call BlzPlaySpecialEffect(pEffect, aAnim)
		//
		return this
	endmethod

	//-----------------
	// animation tags
	method addAnimTag takes subanimtype aTag returns thistype
		call BlzSpecialEffectAddSubAnimation(pEffect, aTag)
		//
		return this
	endmethod
	//
	method removeAnimTag takes subanimtype aTag returns thistype
		call BlzSpecialEffectRemoveSubAnimation(pEffect, aTag)
		//
		return this
	endmethod
	method clearAnimTags takes nothing returns thistype
		call BlzSpecialEffectClearSubAnimations(pEffect)
		//
		return this
	endmethod

	//----------------
	// instantiators
//! textmacro P_EFFECT_INIT
		//
		set pColor = 0xFFFFFF
		set pAlpha = 0xFF
		set pOwner = Player(0)
		//
		set pScale = 1
		set pSpeed = 1
		//
		set pHide = 0
		//
		set pYaw = 0
		set pPitch = 0
		set pRoll = 0
		//
		set pX = 0x8000
		set pY = 0x8000
		set pZ = 0
		//
		set pHeight = 0
		//
//! endtextmacro
//! runtextmacro LOCKABLE("string aPath")
		//
		set pEffect = AddSpecialEffect(aPath, 0x8000, 0x8000)
		//
	//! runtextmacro P_EFFECT_INIT()
		//
//! runtextmacro LOCKABLE_DESTROY()
		//
		call DestroyEffect(pEffect)
		set pEffect = null
		set widget = null
		//
//! runtextmacro LOCKABLE_END()
	//
	static method attach takes string aPath, widget aWidget, string aPoint returns thistype
		local thistype this = allocate()
		//
		set pEffect = AddSpecialEffectTarget(aPath, aWidget, aPoint)
		set widget = aWidget
		//
	//! runtextmacro P_EFFECT_INIT()
		//
		return this
	endmethod

endstruct

endlibrary
