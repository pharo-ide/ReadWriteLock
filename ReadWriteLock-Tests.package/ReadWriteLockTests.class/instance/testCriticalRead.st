tests
testCriticalRead

	| actual |
	actual := lock criticalRead: [ #result].
	
	self assert: actual equals: #result