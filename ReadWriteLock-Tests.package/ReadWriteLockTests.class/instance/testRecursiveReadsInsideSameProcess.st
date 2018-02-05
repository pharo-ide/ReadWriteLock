tests
testRecursiveReadsInsideSameProcess

	| executed |
	self fork: [
		lock criticalRead: [ 
			lock criticalRead: [executed := true]].
	].
	self waitForkedProcesses.
	
	executed should be: true