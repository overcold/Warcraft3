# Lockable

Base object structure used for other systems.

An object that implements **Lockable** will specify `implement Lockable("ARGS")` with **ARGS** being the arguments of its **create** method.

```
struct Example extends array

	integer data

	implement Lockable("integer int")
	// this means this struct has:
		static method create takes integer int returns thistype
		// for the rest of this guide, suppose that this method assigns int to .data

	method getHexString takes nothing returns string
	// and suppose that this returns .data converted into a hexadecimal string

endstruct
```

**Lockable** objects are created the same way as regular structs are, but they lack the method **.destroy** and instead they use **.unlock** to deallocate instances. This is because a **Lockable** instance has an internal counter that counts how many times it has been locked. Locking an instance is done by calling **.lock** and will increase its lock-counter by 1. Unlocking an instance will do the reverse and if it ends up having a negative counter, it destroys the instance.

Here's an example of **create** and **.unlock** being used. Notice that **.unlock** fulfills the role of a deallocator.

```
function Integer2HexString takes integer i returns string
	local Example e = Example.create(i)
	local string hs = e.getHexString()
	call e.unlock()
	return hs
endfunction
```

The method **.unlock** actually does _not_ return nothing. It returns the object that calls it, allowing it to be chained with another method. With this info, let's rewrite the above function.

```
function Integer2HexString takes integer i returns string
	return Example.create(i).unlock().getHexString()
	// this is a BAD practice, but on some objects this can still work
endfunction
```

To understand the functionality of **.lock**, I'll be adding this struct.

```
struct Temp extends array

	private static Example pEx

	static method operator ex takes nothing returns Example
		return pEx
	endmethod

	static method operator ex= takes Example replacement returns nothing

		call pEx.unlock()
		// old .pEx is going to be replaced, unlock it

		set pEx = replacement.lock()
		// replacement is stored into .pEx, lock it
		// (notice that it can be written that way because .lock() returns replacement)

	endmethod

endstruct
```

Here's the same function as before but written differently, just to demonstrate how lock-counter works.

```
function Integer2HexString takes integer i returns string
	local string hs
	local Example e = Example.create(i)
	// e has 0 counter

	set Temp.ex = e
	// e has 1 counter, and keep in mind that Temp.ex == e

	set hs = Temp.ex.unlock().getHexString()
	// e has 0 counter, it is not yet destroyed

	call e.unlock()
	// e has -1 counter, destroying it in this process

	return hs
endfunction
```

This is a wrong version of it.

```
function Integer2HexString takes integer i returns string
	local string hs
	set Temp.ex = Example.create(i)
	// Temp.ex has 1 counter

	set hs = Temp.ex.getHexString()
	call Temp.ex.unlock()
	// Temp.ex has 0 counter, NOT yet being destroyed

	return hs
endfunction
```

And this is also wrong.

```
function Integer2HexString takes integer i returns string
	local string hs
	set Temp.ex = Example.create(i).unlock()
	// Temp.ex has 0 counter, but it got destroyed already

	set hs = Temp.ex.getHexString()
	call Temp.ex.unlock()
	// Temp.ex has -1 counter, and it is destroyed for the second time

	return hs
endfunction
```

That shows the behavior of objects that store other objects inside it. The storing object locks the stored object and unlocks it when it is no longer stored. This sometimes can cause trouble when passing objects, and because of this there's a method to unlock an instance without destroying it. The method is called **.delock** and it returns the object again just like **.lock** and **.unlock**.

```
function Integer2HexString takes integer i returns string
	local string hs
	set Temp.ex = Example.create(i).delock()
	// Temp.ex has 0 counter, and it didn't get destroyed

	set hs = Temp.ex.getHexString()
	call Temp.ex.unlock()
	// Temp.ex has -1 counter, and it is destroyed correctly

	return hs
endfunction
```

Lastly, because there's no **.destroy** method, boolean **.destroyed** is used to know whether an instance has been destroyed or not.

```
function TestUnlock takes Example e returns boolean
	if (e.unlock().destroyed) then
		call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Just destroyed an Example.")
		return true
	endif
	return false
endfunction
```

That should conclude the guide. Anything that is not covered by this guide should be directly inquired to me.

Below is an excerpt of the API list. For the complete list please refer to the script's header.

```
	static method create takes ARGS returns thistype

	method lock takes nothing returns thistype(this)
	method delock takes nothing returns thistype(this)
	method unlock takes nothing returns thistype(this)

	readonly boolean destroyed

```
