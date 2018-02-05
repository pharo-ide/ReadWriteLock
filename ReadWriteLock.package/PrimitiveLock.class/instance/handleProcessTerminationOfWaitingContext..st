process termination handling
handleProcessTerminationOfWaitingContext: suspendedContext
"
This method called from Process>>terminate when it detects waiting me. My users should handle very carefully process termination to ensure releasing only when I was acquired. Users use special temp variable which tracks state of acquiring me for current process. VM not interrupts process on assignments. It allows to write safe code like this: 
	[releaseNotRequired := false.
	releaseNotRequired := lock acquire]
		ensure: [ releaseNotRequired ifFalse: [ lock release ] ]
This code is not working correctly by itself. When current process waits on 'lock acquire' somebody can terminate it and ensure will release me which shoud not happens in this case. But if I was acquired but process is just suspended on 'lock acquire' then process termination should execute ensure block to release me.  
This problem solved by this special method. Process>>terminate detects first case and inject right value for tracking variable.  Senders should mark method with special pragma 
<lockAt: #lockVariableName tracksStateAt: #tempName> 'var name which keeps the lock state'
Method can contain multiple pragmas for referenced locks. (ReadWriteLock for example needs this)"
	| receiver |
	receiver := suspendedContext receiver.
	
	suspendedContext method pragmas do: [ :pragma | 		
		pragma keyword == #lockAt:tracksStateAt: ifTrue: [ 
			(receiver readSlotNamed: pragma arguments first) == self ifTrue: [ 
				self resetLockFlag: pragma arguments last in: suspendedContext home.
			 ]
		]
	 ].

	^suspendedContext