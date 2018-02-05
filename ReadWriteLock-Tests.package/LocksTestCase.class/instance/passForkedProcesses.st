helpers
passForkedProcesses
	"While this trick looks bad it is quite difficult to control processes which are forked by tested code.
	This yield loop works well in practice.
	It allow all forked processes proceed"
	10 timesRepeat: [Processor yield]