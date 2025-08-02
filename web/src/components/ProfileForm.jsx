import React from 'react';
import './profileform.css';
import { useNavigate } from 'react-router-dom';

const ProfilePage = () => {
  const navigate = useNavigate();

  const handleEditClick = (e) => {
    const btn = e.target;
    const originalText = btn.textContent;
    btn.style.background = 'linear-gradient(135deg, #4CAF50, #45a049)';
    btn.textContent = 'Đang xử lý...';
    setTimeout(() => {
      btn.style.background = 'linear-gradient(135deg, #667eea, #764ba2)';
      btn.textContent = originalText;
    }, 1500);
  };

  return (
    <div>
      <main className="main-content">
        <div className="profile-section">
          <div className="profile-content">
            <div className="profile-avatar">NA</div>
            <div className="profile-info">
              <h1 className="profile-name">Nguyễn Văn A</h1>
              <p className="profile-email">nguyenvana@example.com</p>
            </div>
          </div>
        </div>

        <div className="info-grid">
          <div className="info-card">
            <h2 className="info-title">Thông tin cá nhân</h2>
            <div className="info-item">
              <span className="info-label">Số điện thoại</span>
              <span className="info-value">+84 123 456 789</span>
            </div>
            <div className="info-item">
              <span className="info-label">Địa chỉ</span>
              <span className="info-value">Hà Nội, Việt Nam</span>
            </div>
            <div className="info-item">
              <span className="info-label">Ngày tham gia</span>
              <span className="info-value">01/01/2024</span>
            </div>
            <button className="edit-btn" onClick={() => navigate('/editprofile')}>Chỉnh sửa thông tin</button>
          </div>

          <div className="info-card">
            <h2 className="info-title">Cài đặt tài khoản</h2>
            <div className="info-item">
              <span className="info-label">Ngôn ngữ</span>
              <span className="info-value">Tiếng Việt</span>
            </div>
            <div className="info-item">
              <span className="info-label">Múi giờ</span>
              <span className="info-value">GMT+7</span>
            </div>
            <div className="info-item">
              <span className="info-label">Thông báo</span>
              <span className="info-value">Bật</span>
            </div>
            <button className="edit-btn" onClick={handleEditClick}>Cài đặt thông báo</button>
          </div>
        </div>

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
      </main>
    </div>
  );
};

export default ProfilePage;
