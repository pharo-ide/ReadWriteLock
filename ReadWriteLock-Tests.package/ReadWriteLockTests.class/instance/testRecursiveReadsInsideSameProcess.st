tests
testRecursiveReadsInsideSameProcess

	| executed |
	self fork: [
		lock criticalRead: [ 
			lock criticalRead: [executed := true]].
	].
	15 milliSeconds wait.
	
	executed should be: true