tests
testCriticalRead

	| actual |
	actual := lock criticalRead: [ #result].
	
	actual should be: #result