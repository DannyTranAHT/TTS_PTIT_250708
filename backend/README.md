# 🚀 Backend Development Guide (ExpressJS)

## 📦 Setup Instructions

1. Navigate to the backend folder:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create a `.env` file based on `.env.example`:
   ```
   PORT=5000
   MONGO_URI=mongodb://localhost:27017/project-management
   JWT_SECRET=your_jwt_secret
   ```

4. Start the development server:
   ```bash
   npm run dev
   ```

## 🧪 Testing

- Use Postman to hit endpoints like `/api/auth`, `/api/projects`, `/api/tasks`
- WebSocket endpoint runs on the same port using `Socket.IO`

## 📂 Structure Overview

- `routes/` – Route declarations
- `controllers/` – Request handlers
- `models/` – Mongoose schemas
- `middlewares/` – Auth & error handling
- `sockets/` – Real-time WebSocket logic
