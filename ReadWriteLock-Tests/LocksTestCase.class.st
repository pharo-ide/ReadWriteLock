Class {
	#name : #LocksTestCase,
	#superclass : #TestCase,
	#instVars : [
		'forkedProcesses'
	],
	#category : 'ReadWriteLock-Tests'
}

{ #category : #testing }
LocksTestCase class >> isAbstract [
	^self == LocksTestCase
]

{ #category : #helpers }
LocksTestCase >> fork: aBlock [

	| newProcess |
	newProcess := aBlock forkNamed: testSelector.
	forkedProcesses add: newProcess.
	^newProcess
]

{ #category : #helpers }
LocksTestCase >> fork: aBlock at: priority [

	| newProcess |
	newProcess := aBlock forkAt: priority named: testSelector.
	forkedProcesses add: newProcess.
	^newProcess
]

{ #category : #helpers }
LocksTestCase >> forkAndWait: aBlock [

	self fork: aBlock.
	self waitLastProcessFinished
]

{ #category : #helpers }
LocksTestCase >> passForkedProcesses [
	"While this trick looks bad it is quite difficult to control processes which are forked by tested code.
	This yield loop works well in practice.
	It allow all forked processes proceed"
	10 timesRepeat: [Processor yield]
]

{ #category : #running }
LocksTestCase >> setUp [
	super setUp.
	
	forkedProcesses := OrderedCollection new
]

{ #category : #running }
LocksTestCase >> tearDown [
	super tearDown.
	
	forkedProcesses do: #terminate
]

{ #category : #helpers }
LocksTestCase >> waitForkedProcesses [

	[forkedProcesses allSatisfy: [ :each | each isTerminated ]] 
		whileFalse: [ Processor yield ]
]

{ #category : #helpers }
LocksTestCase >> waitLastProcessFinished [
	| lastProcess |
	lastProcess := forkedProcesses last.
	Processor yield.
	[
		[ lastProcess isTerminated | lastProcess isSuspended] whileFalse: [5 milliSeconds wait ]
	] valueWithin: 2 seconds onTimeout: [ self fail: 'Last process not terminated within 5 seconds' ].

	lastProcess isTerminated ifFalse: [ self notify: 'Last process is not terminated but suspended' ]
]

{ #category : #helpers }
LocksTestCase >> waitUntil: conditionBlock [
	
	conditionBlock whileFalse: [Processor yield]
]
