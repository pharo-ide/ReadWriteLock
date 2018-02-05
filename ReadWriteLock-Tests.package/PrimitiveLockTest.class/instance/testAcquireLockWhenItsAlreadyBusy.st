tests
testAcquireLockWhenItsAlreadyBusy

	| lastLockAcquired syncSemaphore lockSemaphore |
	lastLockAcquired := false.
	syncSemaphore := Semaphore new.
	lockSemaphore := Semaphore new.
	self fork: [ lock acquire. syncSemaphore signal. lockSemaphore wait. ].
	syncSemaphore wait.
	self fork: [ lock acquire. lastLockAcquired := true ].
	self passForkedProcesses.
	lockSemaphore signal.
	
	self deny: lastLockAcquired
	