# Garf

Garf provides a real-time graphical representation and detailed overview of your macOS system's performance, including memory (RAM) usage, CPU usage, individual CPU core statistics, and general system information.

## Features

- **Real-Time Graphs for Memory and CPU Usage**: 
  - Displays the usage of memory and CPU as graphs, updating in real time.

- **Individual CPU Core Usage**: 
  - Shows usage statistics for each CPU core separately.

- **System Information**: 
  - Provides detailed information about the device, including model, RAM, CPU cores, GPU cores, chipset model, battery capacity, and Wi-Fi signal strength.

- **Customizable Update Frequency**: 
  - Allows you to specify how often the script updates the data.

## Requirements

- macOS Operating System
- Bash Shell
- Command-line tools: `system_profiler`, `sysctl`, `top`, `awk`, `bc`, `sed`, `vm_stat`, `ps`

## Usage

To run the script, use the following command in the terminal:
./app.sh

### Arguments

- **-i interval**: Specify the update interval in seconds. For example, use `-i 2` for updating every 2 seconds.
