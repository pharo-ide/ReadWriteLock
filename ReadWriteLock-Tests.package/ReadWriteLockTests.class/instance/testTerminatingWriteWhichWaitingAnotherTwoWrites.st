tests
testTerminatingWriteWhichWaitingAnotherTwoWrites

	| lastWriteExecutedAfterFirst lastWriteExecuted secondWriteExecuted secondWriter |
	lastWriteExecutedAfterFirst := false.
	secondWriteExecuted := false.
	lastWriteExecuted := false.

	self fork: [
		lock criticalWrite: [ 10 milliSeconds wait. 
			lastWriteExecutedAfterFirst := lastWriteExecuted not ]
	].	
	secondWriter := self fork: [lock criticalWrite: [ secondWriteExecuted := true ]].	
	self fork: [lock criticalWrite: [ lastWriteExecuted := true ]].
	5 milliSeconds wait.
	secondWriter terminate.
	15 milliSeconds wait.	
	lastWriteExecuted should be: true.
	secondWriteExecuted should be: false.
	lastWriteExecutedAfterFirst should be: true