tests
testMultipleWritesShouldWaitEachOther

	| lastWriteExecutedAfterFirst lastWriteExecuted |
	lastWriteExecutedAfterFirst := nil.
	lastWriteExecuted := false.

	self fork: [
		lock criticalWrite: [ 10 milliSeconds wait. 
			lastWriteExecutedAfterFirst := lastWriteExecuted not]
	].	
	self fork: [lock criticalWrite: [ lastWriteExecuted := true ]].
	self waitForkedProcesses.
	
	lastWriteExecuted should be: true.
	lastWriteExecutedAfterFirst should be: true.
	
	