tests
testAcquireLockWhenItsAlreadyBusy

	| lastLockAcquired |
	lastLockAcquired := false.
	self fork: [ lock acquire. 10 seconds wait. ].
	self fork: [ lock acquire. lastLockAcquired := true ].
	10 milliSeconds wait.
	
	self deny: lastLockAcquired
	