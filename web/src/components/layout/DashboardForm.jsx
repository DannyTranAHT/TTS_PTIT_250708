import '../../styles/layout/Dashboard.css';
import React, { useEffect, useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { refreshToken } from '../../services/authService';
import { jwtDecode } from 'jwt-decode';
import { getAllProjects } from '../../services/projectService';
import { getAllTasks } from '../../services/taskService';

export default function Dashboard() {
  const [user, setUser] = useState(null);
  const navigate = useNavigate();
  const [totalProjects, setTotalProjects] = useState(0);
  const [tasks, setTasks] = useState([]);
  const [projects, setProjects] = useState([]);
  const [taskdone, setTaskDone] = useState(0);
  const [taskblock, setTaskBlock] = useState(0);
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
      // Lấy thông tin tất cả dự án
      const fetchProjects = async () => {
        try {
          // Kiểm tra nếu đã có projects trong localStorage
          const storedProjects = localStorage.getItem("projects");
          if (storedProjects) {
            setProjects(JSON.parse(storedProjects)); // Sử dụng dữ liệu từ localStorage
            setTotalProjects(JSON.parse(storedProjects).length);
            return;
          }
  
          // Nếu chưa có, gọi API để lấy projects
          const res = await getAllProjects({page: 1, limit: 100});
          setProjects(res.projects);
          setTotalProjects(res.total);
          localStorage.setItem("projects", JSON.stringify(res.projects)); // Lưu vào localStorage
        } catch (error) {
          console.error("Lỗi khi lấy danh sách dự án:", error);
        }
      };
  
      fetchProjects();
    }, []); // Chỉ chạy một lần khi component được mount
  
    useEffect(() => {
      // Lấy danh sách tất cả task của từng dự án
      const fetchTasks = async () => {
        try {
          // Kiểm tra nếu đã có tasks trong localStorage
          const storedTasks = localStorage.getItem("alltasks");
          if (storedTasks) {
            setTasks(JSON.parse(storedTasks)); // Sử dụng dữ liệu từ localStorage
            return;
          }
  
          // Nếu chưa có, gọi API để lấy tasks
          const allTasks = [];
          for (const project of projects) {
            const res = await getAllTasks(project._id);
            allTasks.push(...res.tasks);
          }
          setTasks(allTasks); // Cập nhật state tasks
          localStorage.setItem("alltasks", JSON.stringify(allTasks)); // Lưu vào localStorage
        } catch (error) {
          console.error("Lỗi khi lấy danh sách task:", error);
        }
      };
  
      if (projects.length > 0) {
        fetchTasks(); // Chỉ gọi khi danh sách projects đã được cập nhật
      }
    }, [projects]); // Theo dõi sự thay đổi của projects
  useEffect(() => {
    const completedTasks = tasks.filter(task => task.status === 'Done').length;
    const blockedTasks = tasks.filter(task => task.status === 'Blocked').length;
    setTaskBlock(blockedTasks);
    setTaskDone(completedTasks);
  }, [tasks]);

  const logoutUser = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('refreshToken');
    localStorage.removeItem('user');
    alert('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
    navigate('/login');
  };

  return (
    <div>
      <main className="main-content">
        <div className="welcome-section">
          <div className="welcome-content">
            <h1 className="welcome-title">Chào mừng trở lại! 👋</h1>
            <p className="welcome-subtitle">Bạn có 5 dự án đang hoạt động và 12 task cần hoàn thành</p>
          </div>
        </div>

        <div className="stats-grid">
          <StatCard title="Dự án" icon="📁" value={totalProjects} change={`+${totalProjects} tuần này`} className="projects" />
          <StatCard title="Task tổng" icon="📋" value={tasks.length} change="+7 hôm nay" className="tasks" />
          <StatCard title="Hoàn thành" icon="✅" value={taskdone} change="73% tỷ lệ" className="completed" />
          <StatCard title="Quá hạn" icon="⏰" value={taskblock} change="-1 từ hôm qua" className="overdue" />
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
