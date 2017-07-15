initialization
initialize
	super initialize.
	
	readLock := PrimitiveLock new.
	currentReaders := 0.
	writeLock := PrimitiveLock new.