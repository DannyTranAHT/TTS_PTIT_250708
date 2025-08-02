// src/pages/LandingPage.jsx
import { Link } from 'react-router-dom';
import '../styles/layout/LandingPage.css'; // Import your CSS styles

export default function LandingPage() {
  return (
    <div className="landing-container">
      <div className="welcome-box">
        <h1>🚀 Chào mừng bạn đến với <span>Project Hub</span></h1>
        <p>Giải pháp quản lý dự án thông minh, hiện đại và tiện lợi</p>

        <div className="btn-group">
          <Link to="/login" className="btn btn-login">Đăng nhập</Link>
          <Link to="/register" className="btn btn-register">Đăng ký</Link>
        </div>
      </div>
    </div>
  );
}
