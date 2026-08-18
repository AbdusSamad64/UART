# UART

A UART (Universal Asynchronous Receiver/Transmitter) is a serial communication protocol that sends and receives data one bit at a time over a single wire, without a shared clock, timing is instead agreed upon in advance using a fixed baud rate. Each byte is framed with a start bit, 8 data bits, an optional parity bit, and a stop bit, letting two devices sync up and exchange data reliably.

This project implements a configurable UART TX and RX in SystemVerilog, supporting no parity, even parity, or odd parity via a runtime-selectable mode, along with framing and parity error detection.

It has been completely verified using a layered testbench architecture (transaction, driver, monitor, scoreboard, environment), and functional coverage has been applied on top of it, tracking data value coverage, parity mode coverage, FSM state transition coverage, and cross coverage between data and parity to ensure the design has been thoroughly exercised and verified.
