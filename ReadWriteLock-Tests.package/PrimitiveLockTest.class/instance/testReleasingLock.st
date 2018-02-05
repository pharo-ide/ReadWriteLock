tests
testReleasingLock

	| lastExecuted syncSemaphore lockSemaphore |
	lastExecuted := false.
	syncSemaphore := Semaphore new.
	lockSemaphore := Semaphore new.

	self fork: [ lock acquire. syncSemaphore signal. lockSemaphore wait].
	self fork: [ lock acquire. lastExecuted := true].
	syncSemaphore wait.
	self passForkedProcesses.
	lock release.	
	self waitLastProcessFinished.
	self assert: lastExecuted