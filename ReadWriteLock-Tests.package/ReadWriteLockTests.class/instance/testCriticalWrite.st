tests
testCriticalWrite

	| actual |
	actual := lock criticalWrite: [ #result].
	
	self assert: actual equals: #result