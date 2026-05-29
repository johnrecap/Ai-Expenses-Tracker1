---
name: mobile-agent-qa
description: Use when testing a Flutter/mobile app on Android or iOS devices/emulators, validating UI flows, producing reproducible QA steps, or converting manual mobile checks into integration tests.
---
# Mobile QA via Flutter integration tests + Mobilerun

## Prerequisites
- Flutter SDK and a connected device/emulator.
- Android: `adb devices` must show a device.
- Optional natural-language device automation: `uv tool install mobilerun`.

## Workflow
1. First run deterministic checks: `flutter analyze` and `flutter test`.
2. For UI flows, prefer Flutter `integration_test` when behavior should be permanent.
3. Use Mobilerun only for exploratory/manual-like QA flows.
4. Capture failing steps, screen name, expected result, actual result, and proposed fix.

## Failure handling
- If Mobilerun is unavailable, continue with Flutter integration tests and adb/simulator tools.