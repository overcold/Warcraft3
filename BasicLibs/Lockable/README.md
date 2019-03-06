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


