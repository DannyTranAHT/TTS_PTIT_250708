import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { loginUser, refreshToken } from '../services/authService';
import { jwtDecode } from 'jwt-decode';

const Dashboard = () => {
  const [user, setUser] = useState(null);
  const navigate = useNavigate();

  // Kiểm tra user từ localStorage
  useEffect(() => {
    const userData = localStorage.getItem('user');
    if (userData) {
      setUser(JSON.parse(userData));
    } else {
      navigate('/login');
    }
  }, [navigate]);

  // 🧠 Kiểm tra token mỗi 10s, nếu sắp hết hạn thì gọi refreshToken
useEffect(() => {
  const interval = setInterval(async () => {
    const token = localStorage.getItem('token');
    const refresh = localStorage.getItem('refreshToken');

    if (token) {
      try {
        const { exp } = jwtDecode(token);
        const now = Math.floor(Date.now() / 1000);

        if (exp - now <= 5) {
          // Nếu token sắp hết hạn hoặc đã hết hạn
          if (!refresh) {
            console.log('Không có refresh token → logout');
            logoutUser();
            return;
          }

          console.log('Token sắp hết hạn → gọi refreshToken()');

          try {
            const response = await refreshToken(refresh);
            localStorage.setItem('token', response.token);
            localStorage.setItem('refreshToken', response.refreshToken || refresh); // backup
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
  }, 10000); // mỗi 10s

  return () => clearInterval(interval);
}, []);


  const logoutUser = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    alert('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
    navigate('/login');
  };

  return (
    <div style={{ display: 'flex', height: '100vh' }}>
      {/* Sidebar */}
      <div style={{ width: '200px', background: '#333', color: '#fff', padding: '20px' }}>
        <h2>My App</h2>
        <ul style={{ listStyle: 'none', padding: 0 }}>
          <li>🏠 Dashboard</li>
          <li>📁 Projects</li>
          <li>👤 Profile</li>
          <li onClick={logoutUser} style={{ cursor: 'pointer', marginTop: '20px', color: 'red' }}>
            🚪 Logout
          </li>
        </ul>
      </div>

      {/* Main content */}
      <div style={{ flex: 1, padding: '20px' }}>
        <h1>Welcome{user ? `, ${user.name || user.email}` : ''}!</h1>

        {/* Cards */}
        <div style={{ display: 'flex', gap: '20px', marginTop: '20px' }}>
          <div style={{ flex: 1, background: '#f2f2f2', padding: '20px', borderRadius: '8px' }}>
            <h3>📊 Total Tasks</h3>
            <p>24</p>
          </div>
          <div style={{ flex: 1, background: '#f2f2f2', padding: '20px', borderRadius: '8px' }}>
            <h3>✅ Completed</h3>
            <p>16</p>
          </div>
          <div style={{ flex: 1, background: '#f2f2f2', padding: '20px', borderRadius: '8px' }}>
            <h3>⏳ In Progress</h3>
            <p>5</p>
          </div>
        </div>

        {/* Chart Placeholder */}
        <div style={{ marginTop: '40px', background: '#e0e0e0', height: '300px', borderRadius: '8px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <p>📈 Chart Placeholder</p>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
