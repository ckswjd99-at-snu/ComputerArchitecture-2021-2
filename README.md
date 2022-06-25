# SNUCA 2021-2

Assignments in **SNU ECE Computer Architecture (430.322)** lecture, at 2021 autumn.

Implemented **various versions of CPU of TSC ISA.**

<h2><a href="/src/Single%20Cycle%20CPU">Single Cycle CPU</a></h2>

**Single cycle CPU** of TSC instruction set architecture.

<h2><a href="/src/Multi%20Cycle%20CPU">Multi Cycle CPU</a></h2>

**Multi cycle CPU** of TSC instruction set architecture.

This CPU has 5 stages:

- IF (Instruction Fetch)
- ID (Instruction Decode)
- EX (Execution)
- MEM (Memory Access)
- WB (Write Back)

<h2><a href="/src/Pipelined%20CPU">Pipelined CPU</a></h2>

**New Modules**: Control Hazard Detector, Data Hazard Detector.

When data hazard occurs, DHD stalls IF stage. After data hazard is resolved, it allows IF stage to proceed.

When control hazard occurs, CHD stalls ID stage. After control hazard is resolved, it allows ID stage to proceed.

<h2><a href="/src/Pipelined%20CPU%20with%20Data%20Forwarding">Pipelined CPU with Data Forwarding</a></h2>

**New Module**: Data Magic Box.

Data Magic Box decodes instructions in ID, MEM, WB stages, then provides appropriate values to every modules.

<h2><a href="/src/Pipelined%20CPU%20with%20Naive%20Cache">Pipelined CPU with Naive Cache</a></h2>

**New Module**: First-In-First-Out Cache.

Implemented FIFO Cache memory at instruction memory and data memory.

<h2><a href="/src/Pipelined%20CPU%20with%20Fully%20Associative%20Cache">Pipelined CPU with Fully Associative Cache</a></h2>

**New Module**: Younger the Better Cache.

Implemented YB Cache memory at instruction memory and data memory.

<h2><a href="/src/Pipelined%20CPU%20supporting%20DMA">Pipelined CPU supporting DMA</a></h2>

**New Module**: DMA Controller.

Implemented DMA controller inside CPU, activated when received inturrupt.
