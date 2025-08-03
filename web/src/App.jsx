import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';
import Dashboard from './pages/DashboardPage';
import LoginAdminPage from './pages/LoginAdminPage';
import LandingPage from './pages/LandingPage';
import ProjectListPage from './pages/ProjectListPage';
import ProjectDetail from './pages/ProjectdetailPage';
import CreateProject from './pages/CreateProjectPage';
import ProfilePage from './pages/ProfilePage';
import TaskDetailPage from './pages/TaskDetailPage';
import CreateTaskPage from './pages/CreateTaskPage';
import MyTasksPage from './pages/MyTasksPage';

export default function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/admin/login" element={<LoginAdminPage />} />
        <Route path="/register" element={<RegisterPage />} />
        <Route path="/profile" element={<ProfilePage />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/projects" element={<ProjectListPage />} />
        <Route path="/projects/projectdetail" element={<ProjectDetail />} />
        <Route path="/projects/create" element={<CreateProject />} />
        <Route path="/tasks/taskdetail" element={<TaskDetailPage />} />
        <Route path="/tasks/create" element={<CreateTaskPage />} />
        <Route path="/tasks" element={<MyTasksPage />} />
      </Routes>
    </Router>
  );
}
