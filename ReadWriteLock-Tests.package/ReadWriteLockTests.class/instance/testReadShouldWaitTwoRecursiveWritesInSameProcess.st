tests
testReadShouldWaitTwoRecursiveWritesInSameProcess

	| readExecuted readExecutedAfterWrites |
	readExecuted := false.
	readExecutedAfterWrites := nil.
	self fork: [ 
		lock criticalWrite: [ 
			lock criticalWrite: [].
			10 milliSeconds wait.
			readExecutedAfterWrites := readExecuted not.
		].
	].
	self fork: [ lock criticalRead: [ readExecuted := true ] ].
	self waitForkedProcesses.
	
	self assert: readExecuted.
	self assert: readExecutedAfterWrites