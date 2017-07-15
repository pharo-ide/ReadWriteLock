tests
testAcquireLockTwiceFromSameProcess

	| result |
	self fork: [ lock acquire. result := lock acquire ].
	self waitLastProcessFinished.
	
	self assert: result description: 'acquiring lock twice should return true'
	