#!/usr/bin/env bash
set -u
# Android Emulator network scenarios. Real-device testing must be performed manually.
ADB="${ADB:-adb}"
case "${1:-help}" in
  good) $ADB emu network speed full; echo 'Emulator network: full' ;;
  wifi) $ADB emu network speed full; echo 'Emulator network: WiFi/full approximation' ;;
  gsm) $ADB emu network speed gsm; echo 'Emulator network: GSM/slow' ;;
  edge) $ADB emu network speed edge; echo 'Emulator network: EDGE/very slow' ;;
  none) $ADB emu network speed none; echo 'Emulator network: disabled' ;;
  help) echo 'Usage: $0 {good|wifi|gsm|edge|none}' ;;
  *) echo 'Unknown scenario'; exit 2 ;;
esac
