# NeverForget — Glassmorphic Special Day Reminder

NeverForget is a high-performance, aesthetically pleasing Android application built with Flutter. It helps users track birthdays, anniversaries, and custom events using a "frosted glass" design language and reliable exact-alarm notifications.

## ✨ Features
* **Glassmorphic UI:** A modern, translucent interface with mesh gradients and staggered animations.
* **Intelligent Notifications:** User-defined alert times with a mandatory 3-day countdown lead-up.
* **Offline-First:** Powered by Isar NoSQL database for lightning-fast, local data persistence.
* **Custom Categories:** Pre-defined categories (Birthdays, Anniversaries) plus user-created custom types.
* **Interactive Alarms:** Day-of-event notifications include "Snooze" and "Acknowledge" actions.

## 🛠️ Tech Stack
* **Framework:** Flutter (Min SDK 21)
* **Database:** Isar DB
* **State Management:** Provider
* **Notifications:** flutter_local_notifications (Timezone-aware)
* **Animations:** flutter_staggered_animations

## 🚀 Getting Started
1. Clone the repo: `git clone https://github.com/shad-ct/neverforget.git`
2. Install dependencies: `flutter pub get`
3. Generate DB code: `dart run build_runner build`
4. Run the app: `flutter run`

## 📸 Design Language
The app follows strict Glassmorphism principles:
- Backdrop Filter Blur: 10.0–15.0
- Border Opacity: 0.2 white
- Primary Font: Poppins / Montserrat