operations
criticalRead: aBlock
"
	See comment of Mutex>>critical:. Here is same logic about terminating handling but for both read and write locks.
	We should garanties that when process terminated readLock is not waiting anymore and readers count are correct.
	The main trick is assignment right before we go into the wait primitive (which is not a real send and therefore not interruptable either). So after we can check that waiting happens in current process or not.
	Given block is safe for recursive read/write sections
"
	| readLockAcquiredNotHere newReadersCount  writeLockAcquiredNotHere readingPrepared writeLockWasAsked |
	<lockAt: #readLock tracksStateAt: 1>
	<lockAt: #writeLock tracksStateAt: 3>
		
	readLockAcquiredNotHere := true.
	writeLockAcquiredNotHere := true.
	writeLockWasAsked := false.
	readingPrepared := false.
	
	[readLockAcquiredNotHere := false.
	readLockAcquiredNotHere := readLock acquire.	
	newReadersCount := currentReaders + 1. "It is possible to be interrupted here and then terminated. We will analize it further".	
	[currentReaders = 0 ifTrue: [
		writeLockWasAsked := true.
		writeLockAcquiredNotHere := false.
		writeLockAcquiredNotHere := writeLock acquire].			
	currentReaders := newReadersCount.
	readingPrepared := true.
	readLockAcquiredNotHere := true.
	readLock release] ifCurtailed: [
		newReadersCount ifNotNil: [ currentReaders := newReadersCount - 1 ]. "we should restore previous value because we can't prepare reading (process was terminated)"
		readLockAcquiredNotHere ifFalse: [readLock release].
		writeLockAcquiredNotHere ifFalse: [ writeLock release]].		
	^aBlock value] ensure: [ 
		readingPrepared ifTrue: [ 
			readLock acquire.
			currentReaders := currentReaders - 1.	
			currentReaders = 0 ifTrue: [ 
				writeLockWasAsked not | (writeLockWasAsked & writeLockAcquiredNotHere not)  
					ifTrue: [writeLock release ]].
			readLock release]
	].