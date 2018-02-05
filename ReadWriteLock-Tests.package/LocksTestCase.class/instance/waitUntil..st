helpers
waitUntil: conditionBlock
	
	conditionBlock whileFalse: [Processor yield]