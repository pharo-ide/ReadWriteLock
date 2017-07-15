helpers
forkAndWait: aBlock

	self fork: aBlock.
	self waitLastProcessFinished