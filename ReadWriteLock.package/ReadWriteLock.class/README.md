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