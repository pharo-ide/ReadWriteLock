tests
testFailedReadShouldUnblockWrite
	
	| executed |
	self fork: [
		[lock criticalRead: [ 10 milliSeconds wait. self error: 'failed read']] ifError: [  ]
	].	
	self fork: [lock criticalWrite: [ executed := true ]].
	15 milliSeconds wait.
	
	executed should be: true
	
	