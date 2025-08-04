import React, { useState, useRef, useEffect, useCallback } from 'react';
import '../../styles/layout/Header.css';
import { jwtDecode } from 'jwt-decode';
import { useNavigate, Link } from 'react-router-dom';
import {
  getNotifications,
  markAllAsRead,
  markAsRead,
} from '../../services/notificationService';
import { useSocket } from '../../hooks/SocketProvider';

const Header = () => {
  const [user, setUser] = useState(null);
  const [isOpen, setIsOpen] = useState(false);
  const [unreadCount, setUnreadCount] = useState(0);
  const [notifications, setNotifications] = useState([]);
  const [visibleCount, setVisibleCount] = useState(6);
  const [toastNotification, setToastNotification] = useState(null);
  const dropdownRef = useRef(null);
  const navigate = useNavigate();
  const socket = useSocket();

  const toggleDropdown = useCallback(() => setIsOpen((prev) => !prev), []);

  const handleClickOutside = useCallback((e) => {
    if (dropdownRef.current && !dropdownRef.current.contains(e.target)) {
      setIsOpen(false);
    }
  }, []);

  const markAllAsReadHandler = useCallback(async () => {
    try {
      await markAllAsRead();
      setNotifications((prev) =>
        prev.map((n) => ({ ...n, is_read: true }))
      );
      setUnreadCount(0);
    } catch (error) {
      console.error('Error marking all as read:', error);
    }
  }, []);

  const handleNotificationClick = useCallback(
    async (id) => {
      try {
        await markAsRead(id, { is_read: true });
        setNotifications((prev) =>
          prev.map((n) =>
            n._id === id ? { ...n, is_read: true } : n
          )
        );
        setUnreadCount((prev) => Math.max(prev - 1, 0));
      } catch (error) {
        console.error('Error marking notification as read:', error);
      }
    },
    []
  );

  const handleLoadMore = useCallback(() => {
    setVisibleCount((prev) => prev + 6);
  }, []);

  useEffect(() => {
    const fetchNotifications = async () => {
      try {
        const res = await getNotifications();
        setNotifications(res.notifications || []);
        const unread = res.notifications?.filter((n) => !n.is_read).length || 0;
        setUnreadCount(unread);
      } catch (error) {
        console.error('Error fetching notifications:', error);
      }
    };

    fetchNotifications();
    // const intervalId = setInterval(fetchNotifications, 60000); // Refresh every 1 minute

    // return () => clearInterval(intervalId);
  }, []);

  // useEffect(() => {
  //   if (!socket) return;

  //   const handleNewNotification = (data) => {
  //     setNotifications((prev) => [data, ...prev]);
  //     setUnreadCount((prev) => prev + 1);
  //   };

  //   socket.on('notification', handleNewNotification);

  //   return () => {
  //     socket.off('notification', handleNewNotification);
  //   };
  // }, [socket]);

  useEffect(() => {
    const token = localStorage.getItem('token');

    if (!token) {
      navigate('/login');
      return;
    }

    try {
      jwtDecode(token); // Validate token
      const storedUser = localStorage.getItem('user');
      if (storedUser) {
        setUser(JSON.parse(storedUser));
      } else {
        console.warn('User info not found → logging out');
        logoutUser();
      }
    } catch (err) {
      console.error('Invalid token → logging out');
      logoutUser();
    }
  }, [navigate]);

  useEffect(() => {
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [handleClickOutside]);

  const visibleNotifications = notifications.slice(0, visibleCount);
  const hasMore = visibleCount < notifications.length;

  return (
    <header className="header">
      <div className="header-content">
        <div
          className="logo"
          onClick={() => navigate('/dashboard')}
          style={{ cursor: 'pointer' }}
        >
          🛠️ Project Hub
        </div>
        <div className="user-info">
          {user ? (
            <>
              <span
                onClick={() => navigate('/profile')}
                style={{ cursor: 'pointer' }}
              >
                Chào mừng, <strong>{user.full_name}</strong>
              </span>
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
              {unreadCount > 0 && (
                <span className="notification-dot"></span>
              )}
            </button>
            {isOpen && (
              <div className="notification-dropdown">
                <div className="dropdown-header">
                  <span>Thông báo</span>
                  <button
                    className="mark-read"
                    onClick={markAllAsReadHandler}
                  >
                    Đánh dấu đã đọc
                  </button>
                </div>
                <div className="dropdown-list">
                  {visibleNotifications.map((n, i) => (
                    <div
                      className={`dropdown-item ${
                        n.is_read ? 'read' : ''
                      }`}
                      key={i}
                      onClick={() => handleNotificationClick(n._id)}
                      style={{ cursor: 'pointer' }}
                    >
                      <span className="icon">🔔</span>
                      <div className="content">
                        <div className="title">
                          <strong>{n.title}</strong>
                        </div>
                        <div className="text">{n.message}</div>
                        <div className="time">
                          {new Date(n.created_at).toLocaleString()}
                        </div>
                      </div>
                    </div>
                  ))}
                  {hasMore && (
                    <button
                      className="load-more-btn"
                      onClick={handleLoadMore}
                    >
                      Xem thông báo trước đó
                    </button>
                  )}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
      {toastNotification && (
        <div className="toast-notification">
          <strong>{toastNotification.title}</strong>
          <p>{toastNotification.message}</p>
        </div>
      )}
    </header>
  );
};

export default Header;
