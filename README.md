# ReadWriteLock

[![GitHub release](https://img.shields.io/github/release/pharo-ide/ReadWriteLock.svg)](https://github.com/pharo-ide/ReadWriteLock/releases/latest)
[![Unit Tests](https://github.com/pharo-ide/ReadWriteLock/actions/workflows/tests.yml/badge.svg)](https://github.com/pharo-ide/ReadWriteLock/actions/workflows/tests.yml)

[![Pharo 7.0](https://img.shields.io/badge/Pharo-7.0-informational)](https://pharo.org)
[![Pharo 8.0](https://img.shields.io/badge/Pharo-8.0-informational)](https://pharo.org)
[![Pharo 9.0](https://img.shields.io/badge/Pharo-9.0-informational)](https://pharo.org)
[![Pharo 10](https://img.shields.io/badge/Pharo-10-informational)](https://pharo.org)
[![Pharo 11](https://img.shields.io/badge/Pharo-11-informational)](https://pharo.org)

It's implementation of reentral read write lock which described in 
[https://en.wikipedia.org/wiki/Readers–writer_lock](). From the article:

> A ReadWriteLock allows concurrent access for read-only operations, while write operations require exclusive access. This means that multiple threads can read the data in parallel but an exclusive lock is needed for writing or modifying data. When a writer is writing the data, all other writers or readers will be blocked until the writer is finished writing.

## Installation
```Smalltalk
Metacello new
  baseline: 'ReadWriteLock';
  repository: 'github://pharo-ide/ReadWriteLock';
  load
```
Use following snippet for stable dependency in your project baseline:
```Smalltalk
spec
    baseline: 'ReadWriteLock'
    with: [ spec repository: 'github://pharo-ide/ReadWriteLock:v1.0.0' ]
```
## Public API and Key Messages:
```Smalltalk
lock := ReadWriteLock new.
lock criticalRead: ["read code"].
lock criticalWrite: ["write code"]
```
Main difficulty is carefully handle process termination during execution of critical sections. This problem described in Semaphore>>critical: comment. Same approach is used here. But synchronization logic around two semaphores for reading and writing complicates things very much. No simple way to decompose logic on methods because information about process interruption become hidden.</br>
From Semaphore comment:
>The main trick is assignment right before we go into the wait primitive (which is not a real send and therefore not interruptable either). So after we can check that waiting is happen or not.
