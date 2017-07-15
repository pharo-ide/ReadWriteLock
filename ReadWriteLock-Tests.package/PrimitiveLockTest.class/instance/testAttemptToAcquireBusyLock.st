tests
testAttemptToAcquireBusyLock
	
	| executed result |
	executed := false.
	self fork: [ lock acquire. 10 seconds wait. ].
	self fork: [ result := lock tryAcquire. executed := true].
	self waitLastProcessFinished.
	
	self assert: result isNil description: 'attempt to acquire busy lock should returns nil'. 
	self assert: executed.
	