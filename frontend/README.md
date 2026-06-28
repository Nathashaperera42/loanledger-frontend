# LoanLedger — Flutter app

Mobile-first loan management UI matching the approved preview: Dashboard, Lent,
Borrowed, Due, and Profit (monthly P&L), with login, dark mode, the funding /
margin model, and full add/edit flows via bottom sheets.

## Stack
- Flutter (Material 3), dark mode
- Riverpod for state management (MVC + repository pattern)
- Dio HTTP client (JWT access/refresh, auto-retry on 401)
- flutter_secure_storage for tokens (Keychain / Keystore)
- url_launcher for Call / SMS / WhatsApp

## What's production-ready vs. what you do
- ✅ All screens, models, repositories, providers, theme, navigation — ready.
- 🔧 You must: have the backend running, set the API URL, run `flutter pub get`,
  and build the app. (Flutter can't be compiled in this delivery environment, so
  this is clean source you build locally.)
- 📱 Android config is included. For iOS, run `flutter create .` once to generate
  the `ios/` folder, then it builds normally.

## 1. Prerequisites
- Flutter SDK 3.3+ (`flutter doctor` should pass for Android)
- The LoanLedger backend running and reachable

## 2. Configure the API URL
Edit `lib/core/api_client.dart`:
```dart
const String kApiBaseUrl = 'http://10.0.2.2:4000/api'; // Android emulator -> your PC
// Real device on the same Wi-Fi: 'http://192.168.x.x:4000/api'
// Deployed backend: 'https://your-api.onrender.com/api'
```
`10.0.2.2` is how the Android emulator reaches `localhost` on your computer.

## 3. Run
```bash
cd frontend
flutter pub get
flutter run            # on a connected device/emulator
```
Build a shareable APK:
```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

## 4. Log in
Use the admin you created in the backend (e.g. `admin@loanledger.lk`).
The email is pre-filled on the login screen for convenience — change it.

## Project layout
```
lib/
  core/         colors, theme, formatting, api client (token storage + refresh)
  models/       client, lender, finance (expense/revenue/dashboard/report)
  repositories/ one file: auth, client, lender, finance, report repos
  providers/    Riverpod providers + refreshAll()
  widgets/      common (Avatar, AppCard, pills…), cards (list rows), sheets (all bottom sheets)
  screens/      login, home_shell (bottom nav), dashboard, lent, borrowed, due, profit, app_header (+settings)
  main.dart     entry + auth gate
android/        Gradle + manifest (INTERNET permission, tel/sms/https queries)
```

## Notes
- The five bottom tabs mirror the preview: **Dashboard · Lent · Borrowed · Due · Profit**.
  Settings opens from the avatar (top-right). Theme toggle is next to it.
- The "Funded by" picker on Add Client lists your active lenders and computes the
  lending margin live, exactly like the preview.
- Push notifications: the backend sends FCM. To receive them on-device you'll add
  `firebase_messaging` + `google-services.json` (Firebase setup) — the backend
  already exposes `POST /devices` to register the token. This is optional; the
  reminder system also logs server-side without it.
- If lists show a "could not reach server" state, the API URL is wrong or the
  backend isn't running.
```
