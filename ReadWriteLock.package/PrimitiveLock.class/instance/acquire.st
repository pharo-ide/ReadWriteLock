controlling
acquire
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