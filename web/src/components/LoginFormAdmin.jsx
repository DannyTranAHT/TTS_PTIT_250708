import { useState } from 'react';
import './LoginFormAdmin.css';
import { loginUser, getProfile } from '../services/authService';
import { useNavigate } from 'react-router-dom';

export default function LoginFormAdmin() {
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

      const response = await loginUser({ email, password });
      localStorage.setItem('token', response.token);
      localStorage.setItem('refreshToken', response.refreshToken);

      const profileResponse = await getProfile();
      const user = profileResponse.user;

      if (user.role !== 'Admin') {
        alert('Tài khoản không có quyền truy cập trang quản trị.');
        return;
      }

      localStorage.setItem('user', JSON.stringify(user));
      alert('Đăng nhập admin thành công!');
      navigate('/admin/dashboard');
    } catch (err) {
      alert(err.response?.data?.message || 'Đăng nhập thất bại!');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="admin-login-container">
      <div className="admin-logo">
        <h1>🔐 Admin Portal</h1>
        <p>Chào mừng quay lại trang quản trị</p>
      </div>

      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label>Email quản trị</label>
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

        <button className="admin-login-btn" disabled={loading}>
          {loading ? 'Đang xác minh...' : 'Đăng nhập Admin'}
        </button>
      </form>
    </div>
  );
}
