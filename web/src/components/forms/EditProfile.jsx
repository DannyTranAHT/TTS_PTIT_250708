import React, { useState } from 'react';
import '../../styles/forms/editprofile.css';

const EditProfile = () => {
  const [fullName, setFullName] = useState('Nguyễn Văn A');
  const [email, setEmail] = useState('nguyenvana@example.com');
  const [password, setPassword] = useState('');
  const [avatar, setAvatar] = useState('');
  const [errors, setErrors] = useState({});
  const [saving, setSaving] = useState(false);
  const [cancelling, setCancelling] = useState(false);

  const initials = fullName
    .split(' ')
    .map((w) => w[0])
    .join('')
    .slice(0, 2)
    .toUpperCase();

  const handleAvatarChange = (e) => {
    const file = e.target.files[0];
    if (file && file.type.startsWith('image/')) {
      const reader = new FileReader();
      reader.onload = (e) => {
        setAvatar(e.target.result);
      };
      reader.readAsDataURL(file);
      setErrors((prev) => ({ ...prev, avatar: '' }));
    } else {
      setErrors((prev) => ({ ...prev, avatar: 'Vui lòng chọn một file ảnh hợp lệ' }));
    }
  };

  const validate = () => {
    let valid = true;
    const newErrors = {};

    if (!fullName.trim()) {
      newErrors.fullName = 'Vui lòng nhập họ và tên';
      valid = false;
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      newErrors.email = 'Vui lòng nhập email hợp lệ';
      valid = false;
    }

    if (password && password.length < 6) {
      newErrors.password = 'Mật khẩu phải có ít nhất 6 ký tự';
      valid = false;
    }

    setErrors(newErrors);
    return valid;
  };

  const handleSubmit = () => {
    if (validate()) {
      setSaving(true);
      setTimeout(() => {
        setSaving(false);
        alert('Thông tin đã được lưu!');
      }, 1500);
    }
  };

  const handleCancel = () => {
    setCancelling(true);
    setTimeout(() => {
      window.location.href = 'profile.html';
    }, 1000);
  };

  return (
    <div className="edit-profile-page">
      <main className="main-content">
        <div className="edit-section">
          <h1 className="edit-title">Chỉnh sửa thông tin cá nhân</h1>
          <div className="edit-form">
            <div className="form-group">
              <label className="form-label" htmlFor="fullName">Họ và tên</label>
              <input
                type="text"
                id="fullName"
                className="form-input"
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
                placeholder="Nhập họ và tên"
              />
              {errors.fullName && <span className="error-message">{errors.fullName}</span>}
            </div>
            <div className="form-group">
              <label className="form-label" htmlFor="email">Email</label>
              <input
                type="email"
                id="email"
                className="form-input"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="Nhập email"
              />
              {errors.email && <span className="error-message">{errors.email}</span>}
            </div>
            <div className="form-group">
              <label className="form-label" htmlFor="password">Mật khẩu mới</label>
              <input
                type="password"
                id="password"
                className="form-input"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Nhập mật khẩu mới"
              />
              {errors.password && <span className="error-message">{errors.password}</span>}
            </div>
            <div className="form-group">
              <label className="form-label">Avatar</label>
              <div className="avatar-section">
                <div
                  className="avatar-preview"
                  style={{
                    background: avatar
                      ? `url(${avatar}) center/cover`
                      : 'linear-gradient(135deg, #4CAF50, #45a049)',
                  }}
                >
                  {!avatar && initials}
                </div>
                <div className="avatar-upload">
                  <label className="avatar-label" htmlFor="avatar">Chọn ảnh mới</label>
                  <input type="file" id="avatar" className="avatar-input" accept="image/*" onChange={handleAvatarChange} />
                  {errors.avatar && <span className="error-message">{errors.avatar}</span>}
                </div>
              </div>
            </div>
            <div className="form-actions">
              <button className="submit-btn" onClick={handleSubmit} disabled={saving}>
                {saving ? 'Đang lưu...' : 'Lưu thay đổi'}
              </button>
              <button className="cancel-btn" onClick={handleCancel} disabled={cancelling}>
                {cancelling ? 'Đang hủy...' : 'Hủy'}
              </button>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
};

export default EditProfile;
