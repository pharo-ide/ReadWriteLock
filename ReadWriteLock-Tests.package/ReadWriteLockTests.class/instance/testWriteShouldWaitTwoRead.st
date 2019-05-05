tests
testWriteShouldWaitTwoRead

	| writeExecutedAfterRead writeExecuted |
	writeExecutedAfterRead := nil.
	writeExecuted := false.

	self fork: [	lock criticalRead: [ 15 milliSeconds wait]].	
	self fork: [
		lock criticalRead: [ 25 milliSeconds wait. 
			writeExecutedAfterRead := writeExecuted not ].		
	].	
	self fork: [lock criticalWrite: [ writeExecuted := true ]].
	self waitForkedProcesses.
	
	self assert: writeExecuted.
	self assert: writeExecutedAfterRead
	