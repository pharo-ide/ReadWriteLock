tests
testMultipleReadsShouldNotBlockEachOthers

	| firstReadExecutedAfterLast lastReadExecuted |
	firstReadExecutedAfterLast := nil.
	lastReadExecuted := false.

	self fork: [
		lock criticalRead: [ 10 milliSeconds wait. 
			firstReadExecutedAfterLast := lastReadExecuted]
	].	
	self fork: [lock criticalRead: [ lastReadExecuted := true ]].
	self waitForkedProcesses.
	
	self assert: lastReadExecuted.
	self assert: firstReadExecutedAfterLast