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
	15 milliSeconds wait.
	
	writeExecuted should be: true.
	writeExecutedAfterRead should be: true.
	
	