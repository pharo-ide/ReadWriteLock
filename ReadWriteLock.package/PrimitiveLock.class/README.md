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
This code is not working correctly by itself. When current process waits on  "lock acquire"  somebody can terminate it and ensure will release me which shoud not happens in this case. But if I was acquired but process is just suspended on "lock acquire" then process termination should execute ensure block to release me.  
This problem solved by this special method handleWaitTerminationInside:. Process>>terminate detects first case and call this method which  injects right value for tracking variable.  Senders should mark method with special pragma 
	<lockAt: #lockVariableName tracksStateAt: 1> "index of local variable"
Method can contain multiple pragmas for referenced locks. (ReadWriteLock for example needs this).
    
	Instance Variables
	owningProcess:		<Process>

Copyright (c) 2016 - 3D Immersive Collaboration Consulting, LLC.