simulating
primitiveEnterCriticalSectionOnBehalfOf: activeProcess
	[owningProcess ifNil:
		[owningProcess := activeProcess.
		 ^false].
	  owningProcess = activeProcess ifTrue:
		[^true].
	  self addLast: activeProcess.
	 activeProcess suspend] valueUnpreemptively