# MedGlobal Network

Medical professional networking app with Flutter frontend, Rust backend, and PostgreSQL database.

## Firebase Hosting

This project can be deployed as a Flutter web app on Firebase Hosting.

```bash
cd medglobalnetwork
flutter build web --release
firebase deploy --only hosting
```

If your backend is deployed separately, pass the production API URL at build time:

```bash
flutter build web --release --dart-define=API_BASE_URL=https://your-backend-domain.com
```

Firebase Hosting serves the web frontend only. The Rust API still needs its own public deployment target.
