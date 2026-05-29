# AI Expenses Tracker

Production Flutter expense tracker with Firebase legacy mode, VPS PostgreSQL
sync, and a Cloudflare AI gateway boundary.

## Backend Validation

The VPS API lives in `server/`. Detailed setup, deployment, migration, backup,
and rollback instructions are in `docs/backend/vps-postgres-runbook.md`.

Common local checks:

```powershell
cd server
npm ci
npm run typecheck
npm test
```

Firestore legacy deployment files live at the repository root:

- `.firebaserc`
- `firebase.json`
- `firestore.rules`
- `firestore.indexes.json`

The Firestore ownership matrix is documented in
`docs/firebase/firestore-schema.md`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
