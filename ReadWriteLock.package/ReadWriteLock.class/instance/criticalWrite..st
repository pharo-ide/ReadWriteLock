operations
criticalWrite: aBlock
"
	See comment of Mutex>>critical:. Here is same logic about terminating handling but for both read and write locks.
	We should garanties that when process terminated writeLock is not waiting anymore.
	The main trick is assignment right before we go into the wait primitive (which is not a real send and therefore not interruptable either). So after we can check that waiting happens in current process or not.
	Given block is safe for recursive read/write sections
"
	| lockAcquiredNotHere |
	<lockAt: #writeLock tracksStateAt: 1>
	
	lockAcquiredNotHere := true.
	
	[lockAcquiredNotHere := false.
	lockAcquiredNotHere := writeLock acquire.
	
	^aBlock value] ensure: [	lockAcquiredNotHere ifFalse: [writeLock release]	]