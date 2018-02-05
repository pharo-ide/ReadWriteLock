tests
testTerminatingWriteWhichWaitingAnotherTwoWrites

	| lastWriteExecutedAfterFirst lastWriteExecuted secondWriteExecuted secondWriter syncSemaphore writeSemaphore |
	lastWriteExecutedAfterFirst := false.
	secondWriteExecuted := false.
	lastWriteExecuted := false.
	syncSemaphore := Semaphore new.
	writeSemaphore := Semaphore new.
	self fork: [
		lock criticalWrite: [ syncSemaphore signal. writeSemaphore wait.
			lastWriteExecutedAfterFirst := lastWriteExecuted not ]
	].	
	syncSemaphore wait.
	secondWriter := self fork: [lock criticalWrite: [ secondWriteExecuted := true ]].	
	self fork: [lock criticalWrite: [ lastWriteExecuted := true ]].
	
	self passForkedProcesses.
	lastWriteExecuted should be: false.
	secondWriter terminate.
	writeSemaphore signal.	
	self waitForkedProcesses.
	lastWriteExecuted should be: true.
	secondWriteExecuted should be: false.
	lastWriteExecutedAfterFirst should be: true