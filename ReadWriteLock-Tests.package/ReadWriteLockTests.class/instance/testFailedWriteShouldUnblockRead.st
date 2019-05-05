tests
testFailedWriteShouldUnblockRead
	
	| executed |
	self fork: [
		[lock criticalWrite: [ 10 milliSeconds wait. self error: 'failed write']] ifError: [  ]
	].	
	self fork: [lock criticalRead: [ executed := true ]].
	self waitForkedProcesses.
	
	self assert: executed