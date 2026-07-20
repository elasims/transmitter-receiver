# transmitter-receiver
UART on Zybo Z7-10 (Verilog)

A from-scratch UART transmitter/receiver implementation in Verilog, targeting the Digilent Zybo Z7-10 (Zynq-7010) FPGA board. The top-level module implements a simple echo: any byte received over UART is immediately retransmitted back.

Features
Custom UART transmitter and receiver modules (no IP cores)
Configurable CLK_FREQ / BAUD_RATE via module parameters
Start-bit half-period synchronization for accurate mid-bit sampling
Framing error detection (fram_err)
Simple top-level echo with an activity counter on the onboard LEDs
Module overview
Module	File	Description
top	top.v	Instantiates transmitter and receiver, wires up the echo loop, drives led[3:0] as a receive counter
receiver	rx.v	UART receive FSM (idle → start → data → stop → wait), outputs data, datavld, fram_err, busy
transmitter	tx.v	UART transmit FSM (idle → start → data → stop), outputs tx, busy
Hardware setup
Board: Digilent Zybo Z7-10 (xc7z010)
Serial interface: Digilent MAX3232PMB1 Pmod (RS232 level shifter) → RS232-to-USB adapter cable → PC
Pmod header: originally targeted JC, but I/O bank voltage conflicts (Pmod expects LVCMOS33, the bank was configured for 1.8V VCCO) forced reassigning pins across the JC/JA headers — check your .xdc bank voltage settings if you hit placement DRC errors.
Terminal: PuTTY, 115200 8-N-1, no flow control
Clocking

BAUD_TICK is derived from CLK_FREQ and BAUD_RATE:

verilog
localparam BAUD_TICK = CLK_FREQ / BAUD_RATE;

The Zybo Z7-10's onboard system clock is 125 MHz. Both transmitter and receiver must be instantiated with CLK_FREQ = 125_000_000 (this is not inherited automatically from the top module's localparam — it has to be passed explicitly via parameter override):

verilog
transmitter #(.CLK_FREQ(125000000), .BAUD_RATE(115200)) uut_tx (...);
receiver    #(.CLK_FREQ(125000000), .BAUD_RATE(115200)) uut_rx (...);

Default BAUD_RATE is 115200.

Receiver FSM notes
p_idle → p_start: triggered on rx falling edge (~rx), since the line idles high.
p_start: counts HALF_TICK cycles to center sampling on the middle of the start bit.
p_data: samples on bauddone (full BAUD_TICK), shifting bits in LSB-first via {rx, reg_shift[7:1]}.
p_stop: checks stop bit polarity (rx == 1 → valid, latch data/datavld; rx == 0 → fram_err).
p_wait: handles back-to-back frames with no idle gap — if a new start bit has already begun the instant the stop bit ends, this state re-synchronizes on it (half-tick centering) instead of dropping it.
Testing

Verified via:

Loopback simulation in Vivado (tx_tb, rx_tb, top_tb)
On-board testing through the MAX3232 Pmod with PuTTY (115200 8-N-1)
Oscilloscope inspection of rx/tx lines to validate bit timing
Vivado ILA (ChipScope) captures on uut_rx/reg_state (3-bit) and uut_tx/reg_state (2-bit) to inspect FSM behavior directly on hardware — note both modules use the same signal name reg_state, so when probing make sure you're looking at the right hierarchy path.
Status
Receiver: working. Confirmed on hardware — byte counter increments correctly, rx_data captures the correct value, no framing errors in ILA captures.
Transmitter: working. Confirmed on hardware — full echo loop verified end to end, every character typed in the terminal is correctly echoed back.
Known gotchas
CLK_FREQ mismatches between the actual board clock and the module parameter cause consistent bit-sampling drift — symptoms range from garbled characters to full glitch output, not just occasional bit errors.
Stop-bit and start-bit polarity assumes an idle-high line (standard UART); do not invert rx/~rx checks without confirming the physical line polarity first.
