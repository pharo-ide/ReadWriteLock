helpers
waitForkedProcesses

	[forkedProcesses allSatisfy: [ :each | each isTerminated ]] 
		whileFalse: [ Processor yield ]