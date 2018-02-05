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
	lastReaderExecuted should be: false.
	secondReader terminate.
	writeSemaphore signal.
	self waitForkedProcesses.
	lastReaderExecuted should be: true.
	secondReaderExecuted should be: false.
	lastReadExecutedAfterWrite should be: true