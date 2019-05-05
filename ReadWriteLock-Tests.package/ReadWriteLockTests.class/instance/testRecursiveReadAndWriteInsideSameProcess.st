tests
testRecursiveReadAndWriteInsideSameProcess

	| executed |
	self fork: [
		lock criticalRead: [ 
			lock criticalWrite: [executed := true]].
	].
	self waitForkedProcesses.
	
	self assert: executed