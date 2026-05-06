# منصة التقييم المدرسي التكيفية
# Adaptive Assessment Platform

A comprehensive educational platform for adaptive and random assessments, targeting Arabic-speaking schools with RTL-first UI.

## Architecture

```
adaptive-assessment-platform/
├── backend/          # Node.js + Express + TypeScript API
└── mobile/           # Flutter mobile app (Android + iOS)
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter (Dart) — RTL Arabic-first |
| API | Node.js + Express + TypeScript |
| Database | MongoDB Atlas |
| Cache | Redis |
| Auth | JWT + bcrypt |
| Deployment | Docker + AWS ECS |

## Quick Start

### Prerequisites
- Node.js >= 18
- Flutter >= 3.19
- Docker & Docker Compose

### Backend

```bash
cd backend
cp .env.example .env
# Edit .env with your configuration

# Start with Docker (recommended)
docker-compose up -d

# Or run locally
npm install
npm run dev
```

### Mobile

```bash
cd mobile
flutter pub get
flutter run
```

## Environment Variables

See `backend/.env.example` for all required environment variables.

## API Documentation

Base URL: `http://localhost:3000/api/v1`

| Endpoint | Description |
|----------|-------------|
| `GET /health` | Health check |
| `POST /auth/login` | User login |
| `POST /auth/logout` | User logout |
| `POST /auth/refresh` | Refresh token |
| `GET /users` | List users (Admin) |
| `GET /classrooms` | List classrooms |
| `GET /questions` | List questions |
| `POST /assessments` | Create assessment |
| `POST /attempts` | Start exam session |
| `GET /reports/assessment/:id` | Assessment report |
| `GET /notifications` | User notifications |

## Design System

- **Primary Color**: `#00288E` (Academy Blue)
- **Font**: Almarai (Arabic) / Lexend (Latin)
- **Direction**: RTL (Right-to-Left)
- **Theme**: Material Design 3

## License

Private — All rights reserved.
