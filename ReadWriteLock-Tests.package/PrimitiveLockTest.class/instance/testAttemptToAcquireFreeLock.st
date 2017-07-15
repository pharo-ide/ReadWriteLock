tests
testAttemptToAcquireFreeLock

	| result |
	self fork: [ result := lock tryAcquire ].
	self waitLastProcessFinished.
	
	self assert: result not description: 'acquiring new lock should return false'
	