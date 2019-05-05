tests
testReadShouldWaitWrite

	| readExecutedAfterWrite readExecuted |
	readExecutedAfterWrite := nil.
	readExecuted := false.

	self fork: [
		lock criticalWrite: [ 10 milliSeconds wait. 
			readExecutedAfterWrite := readExecuted not]
	].	
	self fork: [lock criticalRead: [ readExecuted := true ]].
	self waitForkedProcesses.
	
	self assert: readExecuted.
	self assert: readExecutedAfterWrite
	