# MedGlobal Network

Medical professional networking app with Flutter frontend, Rust backend, and PostgreSQL database.

## Project Structure

```
mgn/
├── medglobalnetwork/   # Flutter app
├── backend/            # Rust API (Axum + SQLx)
├── docker-compose.yml  # PostgreSQL
└── README.md
```

## Features

- **Phone OTP Login/Signup** via Firebase Authentication
- **Unique User ID** generated on registration (16-char uppercase)
- **Fingerprint / Biometric Login** (optional, via sidebar)
- **Profile Avatar** from email (Gravatar) — user can change via custom URL
- **Universal Sidebar** + **Rounded Bottom Navigation** (Home, Study, Jobs, Shop)
- **Rust REST API** with JWT auth
- **PostgreSQL** user storage

## Prerequisites

- Flutter 3.x
- Rust 1.70+
- PostgreSQL 15+ (Docker **or** native Windows install)
- Firebase project with Phone Authentication enabled

## Setup

### 1. PostgreSQL

#### Option A — Windows without Docker (recommended if Docker is not installed)

**Step 1:** Install PostgreSQL (PowerShell as Administrator):

```powershell
winget install PostgreSQL.PostgreSQL.17 --accept-package-agreements --accept-source-agreements
```

Remember the `postgres` superuser password you set during install.

**Step 2:** Create database and run migrations:

```powershell
cd d:\mgn\scripts
.\setup-postgres-windows.ps1
```

If the PostgreSQL service is not running:

```powershell
Start-Service postgresql-x64-17
```

(Service name may be `postgresql-x64-16` etc. depending on version.)

#### Option B — With Docker

```bash
docker compose up -d
```

### 2. Rust Backend

```bash
cd backend
cp .env.example .env   # edit if needed
cargo run
```

API runs at `http://localhost:8080`

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check |
| `/api/v1/auth/register` | POST | Register user after Firebase OTP |
| `/api/v1/auth/login` | POST | Login existing user |
| `/api/v1/auth/google` | POST | Google auth / create-or-login |
| `/api/v1/users/me` | GET/PUT | Profile (requires JWT) |

#### Docker / Cloud Run

```bash
cd backend
docker build -t medglobalnetwork-backend .
docker run --rm -p 8080:8080 --env-file .env medglobalnetwork-backend
```

For a public deploy, Cloud Run is the cleanest option:

```bash
gcloud run deploy medglobalnetwork-backend \
  --source backend \
  --region asia-south1 \
  --allow-unauthenticated \
  --set-env-vars JWT_SECRET=your-secret,RUST_LOG=info \
  --set-env-vars DATABASE_URL=your-postgres-url
```

Then use the Cloud Run URL as `API_BASE_URL` for the Flutter web build.

### 3. Firebase (Flutter)

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Phone** sign-in under Authentication
3. Install FlutterFire CLI:

```powershell
dart pub global activate flutterfire_cli
```

4. Configure the app (Windows — `flutterfire` not in PATH fix):

```powershell
cd d:\mgn\medglobalnetwork

# Option A: no PATH change needed
dart pub global run flutterfire_cli:flutterfire configure

# Option B: helper script (adds PATH + runs configure)
cd d:\mgn\scripts
.\setup-flutterfire.ps1
```

If you want `flutterfire` to work everywhere, add this folder to your **User PATH**:

`C:\Users\ASUS\AppData\Local\Pub\Cache\bin`

Then restart PowerShell and run `flutterfire configure`.

This replaces placeholder values in `lib/config/firebase_options.dart`.

5. For Android: add SHA-1/SHA-256 fingerprints in Firebase Console
6. For iOS: upload APNs key if needed for phone auth

### 4. Flutter App

```bash
cd medglobalnetwork
flutter pub get
flutter run
```

**API URL for emulator:** `http://10.0.2.2:8080` (Android emulator default)

**Physical device:** run with your machine's LAN IP:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8080
```

## Auth Flow

1. User enters phone number → Firebase sends OTP
2. User verifies OTP → Firebase authenticates
3. App calls Rust backend to register/login → receives JWT + unique ID
4. User lands on Home with sidebar + bottom nav
5. Optional: enable fingerprint login from sidebar
6. Avatar tap opens profile editor (email → Gravatar, or custom image URL)

## Environment Variables (Backend)

| Variable | Default |
|----------|---------|
| `DATABASE_URL` | `postgres://mgn_user:mgn_password@localhost:5432/medglobalnetwork` |
| `JWT_SECRET` | (set in `.env`) |
| `PORT` | `8080` |
