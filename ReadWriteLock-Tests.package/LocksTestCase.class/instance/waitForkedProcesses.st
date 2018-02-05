helpers
waitForkedProcesses

	[CurrentExecutionEnvironment value forkedProcesses 
		allSatisfy: [ :each | each isTerminated ]] whileFalse: [ 
			Processor yield ]