import React from 'react';
import './profileform.css';
import { useNavigate } from 'react-router-dom';

const ProfilePage = () => {
  const navigate = useNavigate();

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('refreshToken');
    localStorage.removeItem('user');
    localStorage.removeItem('projects');
    localStorage.removeItem('alltasks');
    localStorage.removeItem('notifications');
    navigate('/login');
  };

  return (
    <div className="profile-page">
      <main className="main-content">
        {/* Phần thông tin cá nhân */}
        <div className="profile-section">
          <div className="profile-content">
            <div className="profile-avatar">NA</div>
            <div className="profile-info">
              <h1 className="profile-name">Nguyễn Văn A</h1>
              <p className="profile-email">nguyenvana@example.com</p>
              <p className="profile-role">Project Manager</p>
            </div>
          </div>
        </div>

        {/* Thông tin chi tiết */}
        <div className="info-grid">
          <div className="info-card">
            <h2 className="info-title">Thông tin cá nhân</h2>
            <div className="info-item">
              <span className="info-label">Họ và tên</span>
              <span className="info-value">Nguyễn Văn A</span>
            </div>
            <div className="info-item">
              <span className="info-label">Email</span>
              <span className="info-value">nguyenvana@example.com</span>
            </div>
            <div className="info-item">
              <span className="info-label">Vai trò</span>
              <span className="info-value">Project Manager</span>
            </div>
            <div className="info-item">
              <span className="info-label">Chuyên ngành</span>
              <span className="info-value">Công nghệ thông tin</span>
            </div>
            <button className="edit-btn" onClick={() => navigate('/editprofile')}>
              ✏️ Chỉnh sửa thông tin
            </button>
          </div>
        </div>

        {/* Hoạt động gần đây */}
        <div className="activity-section">
          <h2 className="activity-title">Hoạt động gần đây</h2>
          <div className="activity-list">
            <div className="activity-item">
              <div className="activity-icon">📋</div>
              <div className="activity-content">
                <div className="activity-title">Hoàn thành task: Thiết kế UI Dashboard</div>
                <div className="activity-meta">2 giờ trước • Mobile App</div>
              </div>
            </div>
            <div className="activity-item">
              <div className="activity-icon">📱</div>
              <div className="activity-content">
                <div className="activity-title">Tham gia dự án: Mobile App Development</div>
                <div className="activity-meta">Hôm qua • 5 thành viên</div>
              </div>
            </div>
            <div className="activity-item">
              <div className="activity-icon">⚙️</div>
              <div className="activity-content">
                <div className="activity-title">Cập nhật task: Tích hợp API Payment</div>
                <div className="activity-meta">2 ngày trước • Website</div>
              </div>
            </div>
          </div>
        </div>

        {/* Nút đăng xuất */}
        <div className="logout-section">
          <button className="logout-btn" onClick={handleLogout}>
            🔒 Đăng xuất
          </button>
        </div>
      </main>
    </div>
  );
};

export default ProfilePage;
