tests
testWriteShouldWaitRead

	| writeExecutedAfterRead writeExecuted |
	writeExecutedAfterRead := nil.
	writeExecuted := false.

	self fork: [
		lock criticalRead: [ 10 milliSeconds wait. 
			writeExecutedAfterRead := writeExecuted not ]
	].	
	self fork: [lock criticalWrite: [ writeExecuted := true ]].
	self waitForkedProcesses.
	
	writeExecuted should be: true.
	writeExecutedAfterRead should be: true.
	
	