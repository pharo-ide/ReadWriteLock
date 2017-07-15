tests
testRecursiveReadAndWriteInsideSameProcess

	| executed |
	self fork: [
		lock criticalRead: [ 
			lock criticalWrite: [executed := true]].
	].
	15 milliSeconds wait.
	
	executed should be: true