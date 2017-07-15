tests
testAttemptToAcquireLockTwiceFromSameProcess

	| result |
	self fork: [ lock tryAcquire. result := lock tryAcquire ].
	self waitLastProcessFinished.
	
	self assert: result description: 'acquiring lock twice should return true'
	