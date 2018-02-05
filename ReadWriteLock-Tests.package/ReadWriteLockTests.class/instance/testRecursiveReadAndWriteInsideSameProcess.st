tests
testRecursiveReadAndWriteInsideSameProcess

	| executed |
	self fork: [
		lock criticalRead: [ 
			lock criticalWrite: [executed := true]].
	].
	self waitForkedProcesses.
	
	executed should be: true