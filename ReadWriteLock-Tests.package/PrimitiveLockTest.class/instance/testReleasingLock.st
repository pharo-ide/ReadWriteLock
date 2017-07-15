tests
testReleasingLock

	| lastExecuted |
	lastExecuted := false.
	self fork: [ lock acquire. 10 seconds wait].
	self fork: [ lock acquire. lastExecuted := true].
	10 milliSeconds wait.
	lock release.	
	self waitLastProcessFinished.
	self assert: lastExecuted