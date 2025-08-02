import React, { useState, useRef, useEffect } from 'react';
import '../../styles/layout/Header.css';
import { jwtDecode } from 'jwt-decode';
import { useNavigate, Link } from 'react-router-dom';

const Header = () => {
  const [user, setUser] = useState(null);
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef(null);
  const navigate = useNavigate();

  const [notifications, setNotifications] = useState([
    { icon: '🔔', text: 'Task "Viết Unit Tests" đã quá hạn!', time: '2 giờ trước', read: false },
    { icon: '✅', text: 'Dự án Website Redesign đã hoàn thành', time: 'Hôm qua', read: false },
    { icon: '👥', text: 'Thành viên mới được thêm vào Mobile App', time: '3 ngày trước', read: false },
    { icon: '📢', text: 'Có bản cập nhật mới cho hệ thống', time: '4 ngày trước', read: true },
    { icon: '📝', text: 'Bạn vừa được giao task "Thiết kế wireframe"', time: '5 ngày trước', read: false },
    { icon: '📅', text: 'Cuộc họp Sprint Planning vào 9h sáng mai', time: '6 ngày trước', read: true },
    { icon: '⚠️', text: 'Có lỗi xảy ra trong quá trình build app', time: '7 ngày trước', read: false },
    { icon: '🔄', text: 'Bạn vừa cập nhật trạng thái task "Deploy"', time: '1 tuần trước', read: true }
  ]);

  const [visibleCount, setVisibleCount] = useState(6);

  const toggleDropdown = () => setIsOpen(prev => !prev);

  const handleClickOutside = (e) => {
    if (dropdownRef.current && !dropdownRef.current.contains(e.target)) {
      setIsOpen(false);
    }
  };

  const markAllAsRead = () => {
    setNotifications(prev => prev.map(n => ({ ...n, read: true })));
  };

  const handleLoadMore = () => {
    setVisibleCount(prev => prev + 6);
  };

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
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const visibleNotifications = notifications.slice(0, visibleCount);
  const hasMore = visibleCount < notifications.length;

  return (
    <header className="header">
      <div className="header-content">
        <div className="logo" onClick={() => navigate('/dashboard')} style={{ cursor: 'pointer' }}>🛠️ Project Hub</div>
         <div className="user-info" >
          {user ? (
              <>
                <span onClick={() => navigate('/profile')} style={{ cursor: 'pointer' }}>
                Chào mừng, <strong>{user.full_name}</strong></span>
                <div className="user-avatar">
                  {user.full_name?.charAt(0) || 'U'}
                </div>
              </>
            ) : (
              <span>Đang tải...</span>
            )}
          <div className="notification-wrapper" ref={dropdownRef}>
            <button className="notification-btn" onClick={toggleDropdown}>
              🔔
            </button>
            {isOpen && (
              <div className="notification-dropdown">
                <div className="dropdown-header">
                  <span>Thông báo</span>
                  <button className="mark-read" onClick={markAllAsRead}>Đánh dấu đã đọc</button>
                </div>
                <div className="dropdown-list">
                  {visibleNotifications.map((n, i) => (
                    <div className={`dropdown-item ${n.read ? 'read' : ''}`} key={i}>
                      <span className="icon">{n.icon}</span>
                      <div className="content">
                        <div className="text">{n.text}</div>
                        <div className="time">{n.time}</div>
                      </div>
                    </div>
                  ))}
                  {hasMore && (
                    <button className="load-more-btn" onClick={handleLoadMore}>
                      Xem thông báo trước đó
                    </button>
                  )}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;
