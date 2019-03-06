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
	// and suppose that this returns the data converted into a hexadecimal string

endstruct
```

**Lockable** objects have to be created, but not destroyed. Instead of being destroyed, they need to be unlocked.

```
function Integer2HexString takes integer i returns string
	local Example ex = Example.create(i)
	local string hs = ex.getHexString()
	call ex.unlock()
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


