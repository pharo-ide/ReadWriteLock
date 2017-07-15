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
	15 milliSeconds wait.
	
	lastReadExecuted should be: true.
	firstReadExecutedAfterLast should be: true