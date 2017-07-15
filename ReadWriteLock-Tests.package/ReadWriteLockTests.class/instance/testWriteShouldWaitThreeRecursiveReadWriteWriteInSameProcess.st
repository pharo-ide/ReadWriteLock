tests
testWriteShouldWaitThreeRecursiveReadWriteWriteInSameProcess

	| lastWriteExecuted lastWriteExecutedAfterRecursiveWriteRead |
	lastWriteExecuted := false.
	lastWriteExecutedAfterRecursiveWriteRead := nil.
	self fork: [ 
		lock criticalRead: [ lock criticalWrite: [	lock criticalWrite: []].
			10 milliSeconds wait.
			lastWriteExecutedAfterRecursiveWriteRead := lastWriteExecuted not.
		].
	].
	self fork: [ lock criticalWrite: [ lastWriteExecuted := true ] ].
	15 milliSeconds wait.
	
	lastWriteExecuted should be: true.
	lastWriteExecutedAfterRecursiveWriteRead should be: true