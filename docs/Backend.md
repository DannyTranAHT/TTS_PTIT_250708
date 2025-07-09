
# 🚀 Backend - ExpressJS (Node.js)

## 📂 Folder Structure

- `routes/` - Defines API endpoints
- `controllers/` - Business logic and request handlers
- `models/` - Mongoose models and schema definitions
- `services/` - Reusable logic modules
- `middlewares/` - Auth & error handling middleware
- `sockets/` - WebSocket event handlers

## 🔐 Authentication & Authorization

- JWT-based login and protected routes
- Role-based permissions (Admin, Project Manager, Employee)

## 📁 API Resources

- `/api/auth` - Register, login - Quynh
- `/api/projects` - CRUD for projects - Phu
- `/api/tasks` - CRUD for tasks - Phu
- `/api/comments` - Commenting system
- `/api/users` - Basic user profile & listing - Quynh

## ⚙️ Real-time via Socket.IO

- `task:update` - Real-time task updates
- `comment:new` - Live comment streaming
- `notification:new` - Task assignment, project status change, etc.

## 🧪 Testing

- Jest/Mocha for unit/integration testing
- Postman collection for manual testing

# Table schemas

##### 🧑 Users
| Field | Type | Notes |
|-------|------|-------|
| `_id` | UUID/ObjectId | Primary Key |
| `username` | String | Unique |
| `password` | String | Hashed |
| `email` | String | Unique |
| `fullName` | String |  |
| `role` | String | e.g., Admin, Project Manager, Employee |
| `createdAt`, `updatedAt` | Date |  |

---

##### 📁 Projects
| Field | Type | Notes |
|-------|------|-------|
| `_id` | UUID/ObjectId | Primary Key |
| `name` | String | Required |
| `description` | String |  |
| `startDate`, `endDate` | Date |  |
| `status` | String | e.g., Not Started, In Progress, Completed |
| `ownerId` | Reference | → Users._id |
| `members` | Array | → Users._id |
| `createdAt`, `updatedAt` | Date |  |

---

##### ✅ Tasks
| Field | Type | Notes |
|-------|------|-------|
| `_id` | UUID/ObjectId | Primary Key |
| `projectId` | Reference | → Projects._id |
| `name` | String | Required |
| `description` | String |  |
| `dueDate` | Date |  |
| `status` | String | e.g., To Do, In Progress, Blocked, Done |
| `priority` | String | e.g., Low, Medium, High |
| `assignedToId` | Reference | → Users._id (nullable) |
| `createdAt`, `updatedAt` | Date |  |

---

##### 💬 Comments
| Field | Type | Notes |
|-------|------|-------|
| `_id` | UUID/ObjectId | Primary Key |
| `entityType` | String | 'Project' or 'Task' |
| `entityId` | Reference | → Projects._id / Tasks._id |
| `userId` | Reference | → Users._id |
| `content` | String | Required |
| `createdAt`, `updatedAt` | Date |  |

---
# Development
