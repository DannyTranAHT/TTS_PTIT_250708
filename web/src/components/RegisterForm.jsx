import { useState } from 'react';
import './RegisterForm.css';
import { registerUser } from '../services/authService';

export default function RegisterForm() {
  const [formData, setFormData] = useState({
    full_name: '',
    email: '',
    username: '',
    password: '',
    confirmPassword: '',
    role: '',
  });

  const [loading, setLoading] = useState(false);

  const handleChange = (e) =>
    setFormData({ ...formData, [e.target.name]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();
    const { full_name, email, username, password, confirmPassword, role } = formData;

    if (password !== confirmPassword) {
      alert('Mật khẩu và xác nhận mật khẩu không khớp!');
      return;
    }

    try {
      setLoading(true);
      await registerUser({ full_name, email, username, password, role });
      alert('Đăng ký thành công!');
      window.location.href = '/login';
    } catch (err) {
      alert(err.response?.data?.error || 'Đăng ký thất bại!');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="register-container">
      <div className="logo">
        <h1>🛠️ Project Hub</h1>
        <p>Quản lý dự án thông minh</p>
      </div>

      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label>Họ và tên</label>
          <input name="full_name" value={formData.full_name} onChange={handleChange} required />
        </div>

        <div className="form-group">
          <label>Email</label>
          <input name="email" type="email" value={formData.email} onChange={handleChange} required />
        </div>

        <div className="form-group">
          <label>Tên đăng nhập</label>
          <input name="username" value={formData.username} onChange={handleChange} required />
        </div>

        <div className="form-group">
          <label>Mật khẩu</label>
          <input name="password" type="password" value={formData.password} onChange={handleChange} required />
        </div>

        <div className="form-group">
          <label>Xác nhận mật khẩu</label>
          <input name="confirmPassword" type="password" value={formData.confirmPassword} onChange={handleChange} required />
        </div>

        <div className="role-selector">
          <label>Vai trò</label>
          <select name="role" value={formData.role} onChange={handleChange} required>
            <option value="">Chọn vai trò</option>
            <option value="Employee">Nhân viên</option>
            <option value="Project Manager">Quản lý dự án</option>
            <option value="Admin">Quản trị viên</option>
          </select>
        </div>

        <button className="register-btn" disabled={loading}>
          {loading ? 'Đang đăng ký...' : 'Đăng ký'}
        </button>
      </form>

      <div className="divider"><span>hoặc</span></div>

      <div className="login-link">
        <p>Đã có tài khoản? <a href="/login">Đăng nhập ngay</a></p>
      </div>
    </div>
  );
}
