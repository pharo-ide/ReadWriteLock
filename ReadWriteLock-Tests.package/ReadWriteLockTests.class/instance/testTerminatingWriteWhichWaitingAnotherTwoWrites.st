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
	self deny: lastWriteExecuted.
	secondWriter terminate.
	writeSemaphore signal.	
	self waitForkedProcesses.
	self assert: lastWriteExecuted.
	self deny: secondWriteExecuted.
	self assert: lastWriteExecutedAfterFirst