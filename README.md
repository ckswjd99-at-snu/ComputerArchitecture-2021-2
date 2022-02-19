# TSC-CPU

Various versions of CPU of TSC instruction set architecture.

## Versions

### Single Cycle CPU

Single cycle CPU of TSC instruction set architecture.

### Multi Cycle CPU

Multi cycle CPU of TSC instruction set architecture.

This CPU has 5 stages:

- IF (Instruction Fetch)
- ID (Instruction Decode)
- EX (Execution)
- MEM (Memory Access)
- WB (Write Back)

### Pipelined CPU

New Modules: Control Hazard Detector, Data Hazard Detector.

When data hazard occurs, DHD stalls IF stage. After data hazard is resolved, it allows IF stage to proceed.

When control hazard occurs, CHD stalls ID stage. After control hazard is resolved, it allows ID stage to proceed.

### Pipelined CPU with Data Forwarding

New Module: Data Magic Box.

Data Magic Box decodes instructions in ID, MEM, WB stages, then provides appropriate values to every modules.

### Pipelined CPU with Naive Cache

New Module: First-In-First-Out Cache.

Implemented FIFO Cache memory at instruction memory and data memory.

### Pipelined CPU with Fully Associative Cache

New Module: Younger the Better Cache.

Implemented YB Cache memory at instruction memory and data memory.

### Pipelined CPU supporting DMA

New Module: DMA Controller.

Implemented DMA controller inside CPU, activated when received inturrupt.
