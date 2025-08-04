import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { useEffect, useState } from 'react';
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
import AdminDashboardPage from './pages/AdminDashboardPage';
import AdminRoute from './components/AdminRoute';
import EditProfilePage from './pages/EditProfilePage';
import TaskListPage from './pages/TaskListPage';
import MainLayout from './components/layout/MainLayout';
import EditProjectPage from './pages/EditProjectPage';

function AppContent() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  useEffect(() => {
    // Kiểm tra token trong localStorage
    const token = localStorage.getItem('token');
    setIsLoggedIn(!!token); // Nếu có token, người dùng đã đăng nhập
  }, []);

  return (
    <Routes>
      {/* Các route không cần Header */}
      <Route path="/" element={<LandingPage />} />
      <Route path="/login" element={<LoginPage />} />
      <Route path="/admin/login" element={<LoginAdminPage />} />
      <Route path="/register" element={<RegisterPage />} />

        <Route element={<MainLayout />}>
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/profile" element={<ProfilePage />} />
          <Route path="/editprofile" element={<EditProfilePage />} />
          <Route path="/projects" element={<ProjectListPage />} />
          <Route path="/projects/:id" element={<ProjectDetail />} />
          <Route path="/projects/:id/edit" element={<EditProjectPage />} />
          <Route path="/projects/:id/tasks" element={<TaskListPage />} />
          <Route path="/projects/create" element={<CreateProject />} />
          <Route path="/tasks/:id" element={<TaskDetailPage />} />
          <Route path="/tasks/create" element={<CreateTaskPage />} />
          <Route path="/tasks" element={<MyTasksPage />} />
          <Route
            path="/admin/dashboard"
            element={
              <AdminRoute>
                <AdminDashboardPage />
              </AdminRoute>
            }
          />
        </Route>
      
    </Routes>
  );
}

export default function App() {
  return (
    <Router>
      <AppContent />
    </Router>
  );
}
