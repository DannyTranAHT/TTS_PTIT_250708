import React, { useState } from 'react';
import '../../styles/forms/editprofile.css';
import { updateProfile } from '../../services/authService';
import { changePassword } from '../../services/userService';

const EditProfile = () => {
  const [user, setUser] = useState(JSON.parse(localStorage.getItem('user')) || {});
  const [fullName, setFullName] = useState(user.full_name || '');
  const [major, setMajor] = useState(user.major || '');
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [errors, setErrors] = useState({});
  const [savingProfile, setSavingProfile] = useState(false);
  const [changingPassword, setChangingPassword] = useState(false);

  const validateProfile = () => {
    let valid = true;
    const newErrors = {};

    if (!fullName.trim()) {
      newErrors.fullName = 'Vui lòng nhập họ và tên';
      valid = false;
    }

    if (major.length > 255) {
      newErrors.major = 'Chuyên ngành không được vượt quá 255 ký tự';
      valid = false;
    }

    setErrors(newErrors);
    return valid;
  };

  const validatePassword = () => {
    let valid = true;
    const newErrors = {};

    if (!currentPassword) {
      newErrors.currentPassword = 'Vui lòng nhập mật khẩu hiện tại';
      valid = false;
    }

    if (!newPassword || newPassword.length < 6) {
      newErrors.newPassword = 'Mật khẩu mới phải có ít nhất 6 ký tự';
      valid = false;
    }

    setErrors(newErrors);
    return valid;
  };

  const handleProfileSubmit = async () => {
    if (validateProfile()) {
      setSavingProfile(true);
      try {
        // Sử dụng service updateProfile
        const res = await updateProfile({ full_name: fullName, major });
        console.log('Profile updated:', res);
        // Cập nhật thông tin người dùng trong localStorage
        const updatedUser = { ...user, full_name: fullName, major };
        localStorage.setItem('user', JSON.stringify(updatedUser));
        alert('Thông tin cá nhân đã được cập nhật!');
        //về lại trang cá nhân
        window.location.href = '/profile';
      } catch (error) {
        console.error('Error updating profile:', error);
        alert(error?.response?.data?.message || 'Có lỗi xảy ra khi cập nhật thông tin');
      } finally {
        setSavingProfile(false);
      }
    }
  };

  const handlePasswordSubmit = async () => {
    if (validatePassword()) {
      setChangingPassword(true);
      try {
        // Sử dụng service changePassword
        await changePassword(user._id,{ current_password: currentPassword, new_password: newPassword });
        alert('Mật khẩu đã được thay đổi!');
      } catch (error) {
        console.error('Error changing password:', error);
        alert(error?.response?.data?.message || 'Có lỗi xảy ra khi đổi mật khẩu');
      } finally {
        setChangingPassword(false);
      }
    }
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
              <label className="form-label" htmlFor="major">Chuyên ngành</label>
              <input
                type="text"
                id="major"
                className="form-input"
                value={major}
                onChange={(e) => setMajor(e.target.value)}
                placeholder="Nhập chuyên ngành"
              />
              {errors.major && <span className="error-message">{errors.major}</span>}
            </div>
            <div className="form-actions">
              <button className="submit-btn" onClick={handleProfileSubmit} disabled={savingProfile}>
                {savingProfile ? 'Đang lưu...' : 'Lưu thông tin'}
              </button>
            </div>
          </div>
        </div>

        <div className="edit-section">
          <h1 className="edit-title">Đổi mật khẩu</h1>
          <div className="edit-form">
            <div className="form-group">
              <label className="form-label" htmlFor="currentPassword">Mật khẩu hiện tại</label>
              <input
                type="password"
                id="currentPassword"
                className="form-input"
                value={currentPassword}
                onChange={(e) => setCurrentPassword(e.target.value)}
                placeholder="Nhập mật khẩu hiện tại"
              />
              {errors.currentPassword && <span className="error-message">{errors.currentPassword}</span>}
            </div>
            <div className="form-group">
              <label className="form-label" htmlFor="newPassword">Mật khẩu mới</label>
              <input
                type="password"
                id="newPassword"
                className="form-input"
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)}
                placeholder="Nhập mật khẩu mới"
              />
              {errors.newPassword && <span className="error-message">{errors.newPassword}</span>}
            </div>
            <div className="form-actions">
              <button className="submit-btn" onClick={handlePasswordSubmit} disabled={changingPassword}>
                {changingPassword ? 'Đang đổi...' : 'Đổi mật khẩu'}
              </button>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
};

export default EditProfile;
