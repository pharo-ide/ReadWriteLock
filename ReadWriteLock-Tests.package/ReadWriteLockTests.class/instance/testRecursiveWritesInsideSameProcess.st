tests
testRecursiveWritesInsideSameProcess

	| executed |
	self fork: [ 
		lock criticalWrite: [ 
			lock criticalWrite: [executed := true]
		].
	].
	15 milliSeconds wait.
	
	executed should be: true