tests
testCriticalWrite

	| actual |
	actual := lock criticalWrite: [ #result].
	
	actual should be: #result