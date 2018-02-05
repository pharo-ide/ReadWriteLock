process termination handling
resetLockFlag: flagTempName in: criticalContext
	
	criticalContext debuggerMap tempNamed: flagTempName in: criticalContext put: true