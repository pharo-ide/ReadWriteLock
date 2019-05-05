tests
testTerminatingReadWhichWaitingWriteAndAnotherRead

	| lastReadExecutedAfterWrite lastReaderExecuted secondReaderExecuted secondReader syncSemaphore writeSemaphore |
	lastReadExecutedAfterWrite := false.
	secondReaderExecuted := false.
	lastReaderExecuted := false.
	syncSemaphore := Semaphore new.
	writeSemaphore := Semaphore new.
	self fork: [
		lock criticalWrite: [ syncSemaphore signal. writeSemaphore wait. 
			lastReadExecutedAfterWrite := lastReaderExecuted not ]
	].	
	syncSemaphore wait.
	secondReader := self fork: [lock criticalRead: [ secondReaderExecuted := true ]].	
	self fork: [lock criticalRead: [ lastReaderExecuted := true ]].
	
	self passForkedProcesses.
	self deny: lastReaderExecuted.
	secondReader terminate.
	
	self passForkedProcesses. "Now last read should be still locked"
	self deny: lastReaderExecuted.
	writeSemaphore signal.
	self waitForkedProcesses.
	self assert: lastReaderExecuted.
	self deny: secondReaderExecuted.
	self assert: lastReadExecutedAfterWrite