simulating
primitiveTestAndSetOwnershipOfCriticalSectionOnBehalfOf: activeProcess
	[owningProcess ifNil:
		[owningProcess := activeProcess.		
		 ^false].
	  owningProcess = activeProcess ifTrue: [^true].
	  ^nil] valueUnpreemptively