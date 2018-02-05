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
	
	lastReadExecuted should be: true.
	firstReadExecutedAfterLast should be: true