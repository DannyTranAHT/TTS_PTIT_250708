# 🌐 Web Frontend Development Guide (ReactJS)

## 📦 Setup Instructions

1. Navigate to the web folder:
   ```bash
   cd web
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the development server:
   ```bash
   npm run dev
   ```

> React app runs by default at `http://localhost:3000`

## ⚙️ Environment Variables

Create a `.env` file:
```
VITE_API_BASE_URL=http://localhost:5000/api
VITE_SOCKET_URL=http://localhost:5000
```

## 📂 Structure Overview

- `components/` – Reusable UI components
- `pages/` – Main views like Dashboard, Project, Task
- `services/` – API and socket utilities
- `context/` – App-wide state management
