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
	self waitForkedProcesses.
	
	self assert: lastWriteExecuted.
	self assert: lastWriteExecutedAfterRecursiveWriteRead