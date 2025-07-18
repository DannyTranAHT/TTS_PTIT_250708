# 🛠️ Internship Project: Internal Project Management Tool

This is a full-stack internal project management and collaboration tool built using:
- **Flutter** (Mobile)
- **ReactJS** (Web)
- **ExpressJS** (Backend)
- **MongoDB** (Database)
- **Socket.IO** (Real-time Communication)

## 📦 Project Structure

- `backend/` - ExpressJS API server
- `web/` - ReactJS frontend application
- `mobile/` - Flutter mobile application
- `docs/` - Project documentation and milestones

## 📈 Features Overview

- User Registration & Role-Based Login
- Project & Task Management (CRUD)
- Real-Time Comments & Task Updates via WebSocket
- In-App Notifications
- Optional: Task Import (CSV), Archiving, Due Date Reminders

## 📚 Documentation

- 📄 [Backend Overview](docs/Backend.md)
- 🌐 [Web Frontend Overview](docs/Web.md)
- 📱 [Mobile Frontend Overview](docs/Mobile.md)
- ✅ [Technical Milestones](docs/Milestones.md)
- 📏 [Coding Guideline](docs/Coding_guideline/README.md)
- 🔀 [Git Workflow](docs/Git/README.md)

## 🚀 Getting Started

1. Clone the repo
2. Navigate to `backend/`, `web/`, or `mobile/` and follow the setup instructions
3. Run backend first, then frontend clients


## 🚀 Stretch Goals

### ⏰ Reminder Scheduler
- Use `node-cron` or `setInterval`
- Notify users of tasks due in next 24–48 hrs via WebSocket

---

### 📥 Batch Task Import/Export
- **Backend:**
  - CSV upload API
  - Async CSV processing with `setTimeout`
  - Error handling for invalid rows
- **Frontend (React):**
  - CSV Upload UI
  - Show "Processing..." indicator
  - Notify on completion (WebSocket)

---

### 🗃️ Project/Task Archiving
- **Backend:**
  - Simulate long-running archiving (`setTimeout`)
  - Change project status to `Archiving...` → `Archived`
- **Frontend (React):**
  - UI status display
  - Notify user when archiving completes## Stretch goals

---