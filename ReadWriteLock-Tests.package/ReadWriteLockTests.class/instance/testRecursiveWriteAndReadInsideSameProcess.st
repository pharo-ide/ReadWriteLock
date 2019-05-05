tests
testRecursiveWriteAndReadInsideSameProcess

	| executed |
	self fork: [ 
		lock criticalWrite: [ 
			lock criticalRead: [executed := true]
		].
	].
	self waitForkedProcesses.
	
	self assert: executed