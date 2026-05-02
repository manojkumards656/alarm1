# Step Alarm App

A **Flutter-based Alarm Application** designed to enforce habit-building by forcing the user to physically walk to dismiss alarms. If the required steps aren't met within the time limit, a "Penalty Alarm" triggers that cannot be dismissed!

## Features

* ⏰ **Reliable Alarms**: Set multiple alarms that ring accurately even when the app is in the background or killed.
* 🚶 **Step Verification**: Stop the initial alarm, but a countdown begins! You must complete the required steps (tracked via device hardware) to fully cancel the alarm.
* 🚨 **Penalty Mode**: Fail to walk your target steps within the time limit? A continuous penalty alarm triggers with no dismiss button, forcing you to wake up.
* 🎵 **Custom Ringtones**: Select custom audio files straight from your device storage.
* 🎨 **Modern Dark Theme**: Sleek Material 3 dark UI with smooth interactions.

## Tech Stack

* **Flutter 3.x**
* **alarm**: For accurate background scheduling and device waking.
* **pedometer**: For precise hardware step tracking (`ACTIVITY_RECOGNITION`).
* **permission_handler**: For managing iOS and Android permissions.
* **provider**: For clean, decoupled state management.
* **shared_preferences**: For local persistence of alarms and settings.

## Getting Started

### Prerequisites

* Flutter SDK installed
* An Android or iOS device (Note: Hardware step counters are required. Emulators will not register steps unless simulated via ADB).

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/manojkumards656/alarm1.git
   ```
2. Navigate to the directory:
   ```bash
   cd alarm1
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

### Permissions Note
Upon launching for the first time, you must accept permissions for Notifications, Exact Alarms, and Physical Activity (Pedometer) for the app to function correctly.

## Project Architecture

- `lib/models/`: Contains the `StepAlarmSettings` data model.
- `lib/providers/`: 
  - `alarm_provider.dart`: Handles storing, scheduling, and modifying the core alarms.
  - `active_alarm_provider.dart`: The core state machine handling Phase 1 (Dismiss), Phase 1.5 (Step Countdown), and Phase 2 (Penalty).
- `lib/screens/`: Contains the UI for setting alarms and the active "Wake Up" screens.
- `lib/theme/`: Stores the app's custom dark theme.

## License
MIT License
