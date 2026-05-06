# Deploy to Railway

## Steps

### 1. Push to GitHub
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/adaptive-assessment-platform.git
git push -u origin main
```

### 2. Deploy on Railway
1. Go to https://railway.app
2. Click "New Project" → "Deploy from GitHub repo"
3. Select your repository
4. Choose the `adaptive-assessment-platform/backend` folder as root

### 3. Add Services on Railway
Add these services to your project:
- **MongoDB**: Click "Add Service" → "Database" → "MongoDB"
- **Redis**: Click "Add Service" → "Database" → "Redis"

### 4. Set Environment Variables
In Railway dashboard → your backend service → Variables, add:

```
NODE_ENV=production
PORT=3000
MONGODB_URI=${{MongoDB.MONGODB_URL}}
REDIS_URL=${{Redis.REDIS_URL}}
JWT_SECRET=<generate a random 32+ char string>
JWT_EXPIRES_IN=8h
REFRESH_TOKEN_SECRET=<generate another random 32+ char string>
REFRESH_TOKEN_EXPIRES_IN=7d
ENCRYPTION_KEY=<generate a random 32 char hex string>
RATE_LIMIT_WINDOW_MS=60000
RATE_LIMIT_MAX_REQUESTS=100
```

### 5. Get your API URL
After deployment, Railway gives you a URL like:
`https://adaptive-assessment-platform-production.up.railway.app`

Your API base URL will be:
`https://adaptive-assessment-platform-production.up.railway.app/api/v1`

### 6. Build Flutter APK with production URL
```bash
flutter build apk --release \
  --dart-define=ENV=production \
  "--dart-define=API_URL=https://your-app.up.railway.app/api/v1"
```

### 7. Seed the database
After deployment, run the seed script once:
```bash
MONGODB_URI=<your railway mongodb url> node scripts/seed.js
```

Or use Railway's shell to run it directly.
