import React, { useEffect, useState } from 'react';
import './alluserdetail.css';
import { getUserById, updateUser, deactivateUser} from '../../services/userService';
import { getAllProjects } from '../../services/projectService';
import { useNavigate, useParams } from 'react-router-dom';

export default function UserDetail() {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isSuspended, setIsSuspended] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [user, setUser] = useState({});
  const [projects, setProjects] = useState([]);
  const [currentProjectPage, setCurrentProjectPage] = useState(1);
  const projectsPerPage = 5; // Số dự án mỗi trang
  const navigate = useNavigate();
  const { id } = useParams();

  const openModal = () => setIsModalOpen(true);
  const closeModal = () => setIsModalOpen(false);

  const handleSuspend = () => {
    if (window.confirm('Bạn có chắc muốn tạm ngưng tài khoản này?')) {
      setIsSuspended(true);
      setIsEditing(true);
      setTimeout(() => setIsEditing(false), 1500);
    }
  };

  const handleSave = async () => {
    setIsSaving(true);
    try {
      await updateUser(id, { full_name: user.full_name, major: user.major });
      alert('Thông tin đã được cập nhật!');
      setIsModalOpen(false);
    } catch (error) {
      console.error('Error updating user:', error);
      alert('Cập nhật thất bại!');
    } finally {
      setIsSaving(false);
    }
  };

  const handleNextProjectPage = () => {
    if (currentProjectPage < Math.ceil(projects.length / projectsPerPage)) {
      setCurrentProjectPage(currentProjectPage + 1);
    }
  };

  const handlePreviousProjectPage = () => {
    if (currentProjectPage > 1) {
      setCurrentProjectPage(currentProjectPage - 1);
    }
  };

  // Tính toán các dự án hiển thị
  const indexOfLastProject = currentProjectPage * projectsPerPage;
  const indexOfFirstProject = indexOfLastProject - projectsPerPage;
  const currentProjects = projects.slice(indexOfFirstProject, indexOfLastProject);

  useEffect(() => {
    const fetchUserData = async () => {
      try {
        const data = await getUserById(id);
        setUser(data.user);
        console.log('Fetched user:', data.user);
      } catch (error) {
        console.error('Error fetching user:', error);
      }
    };
    fetchUserData();  
    const fetchProjects = async () => {
      try {
        const data = await getAllProjects({page: 1, limit: 100});
        setProjects(data.projects);
        console.log('Fetched projects:', data.projects);
      } catch (error) {
        console.error('Error fetching projects:', error);
      }
    };
    fetchProjects();
  }, [id]);



  return (
    <div>

      <main className="main-content-admin-user-detail">
        {/* Thông tin người dùng */}
        <div className="profile-section">
          <div className="profile-header">
            <img
              src={user.avatar || 'https://via.placeholder.com/150'}
              alt="Avatar"
              className="profile-avatar"
            />
            <div className="profile-info">
              <h1>{user.full_name || 'Tên người dùng'}</h1>
              <p>{user.email || 'Email người dùng'}</p>
              <span
                className={`status-badge ${
                  user.is_active ? 'status-active' : 'status-inactive'
                }`}
              >
                {user.is_active ? 'Hoạt động' : 'Không hoạt động'}
              </span>
            </div>
          </div>
          <div className="profile-details">
            <p>
              <strong>Vai trò:</strong> {user.role || 'Chưa cập nhật'}
            </p>
            <p>
              <strong>Chuyên ngành:</strong> {user.major || 'Chưa cập nhật'}
            </p>
            <p>
              <strong>Ngày tham gia:</strong>{' '}
              {new Date(user.created_at).toLocaleDateString() || 'Chưa cập nhật'}
            </p>
            <p>
              <strong>Tên đăng nhập:</strong> {user.username || 'Chưa cập nhật'}
            </p>
          </div>
          <div className="action-buttons">
            <button className="edit-btn" onClick={openModal}>
              Sửa thông tin
            </button>
            <button className="suspend-btn" onClick={handleSuspend}>
              Tạm ngưng tài khoản
            </button>

          </div>
        </div>

        {/* Danh sách dự án */}
        <div className="section-card">
          <div className="section-header">
            <h2 className="section-title">Dự án được giao</h2>
          </div>
          <div className="table-container">
            <table>
              <thead>
                <tr>
                  <th>Tên dự án</th>
                  <th>Tiến độ</th>
                  <th>Hạn chót</th>
                  <th>Trạng thái</th>
                </tr>
              </thead>
              <tbody>
                {currentProjects.map((project, index) => (
                  <tr key={index}>
                    <td>{project.name}</td>
                    <td>
                      <div className="progress-bar">
                        <div
                          className="progress-fill"
                          style={{ width: `${project.progress || 0}%` }}
                        />
                      </div>
                    </td>
                    <td>
                      {new Date(project.end_date).toLocaleDateString() ||
                        'Chưa cập nhật'}
                    </td>
                    <td>
                      <span
                        className={`status-badge status-${
                          project.status || 'unknown'
                        }`}
                      >
                        {project.status || 'Chưa cập nhật'}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <div className="pagination">
            <button
              className="pagination-btn"
              onClick={handlePreviousProjectPage}
              disabled={currentProjectPage === 1}
            >
              Trang trước
            </button>
            <span>
              Trang {currentProjectPage} / {Math.ceil(projects.length / projectsPerPage)}
            </span>
            <button
              className="pagination-btn"
              onClick={handleNextProjectPage}
              disabled={currentProjectPage === Math.ceil(projects.length / projectsPerPage)}
            >
              Trang sau
            </button>
          </div>
        </div>
        <div className="section-card">
          <div className="section-header">
            <h2 className="section-title">Hoạt động gần đây</h2>
          </div>
          <ul className="activity-list">
            <li className="activity-item">
              <div className="activity-icon">📝</div>
              <div className="activity-content">
                <div className="activity-title">Cập nhật tiến độ dự án API Integration</div>
                <div className="activity-meta">07/08/2025 14:30</div>
              </div>
            </li>
            <li className="activity-item">
              <div className="activity-icon">✅</div>
              <div className="activity-content">
                <div className="activity-title">Hoàn thành task "Thiết kế API"</div>
                <div className="activity-meta">06/08/2025 09:15</div>
              </div>
            </li>
            <li className="activity-item">
              <div className="activity-icon">📩</div>
              <div className="activity-content">
                <div className="activity-title">Gửi báo cáo tiến độ dự án Website Redesign</div>
                <div className="activity-meta">05/08/2025 16:45</div>
              </div>
            </li>
          </ul>
        </div>

        {isModalOpen && (
          <div className="modal">
            <div className="modal-content">
              <span className="close-btn" onClick={closeModal}>&times;</span>
              <h2 className="section-title">Sửa Thông Tin Cá Nhân</h2>
              <form
                className="modal-form"
                onSubmit={(e) => {
                  e.preventDefault();
                  handleSave();
                }}
              >
                <label>Tên</label>
                <input
                  type="text"
                  value={user.full_name || ''}
                  onChange={(e) => setUser({ ...user, full_name: e.target.value })}
                  required
                />
                <label>Chuyên ngành</label>
                <input
                  type="text"
                  value={user.major || ''}
                  onChange={(e) => setUser({ ...user, major: e.target.value })}
                  required
                />
                <button className="action-btn" type="submit">
                  {isSaving ? 'Đang lưu...' : 'Lưu'}
                </button>
              </form>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
