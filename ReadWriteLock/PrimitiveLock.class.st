"
I supply ownership primitives to implement different kind of concurrency tools like Mutex, Monitor, ReadWriteLock and others.
I allow precisely one process acquire me at any one time. I allow  recursive acquiring inside same process. 
I was originally implemented as CriticalSection by Eliot Miranda which had high level methods like #critical: and #critical:IfLocked:. But idea around me is to provide only primitives and push high level method on more appropriate object like Mutex and Monitor.

Public API and Key Messages

-  acquire 
This method acquire lock for current process. If it is already acquired by other process I will suspend current process. So it will wait until I will be released.
I return true immediatelly if I was already acquired by current process (which means recursive call).   Otherwise I return false (with possible waiting)

- tryAcquire
Same as #acquire but It not suspends current process  for waiting. Instead it return nil immediatelly. So this method ensure no waiting. With #tryAcquire current process will acquires me or not immediatelly.

#acquire and #tryAcquire return true/false with very inconvinent logic. It should be inverted in future which will allow more readable code like: 
	acquiredRightNow := lock acquire.
		or
	releaseRequired  := lock acquire.
But current primitives lead to bad names like: 
	releaseNotRequired  := lock acquire.
	
- release 
This method release me from owner process.

-handleWaitTerminationInside:  aContext
This method called from Process>>terminate when it detects waiting me. My users should  handle very carefully process termination to ensure releasing only when I was acquired. Users use special temp variable which tracks state of acquiring me for current process. VM not interrupts process on assignments. It allows to write safe code like this: 
	[releaseNotRequired := false.
	releaseNotRequired := lock acquire]
		ensure: [ releaseNotRequired ifFalse: [ lock release ] ]
This code is not working correctly by itself. When current process waits on  ""lock acquire""  somebody can terminate it and ensure will release me which shoud not happens in this case. But if I was acquired but process is just suspended on ""lock acquire"" then process termination should execute ensure block to release me.  
This problem solved by this special method handleWaitTerminationInside:. Process>>terminate detects first case and call this method which  injects right value for tracking variable.  Senders should mark method with special pragma 
	<lockAt: #lockVariableName tracksStateAt: 1> ""index of local variable""
Method can contain multiple pragmas for referenced locks. (ReadWriteLock for example needs this).
    
	Instance Variables
	owningProcess:		<Process>

Copyright (c) 2016 - 3D Immersive Collaboration Consulting, LLC.
"
Class {
	#name : #PrimitiveLock,
	#superclass : #LinkedList,
	#instVars : [
		'owningProcess'
	],
	#category : #ReadWriteLock
}

{ #category : #controlling }
PrimitiveLock >> acquire [
	"Primitive. The receiver must be unowned or owned by the current process to proceed.
	 Answer if the process is owned by the current process."
	<primitive: 186>
	self primitiveFailed
	"In the spirit of the following"
	"[owner ifNil:
		[owner := Processor activeProcess.
		 ^false].
	  owner = Processor activeProcess ifTrue:
		[^true].
	  self addLast: Processor activeProcess.
	  Processor activeProcess suspend] valueUnpreemptively"
]

{ #category : #'process termination handling' }
PrimitiveLock >> handleProcessTerminationOfWaitingContext: suspendedContext [
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
	
	suspendedContext home method pragmas do: [ :pragma | 		
		pragma selector == #lockAt:tracksStateAt: ifTrue: [ 
			(receiver readSlotNamed: pragma arguments first) == self ifTrue: [ 
				self resetLockFlag: pragma arguments last in: suspendedContext home.
			 ]
		]
	 ].

	^suspendedContext
]

{ #category : #accessing }
PrimitiveLock >> owningProcess [
	"For debugging. Answer the owning process of this mutex.
	There is no setter since the owning process is managed by the VM."
	^owningProcess
]

{ #category : #simulating }
PrimitiveLock >> primitiveEnterCriticalSectionOnBehalfOf: activeProcess [
	[owningProcess ifNil:
		[owningProcess := activeProcess.
		 ^false].
	  owningProcess = activeProcess ifTrue:
		[^true].
	  self addLast: activeProcess.
	 activeProcess suspend] valueUnpreemptively
]

{ #category : #simulating }
PrimitiveLock >> primitiveTestAndSetOwnershipOfCriticalSectionOnBehalfOf: activeProcess [
	[owningProcess ifNil:
		[owningProcess := activeProcess.		
		 ^false].
	  owningProcess = activeProcess ifTrue: [^true].
	  ^nil] valueUnpreemptively
]

{ #category : #controlling }
PrimitiveLock >> release [
	"Primitive. Set the receiver to unowned and if any processes are waiting on
	 the receiver then proceed the first one, indicating that the receiver is unowned."
	<primitive: 185>
	self primitiveFailed
	"In the spirit of the following"
	"[owner := nil.
	  self isEmpty ifFalse:
		[process := self removeFirst.
		 process resume]] valueUnpreemptively"
]

{ #category : #'process termination handling' }
PrimitiveLock >> resetLockFlag: flagTempName in: criticalContext [
	
	criticalContext tempNamed: flagTempName put: true
]

{ #category : #controlling }
PrimitiveLock >> tryAcquire [
	"Primitive. Attempt to set the ownership of the receiver.
	 If the receiver is unowned set its owningProcess to the
	 activeProcess and answer false.  If the receiver is owned
	 by the activeProcess answer true.  If the receiver is owned
	 by some other process answer nil."
	<primitive: 187>
	self primitiveFail
	"In the spirit of the following"
	"[owner ifNil:
		[owningProcess := Processor activeProcess.
		 ^false].
	  owner = Processor activeProcess ifTrue: [^true].
	  ^nil] valueUnpreemptively"
]
