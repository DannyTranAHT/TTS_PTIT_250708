import React, { useEffect } from 'react';
import './AdminDashboard.css';

const AdminDashboard = () => {
  useEffect(() => {
    const numbers = document.querySelectorAll('.stat-number');
    numbers.forEach(number => {
      const target = parseInt(number.textContent);
      let current = 0;
      const increment = target / 30;
      const timer = setInterval(() => {
        current += increment;
        if (current >= target) {
          number.textContent = target;
          clearInterval(timer);
        } else {
          number.textContent = Math.floor(current);
        }
      }, 50);
    });

    document.querySelectorAll('.stat-card').forEach(card => {
      card.addEventListener('click', () => {
        card.style.transform = 'scale(0.98)';
        setTimeout(() => {
          card.style.transform = 'translateY(-5px)';
        }, 150);
      });
    });

    document.querySelectorAll('.action-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const original = btn.textContent;
        btn.style.background = 'linear-gradient(135deg, #4CAF50, #45a049)';
        btn.textContent = 'Đang xử lý...';
        setTimeout(() => {
          btn.style.background = 'linear-gradient(135deg, #667eea, #764ba2)';
          btn.textContent = original;
        }, 1500);
      });
    });
  }, []);

  return (
    <div className="dashboard">
      <header className="header">
        <div className="header-content">
          <div className="logo">🛠️ Project Hub</div>
          <div className="user-info">
            <span>Chào mừng, <strong>Nguyễn Văn A</strong> (Admin)</span>
            <div className="user-avatar">NA</div>
          </div>
        </div>
      </header>

      <main className="main-content-admin-dashboard">
        <section className="welcome-section">
          <div className="welcome-content">
            <h1 className="welcome-title">Chào mừng đến với Dashboard Quản trị! 👑</h1>
            <p className="welcome-subtitle">Quản lý người dùng, dự án, và theo dõi hiệu suất hệ thống</p>
          </div>
        </section>

        <div className="stats-grid">
          <StatCard type="users" title="Người dùng" icon="👥" number={25} change="+3 tuần này" />
          <StatCard type="projects" title="Dự án" icon="📁" number={12} change="+2 hôm nay" />
          <StatCard type="tasks" title="Task tổng" icon="📋" number={85} change="+10 tuần này" />
          <StatCard type="notifications" title="Thông báo chưa đọc" icon="🔔" number={7} change="+4 hôm nay" />
        </div>

        <div className="recent-section">
          <SectionCard
            title="Người dùng gần đây"
            link="/api/users"
            items={[
              { icon: 'TB', name: 'Trần Thị B', role: 'Project Manager', joined: '01/07/2025', status: 'Hoạt động' },
              { icon: 'LC', name: 'Lê Văn C', role: 'Employee', joined: '28/06/2025', status: 'Hoạt động' },
            ]}
            isUser
          />

          <SectionCard
            title="Dự án cần chú ý"
            link="/api/projects"
            items={[
              { icon: '🔧', name: 'API Integration', progress: '40%', deadline: '05/07/2025', status: 'Quá hạn' },
              { icon: '📈', name: 'Marketing Campaign', progress: '20%', deadline: '15/07/2025', status: 'Đang thực hiện' },
            ]}
            isUser={false}
          />
        </div>

        <div className="quick-actions">
          <h2 className="section-title" style={{ marginBottom: '20px' }}>Thao tác nhanh</h2>
          <div className="actions-grid">
            <button className="action-btn">👥 Thêm người dùng mới</button>
            <button className="action-btn">📊 Xem báo cáo hệ thống</button>
            <button className="action-btn">🔧 Quản lý vai trò</button>
            <button className="action-btn">🔔 Gửi thông báo toàn hệ thống</button>
          </div>
        </div>
      </main>
    </div>
  );
};

const StatCard = ({ type, title, icon, number, change }) => (
  <div className={`stat-card ${type}`}>
    <div className="stat-header">
      <span className="stat-title">{title}</span>
      <span className="stat-icon">{icon}</span>
    </div>
    <div className="stat-number">{number}</div>
    <div className="stat-change">{change}</div>
  </div>
);

const SectionCard = ({ title, link, items, isUser }) => (
  <div className="section-card">
    <div className="section-header">
      <h2 className="section-title">{title}</h2>
      <a href={link} className="view-all">Xem tất cả</a>
    </div>
    <div className="item-list">
      {items.map((item, idx) => (
        <div className="item" key={idx}>
          <div className={`item-icon ${isUser ? 'user-icon' : 'project-icon'}`}>{item.icon}</div>
          <div className="item-content">
            <div className="item-title">{item.name}</div>
            <div className="item-meta">
              {isUser ? (
                <>
                  <span>Vai trò: {item.role}</span>
                  <span>•</span>
                  <span>Tham gia: {item.joined}</span>
                </>
              ) : (
                <>
                  <span>Tiến độ: {item.progress}</span>
                  <span>•</span>
                  <span>Hạn: {item.deadline}</span>
                </>
              )}
            </div>
          </div>
          <div className={`status-badge ${item.status === 'Quá hạn' ? 'status-overdue' : 'status-active'}`}>
            {item.status}
          </div>
        </div>
      ))}
    </div>
  </div>
);

export default AdminDashboard;
