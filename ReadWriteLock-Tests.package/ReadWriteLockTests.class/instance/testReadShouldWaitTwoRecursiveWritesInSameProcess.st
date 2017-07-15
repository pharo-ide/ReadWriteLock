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
	15 milliSeconds wait.
	
	readExecuted should be: true.
	readExecutedAfterWrites should be: true