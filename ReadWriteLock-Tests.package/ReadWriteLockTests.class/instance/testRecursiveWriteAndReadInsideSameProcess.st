tests
testRecursiveWriteAndReadInsideSameProcess

	| executed |
	self fork: [ 
		lock criticalWrite: [ 
			lock criticalRead: [executed := true]
		].
	].
	15 milliSeconds wait.
	
	executed should be: true