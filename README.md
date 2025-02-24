# UART Interface Implementation

## Overview
This repository contains a UART (Universal Asynchronous Receiver/Transmitter) interface implementation with a baud rate of 115200 at a 50MHz clock frequency. The implementation includes a receiver, transmitter, and a relay component that echoes received data back to the sender.

## Features
- UART transmitter implementation (115200 baud rate)
- UART receiver implementation (115200 baud rate)
- Echo relay functionality
- 50MHz system clock operation

## Directory Structure
```
├── src/
│   ├── receiver.v     - UART receiver module
│   ├── transmitter.v  - UART transmitter module
│   ├── top_relay.v    - Echo relay module
└── README.md
```

## Implementation Details

### Baud Rate Calculation
At 50MHz system clock and 115200 baud rate:
- Baud rate divisor = (Clock Frequency) / (Baud Rate)
- Baud rate divisor = 50,000,000 / 115,200 = ~434

### Transmitter Module
The transmitter module (`src/transmitter.v`) converts parallel data to serial data according to UART protocol. It handles start bit, data bits, and stop bit transmission at 115200 baud rate.

### Receiver Module
The receiver module (`src/receiver.v`) converts serial UART data to parallel data. It samples the input at the center of each bit period and handles start bit detection, data bit collection, and stop bit validation.

### Relay Module
The relay module (`src/top_relay.v`) connects the receiver and transmitter to create an echo functionality. Any data received is immediately forwarded back to the transmitter.

