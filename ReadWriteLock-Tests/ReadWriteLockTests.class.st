Class {
	#name : #ReadWriteLockTests,
	#superclass : #LocksTestCase,
	#instVars : [
		'lock'
	],
	#category : #'ReadWriteLock-Tests'
}

{ #category : #running }
ReadWriteLockTests >> setUp [
	super setUp.
	
	lock := ReadWriteLock new.
]

{ #category : #tests }
ReadWriteLockTests >> testCriticalRead [

	| actual |
	actual := lock criticalRead: [ #result].
	
	self assert: actual equals: #result
]

{ #category : #tests }
ReadWriteLockTests >> testCriticalWrite [

	| actual |
	actual := lock criticalWrite: [ #result].
	
	self assert: actual equals: #result
]

{ #category : #tests }
ReadWriteLockTests >> testFailedReadShouldUnblockWrite [
	
	| executed |
	self fork: [
		[lock criticalRead: [ 10 milliSeconds wait. self error: 'failed read']] on: Error do: [:err |  ]
	].	

	self fork: [lock criticalWrite: [ executed := true ]].
	self waitForkedProcesses.
	
	self assert: executed
]

{ #category : #tests }
ReadWriteLockTests >> testFailedWriteShouldUnblockRead [
	
	| executed |
	self fork: [
		[lock criticalWrite: [ 10 milliSeconds wait. self error: 'failed write']] on: Error do: [:err |  ]
	].	

	self fork: [lock criticalRead: [ executed := true ]].
	self waitForkedProcesses.
	
	self assert: executed
]

{ #category : #tests }
ReadWriteLockTests >> testMultipleReadsShouldNotBlockEachOthers [

	| firstReadExecutedAfterLast lastReadExecuted |
	firstReadExecutedAfterLast := nil.
	lastReadExecuted := false.

	self fork: [
		lock criticalRead: [ 10 milliSeconds wait. 
			firstReadExecutedAfterLast := lastReadExecuted]
	].	
	self fork: [lock criticalRead: [ lastReadExecuted := true ]].
	self waitForkedProcesses.
	
	self assert: lastReadExecuted.
	self assert: firstReadExecutedAfterLast
]

{ #category : #tests }
ReadWriteLockTests >> testMultipleWritesShouldWaitEachOther [

	| lastWriteExecutedAfterFirst lastWriteExecuted |
	lastWriteExecutedAfterFirst := nil.
	lastWriteExecuted := false.

	self fork: [
		lock criticalWrite: [ 10 milliSeconds wait. 
			lastWriteExecutedAfterFirst := lastWriteExecuted not]
	].	
	self fork: [lock criticalWrite: [ lastWriteExecuted := true ]].
	self waitForkedProcesses.
	
	self assert: lastWriteExecuted.
	self assert: lastWriteExecutedAfterFirst
	
	
]

{ #category : #tests }
ReadWriteLockTests >> testReadShouldWaitTwoRecursiveWritesInSameProcess [

	| readExecuted readExecutedAfterWrites |
	readExecuted := false.
	readExecutedAfterWrites := nil.
	self fork: [ 
		lock criticalWrite: [ 
			lock criticalWrite: [].
			10 milliSeconds wait.
			readExecutedAfterWrites := readExecuted not.
		].
	].
	self fork: [ lock criticalRead: [ readExecuted := true ] ].
	self waitForkedProcesses.
	
	self assert: readExecuted.
	self assert: readExecutedAfterWrites
]

{ #category : #tests }
ReadWriteLockTests >> testReadShouldWaitWrite [

	| readExecutedAfterWrite readExecuted |
	readExecutedAfterWrite := nil.
	readExecuted := false.

	self fork: [
		lock criticalWrite: [ 10 milliSeconds wait. 
			readExecutedAfterWrite := readExecuted not]
	].	
	self fork: [lock criticalRead: [ readExecuted := true ]].
	self waitForkedProcesses.
	
	self assert: readExecuted.
	self assert: readExecutedAfterWrite
	
]

{ #category : #tests }
ReadWriteLockTests >> testRecursiveReadAndWriteInsideSameProcess [

	| executed |
	self fork: [
		lock criticalRead: [ 
			lock criticalWrite: [executed := true]].
	].
	self waitForkedProcesses.
	
	self assert: executed
]

{ #category : #tests }
ReadWriteLockTests >> testRecursiveReadsInsideSameProcess [

	| executed |
	self fork: [
		lock criticalRead: [ 
			lock criticalRead: [executed := true]].
	].
	self waitForkedProcesses.
	
	self assert: executed
]

{ #category : #tests }
ReadWriteLockTests >> testRecursiveWriteAndReadInsideSameProcess [

	| executed |
	self fork: [ 
		lock criticalWrite: [ 
			lock criticalRead: [executed := true]
		].
	].
	self waitForkedProcesses.
	
	self assert: executed
]

{ #category : #tests }
ReadWriteLockTests >> testRecursiveWritesInsideSameProcess [

	| executed |
	self fork: [ 
		lock criticalWrite: [ 
			lock criticalWrite: [executed := true]
		].
	].
	self waitForkedProcesses.
	
	self assert: executed
]

{ #category : #tests }
ReadWriteLockTests >> testTerminatingReadWhichWaitingWriteAndAnotherRead [

	| lastReadExecutedAfterWrite lastReaderExecuted secondReaderExecuted secondReader syncSemaphore writeSemaphore |
	lastReadExecutedAfterWrite := false.
	secondReaderExecuted := false.
	lastReaderExecuted := false.
	syncSemaphore := Semaphore new.
	writeSemaphore := Semaphore new.
	self fork: [
		lock criticalWrite: [ syncSemaphore signal. writeSemaphore wait. 
			lastReadExecutedAfterWrite := lastReaderExecuted not ]
	].	
	syncSemaphore wait.
	secondReader := self fork: [lock criticalRead: [ secondReaderExecuted := true ]].	
	self fork: [lock criticalRead: [ lastReaderExecuted := true ]].
	
	self passForkedProcesses.
	self deny: lastReaderExecuted.
	secondReader terminate.
	
	self passForkedProcesses. "Now last read should be still locked"
	self deny: lastReaderExecuted.
	writeSemaphore signal.
	self waitForkedProcesses.
	self assert: lastReaderExecuted.
	self deny: secondReaderExecuted.
	self assert: lastReadExecutedAfterWrite
]

{ #category : #tests }
ReadWriteLockTests >> testTerminatingWriteWhichWaitingAnotherTwoWrites [

	| lastWriteExecutedAfterFirst lastWriteExecuted secondWriteExecuted secondWriter syncSemaphore writeSemaphore |
	lastWriteExecutedAfterFirst := false.
	secondWriteExecuted := false.
	lastWriteExecuted := false.
	syncSemaphore := Semaphore new.
	writeSemaphore := Semaphore new.
	self fork: [
		lock criticalWrite: [ syncSemaphore signal. writeSemaphore wait.
			lastWriteExecutedAfterFirst := lastWriteExecuted not ]
	].	
	syncSemaphore wait.
	secondWriter := self fork: [lock criticalWrite: [ secondWriteExecuted := true ]].	
	self fork: [lock criticalWrite: [ lastWriteExecuted := true ]].
	
	self passForkedProcesses.
	self deny: lastWriteExecuted.
	secondWriter terminate.
	writeSemaphore signal.	
	self waitForkedProcesses.
	self assert: lastWriteExecuted.
	self deny: secondWriteExecuted.
	self assert: lastWriteExecutedAfterFirst
]

{ #category : #tests }
ReadWriteLockTests >> testWriteShouldWaitRead [

	| writeExecutedAfterRead writeExecuted |
	writeExecutedAfterRead := nil.
	writeExecuted := false.

	self fork: [
		lock criticalRead: [ 10 milliSeconds wait. 
			writeExecutedAfterRead := writeExecuted not ]
	].	
	self fork: [lock criticalWrite: [ writeExecuted := true ]].
	self waitForkedProcesses.
	
	self assert: writeExecuted.
	self assert: writeExecutedAfterRead
	
	
]

{ #category : #tests }
ReadWriteLockTests >> testWriteShouldWaitThreeRecursiveReadReadWriteInSameProcess [

	| lastWriteExecuted lastWriteExecutedAfterRecursiveWriteRead |
	lastWriteExecuted := false.
	lastWriteExecutedAfterRecursiveWriteRead := nil.
	self fork: [ 
		lock criticalRead: [ lock criticalRead: [lock criticalWrite: []].
			10 milliSeconds wait.
			lastWriteExecutedAfterRecursiveWriteRead := lastWriteExecuted not.
		].
	].
	self fork: [ lock criticalWrite: [ lastWriteExecuted := true ] ].
	self waitForkedProcesses.
	
	self assert: lastWriteExecuted.
	self assert: lastWriteExecutedAfterRecursiveWriteRead
]

{ #category : #tests }
ReadWriteLockTests >> testWriteShouldWaitThreeRecursiveReadWriteWriteInSameProcess [

	| lastWriteExecuted lastWriteExecutedAfterRecursiveWriteRead |
	lastWriteExecuted := false.
	lastWriteExecutedAfterRecursiveWriteRead := nil.
	self fork: [ 
		lock criticalRead: [ lock criticalWrite: [	lock criticalWrite: []].
			10 milliSeconds wait.
			lastWriteExecutedAfterRecursiveWriteRead := lastWriteExecuted not.
		].
	].
	self fork: [ lock criticalWrite: [ lastWriteExecuted := true ] ].
	self waitForkedProcesses.
	
	self assert: lastWriteExecuted.
	self assert: lastWriteExecutedAfterRecursiveWriteRead
]

{ #category : #tests }
ReadWriteLockTests >> testWriteShouldWaitTwoRead [

	| writeExecutedAfterRead writeExecuted |
	writeExecutedAfterRead := nil.
	writeExecuted := false.

	self fork: [	lock criticalRead: [ 15 milliSeconds wait]].	
	self fork: [
		lock criticalRead: [ 25 milliSeconds wait. 
			writeExecutedAfterRead := writeExecuted not ].		
	].	
	self fork: [lock criticalWrite: [ writeExecuted := true ]].
	self waitForkedProcesses.
	
	self assert: writeExecuted.
	self assert: writeExecutedAfterRead
	
]

{ #category : #tests }
ReadWriteLockTests >> testWriteShouldWaitTwoRecursiveReadWriteInSameProcess [

	| lastWriteExecuted lastWriteExecutedAfterRecursiveWriteRead |
	lastWriteExecuted := false.
	lastWriteExecutedAfterRecursiveWriteRead := nil.
	self fork: [ 
		lock criticalRead: [ 
			lock criticalWrite: [].
			10 milliSeconds wait.
			lastWriteExecutedAfterRecursiveWriteRead := lastWriteExecuted not.
		].
	].
	self fork: [ lock criticalWrite: [ lastWriteExecuted := true ] ].
	self waitForkedProcesses.
	
	self assert: lastWriteExecuted.
	self assert: lastWriteExecutedAfterRecursiveWriteRead
]

{ #category : #tests }
ReadWriteLockTests >> testWriteShouldWaitTwoRecursiveWriteReadInSameProcess [

	| lastWriteExecuted lastWriteExecutedAfterRecursiveWriteRead |
	lastWriteExecuted := false.
	lastWriteExecutedAfterRecursiveWriteRead := nil.
	self fork: [ 
		lock criticalWrite: [ 
			lock criticalRead: [].
			10 milliSeconds wait.
			lastWriteExecutedAfterRecursiveWriteRead := lastWriteExecuted not.
		].
	].
	self fork: [ lock criticalWrite: [ lastWriteExecuted := true ] ].
	self waitForkedProcesses.
	
	self assert: lastWriteExecuted.
	self assert: lastWriteExecutedAfterRecursiveWriteRead
]
