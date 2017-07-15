tests
testAcquireFreeLockWhichWasAlreadyInUse

	| result |
	self fork: [ result := lock acquire ].
	self waitLastProcessFinished.
	lock release.
	self fork: [ result := lock acquire ].
	self waitLastProcessFinished.
		
	self assert: result not description: 'acquiring new lock should return false'
	