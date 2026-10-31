#!/usr/bin/env bash
#
# temp_monitor.sh — Monitor CPU & motherboard temps, auto-detect Intel/AMD
#

INTERVAL=1
OUTPUT="${HOME}/temp_log.csv"
WARN_THRESHOLD=""

# Tracking variables for summary report
SAMPLES=0
SUM_PKG=0; SUM_C0=0; SUM_C1=0; SUM_C2=0; SUM_C3=0; SUM_MB1=0; SUM_MB2=0; SUM_UTIL=0
COUNT_PKG=0; COUNT_C0=0; COUNT_C1=0; COUNT_C2=0; COUNT_C3=0; COUNT_MB1=0; COUNT_MB2=0
MAX_PKG=0; MAX_C0=0; MAX_C1=0; MAX_C2=0; MAX_C3=0; MAX_MB1=0; MAX_MB2=0; MAX_UTIL=0
COUNT_UTIL=0
MIN_PKG=999; MIN_C0=999; MIN_C1=999; MIN_C2=999; MIN_C3=999; MIN_MB1=999; MIN_MB2=999

START_EPOCH=$(date +%s)
HAS_CORES=0

update_minmax() {
  local name=$1 cur=$2
  local cur_int=${cur%%.*}
  [[ -z "$cur_int" ]] && return
  local cur_key="MAX_${name}"
  local min_key="MIN_${name}"
  if (( cur_int > ${!cur_key} )); then eval "${cur_key}=$cur_int"; fi
  if (( cur_int < ${!min_key} )); then eval "${min_key}=$cur_int"; fi
}

add_to_sum() {
  local name=$1 val=$2
  local val_int=${val%%.*}
  [[ -z "$val_int" ]] && return
  eval "SUM_${name}=\$((SUM_${name} + val_int))"
  eval "COUNT_${name}=\$((COUNT_${name} + 1))"
}

cleanup() {
  echo ""
  echo "============================================================="
  echo "  Temperature Summary Report"
  echo "============================================================="
  echo ""

  local elapsed=$(( $(date +%s) - START_EPOCH ))
  local mins=$((elapsed / 60))
  local secs=$((elapsed % 60))
  echo "  Duration: ${mins}m ${secs}s  |  Samples: ${SAMPLES}"
  echo ""

  if [[ "$SAMPLES" -eq 0 ]]; then
    echo "  No samples collected."
    echo "============================================================="
    exit 0
  fi

  avg() {
    local s=$1 c=$2
    if [[ "$c" -eq 0 ]]; then echo "N/A"; return; fi
    echo $((s / c))
  }

  printf "  %-14s %6s %6s %8s\n" "SENSOR" "MIN" "MAX" "AVERAGE"
  printf "  %s\n" "$(printf '%.0s─' {1..40})"

  printf "  %-14s %5sC %5sC %7sC\n" \
    "CPU Package" "$MIN_PKG" "$MAX_PKG" "$(avg $SUM_PKG $COUNT_PKG)"

  if [[ "$HAS_CORES" -eq 1 ]]; then
    printf "  %-14s %5sC %5sC %7sC\n" \
      "Core 0" "$MIN_C0" "$MAX_C0" "$(avg $SUM_C0 $COUNT_C0)"
    printf "  %-14s %5sC %5sC %7sC\n" \
      "Core 1" "$MIN_C1" "$MAX_C1" "$(avg $SUM_C1 $COUNT_C1)"
    printf "  %-14s %5sC %5sC %7sC\n" \
      "Core 2" "$MIN_C2" "$MAX_C2" "$(avg $SUM_C2 $COUNT_C2)"
    printf "  %-14s %5sC %5sC %7sC\n" \
      "Core 3" "$MIN_C3" "$MAX_C3" "$(avg $SUM_C3 $COUNT_C3)"
  else
    printf "  %-14s %5sC %5sC %7sC\n" \
      "Tctl (AMD)" "$MIN_PKG" "$MAX_PKG" "$(avg $SUM_PKG $COUNT_PKG)"
  fi

  printf "  %-14s %5sC %5sC %7sC\n" \
    "Motherboard" "$MIN_MB1" "$MAX_MB1" "$(avg $SUM_MB1 $COUNT_MB1)"

  printf "  %-14s %5s%% %5s%% %7s%%\n" \
    "CPU Util%" "0" "100" "$(avg $SUM_UTIL $COUNT_UTIL)"

  echo ""
  echo "  CSV logged to: ${OUTPUT}"
  echo "============================================================="
  exit 0
}

trap cleanup SIGINT SIGTERM

usage() {
  cat <<'EOF'
Usage: temp_monitor.sh [--csv [interval]] [--interactive [interval]] [--warn <threshold>] [--help]

Options:
  --csv [SECS]        Log to ~/dell_temp_log.csv (default interval: 1 second)
  --interactive [SECS] Print to terminal live (default interval: 1 second)
  --warn THRESHOLD    Print warning to stderr if any temp exceeds THRESHOLD (e.g., 85)
  --help              Show this help message

Examples:
  temp_monitor.sh --csv 2        # Log every 2 seconds to ~/dell_temp_log.csv
  temp_monitor.sh --csv          # Log every 1 second to ~/dell_temp_log.csv
  temp_monitor.sh --interactive  # Print to terminal every 1 second
  temp_monitor.sh --csv --warn 80  # Log with warnings above 80C
EOF
  exit 0
}

