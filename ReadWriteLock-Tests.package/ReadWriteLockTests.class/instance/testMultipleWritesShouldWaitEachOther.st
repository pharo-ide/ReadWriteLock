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
	
	self assert: lastWriteExecuted.
	self assert: lastWriteExecutedAfterFirst
	
	