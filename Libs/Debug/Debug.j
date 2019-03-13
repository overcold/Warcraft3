library Debug requires GameTime, Color

//! novjass
//	(INFO)

	Debug v0.1a
	- by Overfrost


	REQUIRES:
	--------

	library GameTime
	library Color

//
//	(API)

	STRUCTS:
	-------

	struct Debug extends array

		static method print takes string toBePrinted returns nothing

		static method printFunc takes string name, string args, Color resultColor, string result returns nothing

//
//! endnovjass


//
struct Debug extends array

	//--------
	// print
	static method print takes string aString returns nothing
		call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 0x100, "|cffffcc00" + GameTime.getString(":") + "|r " + aString)
	endmethod
	//
	static method printFunc takes string aName, string aArgs, Color aColor, string aResult returns nothing
		call print(aName + "|cff8080ff(" + aArgs + ")|r " + aColor.colorize(aResult))
	endmethod

endstruct

endlibrary