if [[ $# -gt 4 ]]; then usage; fi
if [[ "${1:-}" == "--help" ]]; then usage; fi

MODE="interactive"
i=1
while (( i <= $# )); do
  arg="${!i}"
  case "$arg" in
    --csv)
      MODE="csv"; i=$((i+1))
      if (( i <= $# )); then
        next="${!i}"
        if [[ "$next" =~ ^[0-9]+$ ]]; then INTERVAL="$next"; i=$((i+1))
        elif [[ "$next" == "--warn" ]]; then
          i=$((i+1))
          if (( i <= $# )); then WARN_THRESHOLD="${!i}"; i=$((i+1)); fi
        fi
      fi
      ;;
    --interactive)
      MODE="interactive"; i=$((i+1))
      if (( i <= $# )); then
        next="${!i}"
        if [[ "$next" =~ ^[0-9]+$ ]]; then INTERVAL="$next"; i=$((i+1))
        elif [[ "$next" == "--warn" ]]; then
          i=$((i+1))
          if (( i <= $# )); then WARN_THRESHOLD="${!i}"; i=$((i+1)); fi
        fi
      fi
      ;;
    --warn)
      i=$((i+1)); if (( i <= $# )); then WARN_THRESHOLD="${!i}"; i=$((i+1)); fi
      ;;
    *) i=$((i+1));;
  esac
done

if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]] || [[ "$INTERVAL" -lt 1 ]]; then
  echo "Error: interval must be a positive integer." >&2; exit 1
fi

if ! command -v sensors &>/dev/null; then
  echo "Error: sensors (lm-sensors) not found. Install with: sudo apt install lm-sensors" >&2; exit 1
fi

parse_sensors() {
  local raw
  raw=$(sensors 2>/dev/null) || true

  # Auto-detect CPU type
  local has_coretemp has_k10temp
  has_coretemp=$(echo "$raw" | grep -c "Package id" || true)
  has_k10temp=$(echo "$raw" | grep -c "Tctl" || true)

  # Detect CPU model
  CPU_MODEL=""
  if command -v lscpu &>/dev/null; then
    CPU_MODEL=$(lscpu | grep 'Model name:' | sed 's/Model name: *//')
  elif grep -q 'model name' /proc/cpuinfo 2>/dev/null; then
    CPU_MODEL=$(grep 'model name' /proc/cpuinfo | head -1 | sed 's/.*: *//')
  fi

  # CPU package temp
  CPU_PKG=""
  if [[ "$has_coretemp" -gt 0 ]]; then
    CPU_PKG=$(echo "$raw" | grep "Package id 0:" | head -1 | awk '{print $4}' | sed 's/[^0-9.]//g')
  elif [[ "$has_k10temp" -gt 0 ]]; then
    CPU_PKG=$(echo "$raw" | grep "Tctl:" | head -1 | awk '{print $2}' | sed 's/[^0-9.]//g')
  fi

  # Individual cores — only for Intel coretemp
  CORE_0=""; CORE_1=""; CORE_2=""; CORE_3=""
  HAS_CORES=0
  if [[ "$has_coretemp" -gt 0 ]]; then
    CORE_0=$(echo "$raw" | grep "Core 0:" | head -1 | awk '{print $3}' | sed 's/[^0-9.]//g')
    CORE_1=$(echo "$raw" | grep "Core 1:" | head -1 | awk '{print $3}' | sed 's/[^0-9.]//g')
    CORE_2=$(echo "$raw" | grep "Core 2:" | head -1 | awk '{print $3}' | sed 's/[^0-9.]//g')
    CORE_3=$(echo "$raw" | grep "Core 3:" | head -1 | awk '{print $3}' | sed 's/[^0-9.]//g')
    HAS_CORES=1
  fi

  # Motherboard temps — match any acpitz block
  local mb_raw
  mb_raw=$(echo "$raw" | grep -A2 "^acpitz" | grep "temp1:" | head -1 | awk '{print $2}' | sed 's/[^0-9.]//g') || true
  MB_TEMP1=$mb_raw
  MB_TEMP2=$(echo "$raw" | grep -A2 "^acpitz" | grep "temp1:" | tail -1 | awk '{print $2}' | sed 's/[^0-9.]//g') || true

  # CPU utilization from /proc/stat
  local cpu_line
  cpu_line=$(grep '^cpu ' /proc/stat) || true
  local user nice system idle iowait irq softirq total active
  if [[ -n "$cpu_line" ]]; then
    user=$(echo "$cpu_line" | awk '{print $2}')
    nice=$(echo "$cpu_line" | awk '{print $3}')
    system=$(echo "$cpu_line" | awk '{print $4}')
    idle=$(echo "$cpu_line" | awk '{print $5}')
    iowait=$(echo "$cpu_line" | awk '{print $6}')
    irq=$(echo "$cpu_line" | awk '{print $7}')
    softirq=$(echo "$cpu_line" | awk '{print $8}')
    total=$((user + nice + system + idle + iowait + irq + softirq))
    active=$((total - idle - iowait))
    if (( total > 0 )); then CPU_UTIL=$((active * 100 / total)); else CPU_UTIL=0; fi
  else
    CPU_UTIL=0
  fi

  # Calculate max core temp (use CPU_PKG for AMD)
  if [[ "$HAS_CORES" -eq 1 ]]; then
    local max_core_int=${CORE_0%%.*}
    local max_core=$CORE_0
    for c in $CORE_1 $CORE_2 $CORE_3; do
      local c_int=${c%%.*}
      if [[ -n "$c_int" ]] && [[ -n "$max_core_int" ]] && (( c_int > max_core_int )); then
        max_core=$c; max_core_int=$c_int
      fi
    done
    MAX_CORE=$max_core
  else
    MAX_CORE=$CPU_PKG
  fi

  # Check warning threshold
  if [[ -n "$WARN_THRESHOLD" ]]; then
    local temp
    for temp in "$CPU_PKG" "$CORE_0" "$CORE_1" "$CORE_2" "$CORE_3"; do
      if [[ -n "$temp" ]]; then
        local temp_int=${temp%%.*}
        if (( temp_int >= WARN_THRESHOLD )); then
          echo "WARNING: Temp ${temp}C exceeds ${WARN_THRESHOLD}C threshold at $(date '+%H:%M:%S')" >&2
        fi
      fi
    done
  fi

  # Update tracking
  SAMPLES=$((SAMPLES + 1))
  update_minmax "PKG" "$CPU_PKG"; add_to_sum "PKG" "$CPU_PKG"
  update_minmax "C0" "$CORE_0"; add_to_sum "C0" "$CORE_0"
  update_minmax "C1" "$CORE_1"; add_to_sum "C1" "$CORE_1"
  update_minmax "C2" "$CORE_2"; add_to_sum "C2" "$CORE_2"
  update_minmax "C3" "$CORE_3"; add_to_sum "C3" "$CORE_3"
  update_minmax "MB1" "$MB_TEMP1"; add_to_sum "MB1" "$MB_TEMP1"
  update_minmax "MB2" "$MB_TEMP2"; add_to_sum "MB2" "$MB_TEMP2"
  add_to_sum "UTIL" "$CPU_UTIL"
}

if [[ "$MODE" == "csv" ]]; then
  echo "Logging temperature data to ${OUTPUT} (Ctrl+C to stop)"
  echo ""
  echo "timestamp,cpu_package_c,core0_c,core1_c,core2_c,core3_c,max_core_c,mb_temp1_c,mb_temp2_c,cpu_util_pct" > "$OUTPUT"
  while true; do
    parse_sensors
    printf "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n" \
      "$(date '+%Y-%m-%d %H:%M:%S')" \
      "${CPU_PKG:---}" "${CORE_0:---}" "${CORE_1:---}" "${CORE_2:---}" "${CORE_3:---}" \
      "${MAX_CORE:---}" \
      "${MB_TEMP1:---}" "${MB_TEMP2:---}" \
      "${CPU_UTIL}" >> "$OUTPUT"
    sleep "$INTERVAL"
  done
elif [[ "$MODE" == "interactive" ]]; then
  parse_sensors
  if [[ -n "$CPU_MODEL" ]]; then
    echo "$CPU_MODEL"
  else
    echo "CPU: Unknown"
  fi
  echo "Temp Monitor (Ctrl+C to stop)"
  echo ""

  if [[ "$HAS_CORES" -eq 1 ]]; then
    printf "%-8s %10s %8s %8s %8s %8s %8s %10s %8s\n" \
      "TIME" "PKG°C" "C0°C" "C1°C" "C2°C" "C3°C" "MAX°C" "MB°C" "UTIL%"
    printf "%s\n" "$(printf '%.0s-' {1..72})"
  else
    printf "%-8s %10s %10s %10s %8s\n" \
      "TIME" "PKG°C" "MB°C" "MAX°C" "UTIL%"
    printf "%s\n" "$(printf '%.0s-' {1..46})"
  fi

  while true; do
    parse_sensors
    if [[ "$HAS_CORES" -eq 1 ]]; then
      printf "%-8s %10s %8s %8s %8s %8s %8s %10s %8s\n" \
        "$(date +%H:%M:%S)" \
        "${CPU_PKG:---}°C" "${CORE_0:---}°C" "${CORE_1:---}°C" \
        "${CORE_2:---}°C" "${CORE_3:---}°C" "${MAX_CORE:---}°C" \
        "${MB_TEMP1:---}°C" "${CPU_UTIL}%"
    else
      printf "%-8s %10s %10s %10s %8s\n" \
        "$(date +%H:%M:%S)" \
        "${CPU_PKG:---}°C" "${MB_TEMP1:---}°C" "${MAX_CORE:---}°C" \
        "${CPU_UTIL}%"
    fi
    sleep "$INTERVAL"
  done
fi
