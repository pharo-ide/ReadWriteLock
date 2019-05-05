tests
testRecursiveWritesInsideSameProcess

	| executed |
	self fork: [ 
		lock criticalWrite: [ 
			lock criticalWrite: [executed := true]
		].
	].
	self waitForkedProcesses.
	
	self assert: executed