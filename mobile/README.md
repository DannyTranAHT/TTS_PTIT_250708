# 📱 Mobile Frontend Development Guide (Flutter)

## 📦 Setup Instructions

1. Navigate to the mobile folder:
   ```bash
   cd mobile
   cd project_hub
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Change ip
   ```bash
   Change ip in lib/config/api_config.dart to your ip
   ```
4. Run the app:
   ```bash
   flutter run
   ```

> Make sure an emulator or physical device is connected

## ⚙️ Environment Setup

Add this to `lib/config.dart`:
```dart
const String apiUrl = 'http://10.0.2.2:5000/api';
const String socketUrl = 'http://10.0.2.2:5000';
```

Use `10.0.2.2` for Android emulator to access local backend

## 📂 Structure Overview

- `screens/` – Main views
- `widgets/` – Reusable components
- `models/` – Data models
- `services/` – HTTP & socket handling
- `providers/` – State management (Provider/Riverpod)
