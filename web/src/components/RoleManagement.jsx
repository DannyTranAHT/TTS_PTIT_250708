import React, { useState } from 'react';
import './rolemanagement.css';

const rolesData = [
  {
    name: 'Admin',
    description: 'Quản trị toàn hệ thống',
    permissions: 'Quản lý người dùng, dự án, vai trò, thông báo, cài đặt hệ thống, báo cáo',
    users: 3
  },
  {
    name: 'Project Manager',
    description: 'Quản lý dự án và task',
    permissions: 'Tạo dự án, giao task, theo dõi tiến độ, cập nhật trạng thái',
    users: 5
  },
  {
    name: 'Employee',
    description: 'Thực hiện task được giao',
    permissions: 'Xem task, cập nhật tiến độ task, báo cáo công việc',
    users: 10
  },
  {
    name: 'Viewer',
    description: 'Chỉ xem thông tin',
    permissions: 'Xem dự án, xem báo cáo, xem thông tin người dùng',
    users: 2
  },
  {
    name: 'Finance',
    description: 'Quản lý tài chính dự án',
    permissions: 'Quản lý ngân sách, phê duyệt chi phí, báo cáo tài chính',
    users: 2
  }
];

export default function RoleManagement() {
  const [showModal, setShowModal] = useState(false);
  const [search, setSearch] = useState('');
  const [sortOrder, setSortOrder] = useState('asc');
  const [roles, setRoles] = useState(rolesData);

  const filteredRoles = roles.filter(role =>
    Object.values(role).some(val =>
      String(val).toLowerCase().includes(search.toLowerCase())
    )
  );

  const handleSort = (key) => {
    const sorted = [...roles].sort((a, b) => {
      if (key === 'users') {
        return sortOrder === 'asc' ? a.users - b.users : b.users - a.users;
      }
      return sortOrder === 'asc'
        ? a[key].localeCompare(b[key])
        : b[key].localeCompare(a[key]);
    });
    setRoles(sorted);
    setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc');
  };

  const handleDelete = (name) => {
    if (window.confirm('Bạn có chắc muốn xóa vai trò này?')) {
      setRoles(roles.filter(role => role.name !== name));
    }
  };

  return (
    <div className="role-page">
      <header className="header">
        <div className="header-content">
          <div className="logo">🛠️ Project Hub</div>
          <div className="user-info">
            <span>Chào mừng, <strong>Nguyễn Văn A</strong> (Admin)</span>
            <div className="user-avatar">NA</div>
          </div>
        </div>
      </header>

      <main className="main-content">
        <div className="section-card">
          <div className="section-header">
            <h2 className="section-title">Quản lý Vai trò</h2>
            <div className="filter-bar">
              <input
                type="text"
                className="search-input"
                placeholder="Tìm kiếm vai trò..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
              />
              <button className="action-btn" onClick={() => setShowModal(true)}>Thêm vai trò</button>
            </div>
          </div>

          <div className="table-container">
            <table>
              <thead>
                <tr>
                  <th onClick={() => handleSort('name')}>Tên vai trò</th>
                  <th onClick={() => handleSort('description')}>Mô tả</th>
                  <th>Quyền hạn</th>
                  <th onClick={() => handleSort('users')}>Số người dùng</th>
                  <th>Hành động</th>
                </tr>
              </thead>
              <tbody>
                {filteredRoles.map((role, idx) => (
                  <tr key={idx}>
                    <td>{role.name}</td>
                    <td>{role.description}</td>
                    <td className="permissions">{role.permissions}</td>
                    <td>{role.users}</td>
                    <td className="action-buttons">
                      <button className="view-btn" onClick={() => alert(`Xem chi tiết vai trò: ${role.name}`)}>Xem</button>
                      <button className="edit-btn" onClick={() => { setShowModal(true); alert(`Chỉnh sửa vai trò: ${role.name}`); }}>Sửa</button>
                      <button className="delete-btn" onClick={() => handleDelete(role.name)}>Xóa</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="pagination">
            <button className="page-btn active">1</button>
            <button className="page-btn">2</button>
            <button className="page-btn">3</button>
          </div>
        </div>

        {showModal && (
          <div className="modal">
            <div className="modal-content">
              <span className="close-btn" onClick={() => setShowModal(false)}>&times;</span>
              <h2 className="section-title">Thêm Vai trò</h2>
              <div className="modal-form">
                <label>Tên vai trò</label>
                <input type="text" placeholder="Nhập tên vai trò" />
                <label>Mô tả</label>
                <input type="text" placeholder="Nhập mô tả" />
                <label>Quyền hạn</label>
                <textarea placeholder="Nhập quyền hạn"></textarea>
                <button className="action-btn">Lưu</button>
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
