tests
testFailedReadShouldUnblockWrite
	
	| executed |
	self fork: [
		[lock criticalRead: [ 10 milliSeconds wait. self error: 'failed read']] ifError: [  ]
	].	
	self fork: [lock criticalWrite: [ executed := true ]].
	self waitForkedProcesses.
	
	self assert: executed