tests
testTerminatingReadWhichWaitingWriteAndAnotherRead

	| lastReadExecutedAfterWrite lastReaderExecuted secondReaderExecuted secondReader |
	lastReadExecutedAfterWrite := false.
	secondReaderExecuted := false.
	lastReaderExecuted := false.

	self fork: [
		lock criticalWrite: [ 10 milliSeconds wait. 
			lastReadExecutedAfterWrite := lastReaderExecuted not ]
	].	
	secondReader := self fork: [lock criticalRead: [ secondReaderExecuted := true ]].	
	self fork: [lock criticalRead: [ lastReaderExecuted := true ]].
	10 milliSeconds wait.
	secondReader terminate.
	15 milliSeconds wait.	
	lastReaderExecuted should be: true.
	secondReaderExecuted should be: false.
	lastReadExecutedAfterWrite should be: true