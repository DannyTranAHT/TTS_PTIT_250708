import { useState } from 'react';
import './LoginForm.css';
import { loginUser, getProfile } from '../services/authService'; // 👉 thêm getProfile
import { Link, useNavigate } from 'react-router-dom';
import { jwtDecode } from 'jwt-decode';

export default function LoginForm() {
  const [formData, setFormData] = useState({ email: '', password: '' });
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleChange = (e) =>
    setFormData({ ...formData, [e.target.name]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      setLoading(true);
      const { email, password } = formData;

      // 🔐 Gọi API đăng nhập để lấy token
      const response = await loginUser({ email, password });

      // ✅ Lưu token và refreshToken vào localStorage
      localStorage.setItem('token', response.token);
      localStorage.setItem('refreshToken', response.refreshToken);

      // 📥 Gọi API getProfile để lấy thông tin người dùng
      const profileResponse = await getProfile();

      // ✅ Lưu thông tin user vào localStorage
      localStorage.setItem('user', JSON.stringify(profileResponse.user));

      alert('Đăng nhập thành công!');
      navigate('/dashboard');
    } catch (err) {
      alert(err.response?.data?.message || 'Đăng nhập thất bại!');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-container">
      <div className="logo">
        <h1>🛠️ Project Hub</h1>
        <p>Quản lý dự án thông minh</p>
      </div>

      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label>Email</label>
          <input
            type="email"
            name="email"
            value={formData.email}
            onChange={handleChange}
            required
          />
        </div>

        <div className="form-group">
          <label>Mật khẩu</label>
          <input
            type="password"
            name="password"
            value={formData.password}
            onChange={handleChange}
            required
          />
        </div>

        <button className="login-btn" disabled={loading}>
          {loading ? 'Đang đăng nhập...' : 'Đăng nhập'}
        </button>

        <div className="forgot-password">
          <Link to="/forgot-password">Quên mật khẩu?</Link>
        </div>
      </form>

      <div className="divider"><span>hoặc</span></div>

      <div className="register-link">
        <p>Chưa có tài khoản? <a href="/register">Đăng ký ngay</a></p>
      </div>
    </div>
  );
}
