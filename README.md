# Proxporter

**Proxporter** is a lightweight Bash script designed to extract key configuration details of QEMU VMs and LXC containers from Proxmox clusters. It gathers important information such as CPU cores, memory, and disk sizes from each node and outputs the data to a CSV file, making it easy to import into Excel, Google Sheets, or any other documentation tool.

## Features

- **Cluster-Aware:** Automatically scans all nodes in your Proxmox cluster for VM and LXC configuration files.
- **Clean Extraction:** Ignores snapshot sections and filters out CD-ROM devices, ensuring only relevant data is exported.
- **CSV Output:** Generates a CSV file (`proxporter.csv`) with configuration data that can be easily imported into spreadsheet applications.
- **Easy Automation:** Can be scheduled with cron for regular documentation updates.

## Requirements

- Proxmox Virtual Environment (VE) with a single server or multi-node cluster setup.
- A Bash shell with standard Unix utilities (`grep`, `sed`, `awk`).

## Installation

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/Micinek/proxporter.git
   cd proxporter
   ```

2. **Make the Script Executable:**

   ```bash
   chmod +x proxporter.sh
   ```

## Usage

Simply run the script on a node in your Proxmox cluster:

```bash
./proxporter.sh
```

This will generate (or update) a file named `proxporter.csv` in the current directory, containing the exported configuration details.

## License

This project is licensed under the [MIT License](LICENSE).
