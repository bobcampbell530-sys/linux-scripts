Temperature Monitor

**Monitor CPU & motherboard temperatures in real time — auto-detects Intel and AMD processors.**

Ever wanted to keep an eye on your system's temperatures without opening a separate monitoring app? This script uses `lm-sensors` to read CPU package temps, per-core temps (on Intel), and motherboard temperatures, displaying them live in your terminal or logging them to CSV.

It's perfect for thermal testing, identifying overheating components, or just satisfying your curiosity about what your CPU is doing under load.

How It Works
1.  **Run the Script**: Execute `sys-temp.sh` with your preferred mode.
2.  **Choose a Mode**: Use `--csv` to log to a CSV file, or `--interactive` (default) for live terminal output.
3.  **Set Interval** (optional): Pass a number to control how often readings are taken (e.g., `--interactive 2` for every 2 seconds).
4.  **Optional Warning Threshold**: Add `--warn 85` to get stderr warnings when any sensor exceeds that temperature.
5.  **Stop**: Press Ctrl+C to stop — the script prints a summary report with min, max, and average readings across all sensors.

Key Features
*   **Auto-Detect CPU Type**: Works with both Intel (coretemp) and AMD (k10temp) — no manual configuration needed.
*   **Per-Core Monitoring**: On Intel CPUs, tracks each core individually (Core 0 through Core 3 shown by default).
*   **Motherboard Sensors**: Reads acpitz motherboard temperature sensors automatically.
*   **CSV Logging**: Save all readings to `~/temp_log.csv` with timestamps for later analysis in Excel, LibreOffice, or any spreadsheet tool.
*   **Live Terminal Display**: See temps update in real-time with a clean, aligned table format.
*   **CPU Utilization**: Shows current CPU utilization percentage alongside temperatures.
*   **Summary Report**: On Ctrl+C, get a full summary with min, max, and average for every sensor over the session duration.
*   **Warning Thresholds**: Use `--warn 85` to get alerts if any temperature exceeds a set limit.

Usage Examples
```bash
# Interactive mode, every second (default)
./sys-temp.sh --interactive

# Log to CSV, every 2 seconds
./sys-temp.sh --csv 2

# Log with warnings above 80°C
./sys-temp.sh --csv --warn 80

# Interactive mode, every 5 seconds
./sys-temp.sh --interactive 5

# Show help
./sys-temp.sh --help
```

Output Preview (Interactive Mode)
```
Intel Core i7-3770S @ 3.10GHz
Temp Monitor (Ctrl+C to stop)

TIME       PKG°C    C0°C    C1°C    C2°C    C3°C    MAX°C    MB°C   UTIL%
------------------------------------------------------------------------
21:30:42       42      41      43      42      42      43      38      12
21:30:43       43      42      44      43      43      44      39      15
21:30:44       44      43      45      44      43      45      40      18
```

What It Needs
*   **lm-sensors**: Install with `sudo apt install lm-sensors`. Run `sudo sensors-detect` first if your sensors aren't showing up.

Why Use This?
*   **Thermal Validation**: Verify that your cooling solution is adequate under load.
*   **Component Health Check**: Monitor temps to detect failing thermal paste, dust buildup, or fan issues before they cause problems.
*   **Data Logging**: CSV output makes it easy to graph temperature trends over time.
*   **Lightweight**: No GUI, no dependencies beyond lm-sensors — runs anywhere Linux does.
*   **Auto-Detect**: Works with Intel and AMD out of the box. No configuration files to edit.

---

*Note: This script requires the lm-sensors package. If you see "sensors not found," install it with `sudo apt install lm-sensors` and run `sudo sensors-detect` to probe your hardware.*
