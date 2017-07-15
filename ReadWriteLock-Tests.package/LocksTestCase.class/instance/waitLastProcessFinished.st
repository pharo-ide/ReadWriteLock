helpers
waitLastProcessFinished
	| lastProcess |
	lastProcess := forkedProcesses last.
	Processor yield.
	[
		[ lastProcess isTerminated | lastProcess isSuspended] whileFalse: [5 milliSeconds wait ]
	] valueWithin: 2 seconds onTimeout: [ self fail: 'Last process not terminated within 5 seconds' ].

	lastProcess isTerminated ifFalse: [ self notify: 'Last process is not terminated but suspended' ]