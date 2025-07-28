import './Dashboard.css';
import React, { useEffect, useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { refreshToken } from '../services/authService';
import { jwtDecode } from 'jwt-decode';
import { getAllProjects } from '../services/projectService';

export default function Dashboard() {
  const [user, setUser] = useState(null);
  const navigate = useNavigate();
  const [totalProjects, setTotalProjects] = useState(0);
  // 🚀 Load user info từ localStorage khi mount
  useEffect(() => {
    const token = localStorage.getItem('token');

    if (!token) {
      navigate('/login');
      return;
    }

    try {
      jwtDecode(token); // kiểm tra token hợp lệ
      const storedUser = localStorage.getItem('user');

      if (storedUser) {
        setUser(JSON.parse(storedUser));
      } else {
        console.warn('Không tìm thấy thông tin user → logout');
        logoutUser();
      }
    } catch (err) {
      console.log('Token không hợp lệ → logout');
      logoutUser();
    }
  }, [navigate]);

  useEffect(() => {
    const fetchProjects = async () => {
      try {
        const res = await getAllProjects(); // trả về { projects: [...], total: 1, ... }
        setTotalProjects(res.total);
      } catch (error) {
        console.error('Lỗi khi lấy danh sách project:', error);
      }
    };

    fetchProjects();
  }, []);

  // 🧠 Kiểm tra token mỗi 10s và gọi refresh nếu cần
  useEffect(() => {
    const interval = setInterval(async () => {
      const token = localStorage.getItem('token');
      const refresh = localStorage.getItem('refreshToken');

      if (token) {
        try {
          const { exp } = jwtDecode(token);
          const now = Math.floor(Date.now() / 1000);

          if (exp - now <= 5) {
            if (!refresh) {
              console.log('Không có refresh token → logout');
              logoutUser();
              return;
            }

            try {
              const response = await refreshToken(refresh);
              localStorage.setItem('token', response.token);
              if (response.refreshToken) {
                localStorage.setItem('refreshToken', response.refreshToken);
              }
              console.log('🔁 Token refreshed thành công!');
            } catch (err) {
              console.log('❌ Refresh token không hợp lệ → logout');
              logoutUser();
            }
          }
        } catch (err) {
          console.log('Decode lỗi → logout');
          logoutUser();
        }
      }
    }, 10000);

    return () => clearInterval(interval);
  }, []);

  const logoutUser = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('refreshToken');
    localStorage.removeItem('user');
    alert('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
    navigate('/login');
  };

  return (
    <div>
      <header className="header">
        <div className="header-content">
          <div className="logo">🛠️ Project Hub</div>
          <div className="user-info" onClick={() => navigate('/profile')} style={{ cursor: 'pointer' }}>
            {user ? (
              <>
                <span>Chào mừng, <strong>{user.full_name}</strong></span>
                <div className="user-avatar">
                  {user.full_name?.charAt(0) || 'U'}
                </div>
              </>
            ) : (
              <span>Đang tải...</span>
            )}
          </div>
        </div>
      </header>

      <main className="main-content">
        <div className="welcome-section">
          <div className="welcome-content">
            <h1 className="welcome-title">Chào mừng trở lại! 👋</h1>
            <p className="welcome-subtitle">Bạn có 5 dự án đang hoạt động và 12 task cần hoàn thành</p>
          </div>
        </div>

        <div className="stats-grid">
          <StatCard title="Dự án" icon="📁" value={totalProjects} change={`+${totalProjects} tuần này`} className="projects" />
          <StatCard title="Task tổng" icon="📋" value={45} change="+7 hôm nay" className="tasks" />
          <StatCard title="Hoàn thành" icon="✅" value={33} change="73% tỷ lệ" className="completed" />
          <StatCard title="Quá hạn" icon="⏰" value={3} change="-1 từ hôm qua" className="overdue" />
        </div>

        <div className="recent-section">
          <RecentProjects />
          <MyTasks />
        </div>

        <QuickActions />
      </main>
    </div>
  );
}

function StatCard({ title, icon, value, change, className }) {
  return (
    <div className={`stat-card ${className}`}>
      <div className="stat-header">
        <span className="stat-title">{title}</span>
        <span className="stat-icon">{icon}</span>
      </div>
      <div className="stat-number">{value}</div>
      <div className="stat-change">{change}</div>
    </div>
  );
}

function RecentProjects() {
  return (
    <div className="section-card">
      <div className="section-header">
        <h2 className="section-title">Dự án gần đây</h2>
        <Link to="/projects" className="view-all">Xem tất cả</Link>
      </div>
      <div className="item-list">
        {[
          { icon: '📱', title: 'Mobile App Development', members: 5, tasks: 15, status: 'progress' },
          { icon: '🌐', title: 'Website Redesign', members: 3, tasks: 8, status: 'completed' },
          { icon: '🔧', title: 'API Integration', members: 2, tasks: 12, status: 'overdue' },
        ].map((p, i) => (
          <div className="item" key={i}>
            <div className="item-icon project-icon">{p.icon}</div>
            <div className="item-content">
              <div className="item-title">{p.title}</div>
              <div className="item-meta">
                <span>{p.members} thành viên</span> • <span>{p.tasks} tasks</span>
              </div>
            </div>
            <div className={`status-badge status-${p.status}`}>
              {p.status === 'progress' && 'Đang thực hiện'}
              {p.status === 'completed' && 'Hoàn thành'}
              {p.status === 'overdue' && 'Quá hạn'}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function MyTasks() {
  return (
    <div className="section-card">
      <div className="section-header">
        <h2 className="section-title">Task của tôi</h2>
        <Link to="/tasks" className="view-all">Xem tất cả</Link>
      </div>
      <div className="item-list">
        {[
          { icon: '🎨', title: 'Thiết kế UI Dashboard', project: 'Mobile App', deadline: '2 ngày', status: 'progress' },
          { icon: '⚙️', title: 'Tích hợp API Payment', project: 'Website', deadline: '1 tuần', status: 'progress' },
          { icon: '🧪', title: 'Viết Unit Tests', project: 'API Integration', deadline: 'Hôm qua', status: 'overdue' },
        ].map((task, i) => (
          <div className="item" key={i}>
            <div className="item-icon task-icon">{task.icon}</div>
            <div className="item-content">
              <div className="item-title">{task.title}</div>
              <div className="item-meta">
                <span>{task.project}</span> • <span>Hạn: {task.deadline}</span>
              </div>
            </div>
            <div className={`status-badge status-${task.status}`}>
              {task.status === 'progress' && 'Đang làm'}
              {task.status === 'overdue' && 'Quá hạn'}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function QuickActions() {
  return (
    <div className="quick-actions">
      <h2 className="section-title" style={{ marginBottom: 20 }}>Thao tác nhanh</h2>
      <div className="actions-grid">
        <button className="action-btn">➕ Tạo dự án mới</button>
        <button className="action-btn">📋 Thêm task</button>
        <button className="action-btn">👥 Mời thành viên</button>
        <button className="action-btn">📊 Báo cáo</button>
      </div>
    </div>
  );
}
