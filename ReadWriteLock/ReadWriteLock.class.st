"
I implement reentral read write lock which described in 
https://en.wikipedia.org/wiki/Readers–writer_lock. From the article

An ReadWriteLock allows concurrent access for read-only operations, while write operations require exclusive access. This means that multiple threads can read the data in parallel but an exclusive lock is needed for writing or modifying data. When a writer is writing the data, all other writers or readers will be blocked until the writer is finished writing.

Public API and Key Messages

- criticalRead:  
- criticalWrite:
 
Internal Representation and Key Implementation Points.

    Instance Variables
	currentReaders:		<Integer>
	readLock:		<OwnedLock>
	writeLock:		<OwnedLock>

    Implementation Points

Main difficulty is carefully  handle process termination during execution of critical sections. This problem described in OwnedLock comments. Same approach is used here. But synchronization logic around two locks for reading and writing complicates things. No simple way to decompose logic on methods because information about process interruption become hidden.

The main trick is assignment right before we go into the wait primitive (which is not a real send and therefore not interruptable either). So after we can check that waiting is happen or not.
"
Class {
	#name : #ReadWriteLock,
	#superclass : #Object,
	#instVars : [
		'currentReaders',
		'readLock',
		'writeLock'
	],
	#category : 'ReadWriteLock'
}

{ #category : #operations }
ReadWriteLock >> criticalRead: aBlock [
"
	See comment of Mutex>>critical:. Here is same logic about terminating handling but for both read and write locks.
	We should garanties that when process terminated readLock is not waiting anymore and readers count are correct.
	The main trick is assignment right before we go into the wait primitive (which is not a real send and therefore not interruptable either). So after we can check that waiting happens in current process or not.
	Given block is safe for recursive read/write sections
"
	| readLockAcquiredNotHere newReadersCount  writeLockAcquiredNotHere readingPrepared writeLockWasAsked |
	<lockAt: #readLock tracksStateAt: #readLockAcquiredNotHere>
	<lockAt: #writeLock tracksStateAt: #writeLockAcquiredNotHere>
		
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
		writeLockAcquiredNotHere ifFalse: [writeLock release]].		
	^aBlock value] ensure: [ 
		readingPrepared ifTrue: [ 
			readLock acquire.
			currentReaders := currentReaders - 1.	
			currentReaders = 0 ifTrue: [ 
				writeLockWasAsked not | (writeLockWasAsked & writeLockAcquiredNotHere not)  
					ifTrue: [writeLock release ]].
			readLock release]
	].
]

{ #category : #operations }
ReadWriteLock >> criticalWrite: aBlock [
"
	See comment of Mutex>>critical:. Here is same logic about terminating handling but for both read and write locks.
	We should garanties that when process terminated writeLock is not waiting anymore.
	The main trick is assignment right before we go into the wait primitive (which is not a real send and therefore not interruptable either). So after we can check that waiting happens in current process or not.
	Given block is safe for recursive read/write sections
"
	| lockAcquiredNotHere |
	<lockAt: #writeLock tracksStateAt: #lockAcquiredNotHere>
	
	lockAcquiredNotHere := true.
	
	[lockAcquiredNotHere := false.
	lockAcquiredNotHere := writeLock acquire.
	
	^aBlock value] ensure: [	lockAcquiredNotHere ifFalse: [writeLock release]	]
]

{ #category : #initialization }
ReadWriteLock >> initialize [
	super initialize.
	
	readLock := PrimitiveLock new.
	currentReaders := 0.
	writeLock := PrimitiveLock new.
]
