# AI Expenses Tracker — VPS Server

Fastify + TypeScript backend for the AI Expenses Tracker. Provides
Firebase-authenticated endpoints for account management, user profiles, and
PostgreSQL-backed data sync.

---

## Prerequisites

- **Docker** 24+ and **Docker Compose** v2+
- **Node.js** 20 (only for local development without Docker)
- A **Firebase project** with a service account (Admin SDK)

---

## Quick Start (Docker Compose)

### 1. Configure environment

```bash
# Docker Compose interpolation vars (project root)
cp .env.example .env

# Server application vars
cp server/.env.example server/.env
```

Edit both `.env` files:

**Root `.env`** — used by `docker-compose.yml` for `${VAR}` interpolation:

| Variable            | Required? | Description                     |
| ------------------- | --------- | ------------------------------- |
| `POSTGRES_USER`     | No        | Default: `ai_expenses`          |
| `POSTGRES_PASSWORD` | **Yes**   | Change the default password     |
| `POSTGRES_DB`       | No        | Default: `ai_expenses`          |
| `POSTGRES_PORT`     | No        | Default: `5432`                 |
| `REDIS_PORT`        | No        | Default: `6379`                 |
| `SERVER_PORT`       | No        | Default: `8080`                 |

**`server/.env`** — loaded into containers at runtime:

| Variable               | Required? | Description                                         |
| ---------------------- | --------- | --------------------------------------------------- |
| `FIREBASE_PROJECT_ID`  | **Yes**   | Firebase project ID                                 |
| `FIREBASE_CLIENT_EMAIL`| **Yes**   | Service account email                               |
| `FIREBASE_PRIVATE_KEY` | **Yes**   | Service account private key (wrap in double quotes) |
| `POSTGRES_PASSWORD`    | **Yes**   | Must match root `.env`                              |

All other variables have sensible defaults for Docker.

### 2. Start services

```bash
# Core services (server + PostgreSQL)
docker compose up -d

# With Redis (for caching / rate limiting)
docker compose --profile with-redis up -d

# Everything
docker compose --profile full up -d
```

### 3. Run database migrations

```bash
docker compose exec server node dist/src/db/migrate.js
```

> If your project doesn't have a compiled migration runner yet, run
> `npm run db:migrate` from a local checkout pointing at the production DB.

### 4. Verify

```bash
curl http://localhost:8080/health
# → { "status": "ok" }
```

### 5. View logs

```bash
docker compose logs -f server
```

---

## Manual Deployment (No Docker)

### Install

```bash
cd server
npm ci
npm run build
```

### Configure

```bash
cp .env.example .env
# Edit .env with production values
```

### Run

```bash
NODE_ENV=production node dist/src/main.js
```

---

## Environment Variables

Full reference of every variable the server reads (validated by Zod).

| Variable               | Type     | Default                                                        | Description                        |
| ---------------------- | -------- | -------------------------------------------------------------- | ---------------------------------- |
| `NODE_ENV`             | `enum`   | `development`                                                  | `development`, `test`, `staging`, or `production` |
| `HOST`                 | `string` | `127.0.0.1`                                                    | IP address to bind                 |
| `PORT`                 | `number` | `8080`                                                         | Server port                        |
| `DATABASE_URL`         | `string` | `postgres://localhost/ai_expenses_dev`                         | PostgreSQL connection string       |
| `FIREBASE_PROJECT_ID`  | `string` | _(required in production)_                                     | Firebase project ID                |
| `FIREBASE_CLIENT_EMAIL`| `string` | _(required in production)_                                     | Admin SDK service account email    |
| `FIREBASE_PRIVATE_KEY` | `string` | _(required in production)_                                     | Private key with `\n` newlines     |
| `LOG_LEVEL`            | `enum`   | `info`                                                         | Pino log level                     |
| `POSTGRES_USER`        | `string` | `ai_expenses`                                                  | Docker Compose only                |
| `POSTGRES_PASSWORD`    | `string` | _(change me)_                                                  | Docker Compose only                |
| `POSTGRES_DB`          | `string` | `ai_expenses`                                                  | Docker Compose only                |
| `POSTGRES_PORT`        | `number` | `5432`                                                         | Docker Compose only                |
| `REDIS_PORT`           | `number` | `6379`                                                         | Docker Compose only                |

---

## Nginx Reverse Proxy

A production-ready nginx config template is included at [`nginx.conf`](nginx.conf).

```bash
# Copy to nginx
sudo cp nginx.conf /etc/nginx/sites-available/ai-expenses-api
sudo ln -s /etc/nginx/sites-available/ai-expenses-api /etc/nginx/sites-enabled/

# Replace api.example.com with your domain
sudo sed -i 's/api.example.com/your-domain.com/g' /etc/nginx/sites-available/ai-expenses-api

# Get SSL certificates
sudo certbot --nginx -d your-domain.com

# Reload
sudo nginx -t && sudo systemctl reload nginx
```

---

## Endpoints

| Method | Path                  | Auth     | Description         |
| ------ | --------------------- | -------- | ------------------- |
| GET    | `/health`             | None     | Health check        |
| GET    | `/metrics`            | None     | Prometheus metrics  |
| GET    | `/api/users/me`       | Firebase | Current user profile|
| GET    | `/api/account`        | Firebase | Account details     |
| POST   | `/api/sync/push`      | Firebase | Push data to server |
| POST   | `/api/sync/pull`      | Firebase | Pull data from server|

---

## Architecture

```
Client (Flutter App)
    │  Firebase Auth token
    ▼
Nginx (443) ─── reverse proxy ───> Fastify Server (:8080)
                                        │
                                        ├── Firebase Admin SDK (verifies tokens)
                                        ├── PostgreSQL 16 (Drizzle ORM)
                                        └── Redis 7 (optional cache)
```

---

## Troubleshooting

| Symptom                            | Fix                                                              |
| ---------------------------------- | ---------------------------------------------------------------- |
| `ECONNREFUSED` on port 8080        | Server didn't start — check `docker compose logs server`         |
| `FirebaseApp: credential` error    | Verify `FIREBASE_*` vars in `.env`                               |
| `password authentication failed`   | Check `POSTGRES_PASSWORD` matches the user                       |
| Migration errors                   | Ensure `DATABASE_URL` points to the correct Postgres container   |
| `permission denied` on volume      | `sudo chown -R 1000:1000 pgdata/` (Postgres UID in Alpine)       |

---

## Scripts (dev only)

```bash
npm run dev              # Hot-reload with tsx
npm run build            # Compile TypeScript
npm run test             # Run vitest suite
npm run lint             # ESLint
npm run db:generate      # Generate Drizzle migrations
npm run db:migrate       # Apply migrations
npm run db:studio        # Open Drizzle Studio
```

---

## License

Private — AI Expenses Tracker project.
