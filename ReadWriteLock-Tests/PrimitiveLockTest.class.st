Class {
	#name : #PrimitiveLockTest,
	#superclass : #LocksTestCase,
	#instVars : [
		'lock'
	],
	#category : 'ReadWriteLock-Tests'
}

{ #category : #running }
PrimitiveLockTest >> setUp [
	super setUp.
	
	lock := PrimitiveLock new.
]

{ #category : #tests }
PrimitiveLockTest >> testAcquireFreeLock [

	| result |
	self fork: [ result := lock acquire ].
	self waitLastProcessFinished.
	
	self assert: result not description: 'acquiring new lock should return false'
	
]

{ #category : #tests }
PrimitiveLockTest >> testAcquireFreeLockWhichWasAlreadyInUse [

	| result |
	self fork: [ result := lock acquire ].
	self waitLastProcessFinished.
	lock release.
	self fork: [ result := lock acquire ].
	self waitLastProcessFinished.
		
	self assert: result not description: 'acquiring new lock should return false'
	
]

{ #category : #tests }
PrimitiveLockTest >> testAcquireLockTwiceFromSameProcess [

	| result |
	self fork: [ lock acquire. result := lock acquire ].
	self waitLastProcessFinished.
	
	self assert: result description: 'acquiring lock twice should return true'
	
]

{ #category : #tests }
PrimitiveLockTest >> testAcquireLockWhenItsAlreadyBusy [

	| lastLockAcquired syncSemaphore lockSemaphore |
	lastLockAcquired := false.
	syncSemaphore := Semaphore new.
	lockSemaphore := Semaphore new.
	self fork: [ lock acquire. syncSemaphore signal. lockSemaphore wait. ].
	syncSemaphore wait.
	self fork: [ lock acquire. lastLockAcquired := true ].
	self passForkedProcesses.
	lockSemaphore signal.
	
	self deny: lastLockAcquired
	
]

{ #category : #tests }
PrimitiveLockTest >> testAttemptToAcquireBusyLock [
	
	| executed result |
	executed := false.
	self fork: [ lock acquire. 10 seconds wait. ].
	self fork: [ result := lock tryAcquire. executed := true].
	self waitLastProcessFinished.
	
	self assert: result isNil description: 'attempt to acquire busy lock should returns nil'. 
	self assert: executed.
	
]

{ #category : #tests }
PrimitiveLockTest >> testAttemptToAcquireFreeLock [

	| result |
	self fork: [ result := lock tryAcquire ].
	self waitLastProcessFinished.
	
	self assert: result not description: 'acquiring new lock should return false'
	
]

{ #category : #tests }
PrimitiveLockTest >> testAttemptToAcquireLockTwiceFromSameProcess [

	| result |
	self fork: [ lock tryAcquire. result := lock tryAcquire ].
	self waitLastProcessFinished.
	
	self assert: result description: 'acquiring lock twice should return true'
	
]

{ #category : #tests }
PrimitiveLockTest >> testReleasingLock [

	| lastExecuted syncSemaphore lockSemaphore |
	lastExecuted := false.
	syncSemaphore := Semaphore new.
	lockSemaphore := Semaphore new.

	self fork: [ lock acquire. syncSemaphore signal. lockSemaphore wait].
	self fork: [ lock acquire. lastExecuted := true].
	syncSemaphore wait.
	self passForkedProcesses.
	lock release.	
	self waitLastProcessFinished.
	self assert: lastExecuted
]
