# 🚆 Digital Score Card – Train Cleanliness Inspection App

A Flutter-based mobile and web app designed to streamline train cleanliness inspections. This application allows inspectors to evaluate individual coaches based on toilets, vestibules, and doorways. It supports PDF export, Firebase-based cloud storage, submission history, and more.

---

## 📲 Features

- 🔢 **Coach-wise Score Entry**: Enter scores (1–10) for toilets, vestibules, and doorways across 13 coaches (C1–C13).
- 📝 **Remarks Input**: Optional remark field for each score.
- 🗓 **Date & Station Details**: Add inspection metadata like station name, train number, and inspection date.
- 📤 **Submit to Firebase**: Save inspections to the cloud (Firebase Realtime Database).
- 🖨 **Export to PDF**: Generate clean and structured PDFs of each inspection.
- 🕓 **Submission History**:
  - View past submissions.
  - Filter by station and date.
  - Export specific submissions to PDF.
  - Delete old entries as needed.
- 🌗 **Dark Mode**: Always-on dark theme for better UX during inspections.
- 📱 **Device Preview**: Optimized layouts for various screen sizes using `device_preview`.

---

## 📦 Tech Stack

- **Flutter** (Cross-platform app framework)
- **Firebase Realtime Database** (Cloud backend)
- **Shared Preferences** (Local state, if added)
- **Printing & pdf** (`printing`, `pdf`) – for exporting reports
- **http** – for Firebase API integration

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK installed
- Firebase project with Realtime Database enabled
- Dependencies installed via:

```bash
flutter pub get
```

### Run App

```bash
flutter run
```

### Enable Device Preview

To preview layout on multiple screen sizes:

```dart
DevicePreview(
  enabled: true,
  builder: (context) => ScoreCardApp(),
)
```

---

## 📂 Folder Structure

```
/lib
 ├── main.dart
 ├── screens/
 │   ├── home_screen.dart
 │   ├── scorecard_form.dart
 │   ├── submission_list_screen.dart
 │   └── submission_detail_screen.dart
 ├── widgets/
 │   └── ...
```

---

## 🛠 Firebase API

**POST Submission**
- Endpoint: `https://your-project-id.firebaseio.com/submissions.json`
- Payload: JSON with station, trainNumber, date, scores, etc.

**GET Submissions**
- Endpoint: `https://your-project-id.firebaseio.com/submissions.json`

---

## 📸 Screenshots

*Coming Soon – Add demo images or screen recordings here.*

---

## 📜 License

MIT License © 2025 Rudra Bharadwaj

---

## 💡 Future Enhancements

- 🔔 Local notifications for scheduled inspections
- 📡 Offline-first mode with sync
- 📊 Dashboard for analytics
- 👥 Multi-user support (Admin + Inspector roles)

---
