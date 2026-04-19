# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SobrietyField is a **Garmin ConnectIQ DataField** app written in **MonkeyC**. It displays days of sobriety on Garmin smartwatches during workout activities. The app reads a user-configured start date from persistent properties and computes elapsed days each second.

## Build Commands

Requires the [Garmin ConnectIQ SDK](https://developer.garmin.com/connect-iq/sdk/) and a developer key (`.pem`, excluded from git).

```bash
# Compile for a specific device
monkeyc -d fenix7 -o bin/SobrietyField.prg -f monkey.jungle -y developer_key.pem

# Run in the ConnectIQ Simulator
connectiq
monkeydo bin/SobrietyField.prg <device_id>

# Build for all supported devices (via IDE or SDK build tools)
monkeyc -e -f monkey.jungle -y developer_key.pem -o bin/SobrietyField.iq
```

There is no test framework — validation is done by running the app in the ConnectIQ Simulator.

## Architecture

**Two source files only:**

- `source/SobrietyFieldApp.mc` — Extends `Application.AppBase`. On `onStart`, seeds today's date as a fallback if properties are uninitialized. Contains the static helper `getNumProp()` used by the view.
- `source/SobrietyFieldView.mc` — Extends `WatchUi.SimpleDataField`. The `compute()` method is called every second during activities and returns the display string. Core logic lives in the private `getDaysSober()` method.

**Persistent storage** uses `Application.Properties` (defined in `resources/settings/properties.xml`): `SobrietyYear`, `SobrietyMonth`, `SobrietyDay`, `SobrietyHour`, `DisplayFormat`.

**Display format** is user-configurable (property `DisplayFormat`): `1` = number only (e.g. `"365"`), `2` = number + label (e.g. `"365 days"`).

**Date calculation:** `getDaysSober()` validates the stored date, creates a `Gregorian.moment`, compares to `Time.now()`, and divides elapsed seconds by 86400. Returns `-1` for invalid or future dates, which renders the "not set" label.

## Resources

- `resources/strings/strings.xml` — `AppName`, `LabelDays`, `LabelNotSet`
- `resources/settings/settings.xml` — Settings UI schema (date fields + display format)
- `resources/settings/properties.xml` — Property types and defaults (all default to `0`)
- `resources/drawables/launcher_icon.svg` — 24×24 SVG icon

## Supported Devices

50+ Garmin models declared in `manifest.xml` (Fenix 8, Instinct 3, Forerunner 55–965, Venu 3, Vivoactive 3–5, Epix 2, Marq, Approach, Descent series, and others). Minimum API level: **3.1.0**.
