import React, { useState } from 'react';
import './AllUsers.css';

const sampleUsers = [
  {
    name: 'Trần Thị B',
    email: 'tranb@example.com',
    role: 'Project Manager',
    joinedDate: '01/07/2025',
    projects: 3,
    status: 'active',
  },
  {
    name: 'Lê Văn C',
    email: 'levanc@example.com',
    role: 'Employee',
    joinedDate: '28/06/2025',
    projects: 2,
    status: 'inactive',
  },
  {
    name: 'Nguyễn Thị D',
    email: 'nguyend@example.com',
    role: 'Admin',
    joinedDate: '15/05/2025',
    projects: 5,
    status: 'active',
  },
  {
    name: 'Phạm Văn E',
    email: 'phame@example.com',
    role: 'Employee',
    joinedDate: '10/06/2025',
    projects: 1,
    status: 'suspended',
  },
  {
    name: 'Hoàng Thị F',
    email: 'hoangf@example.com',
    role: 'Project Manager',
    joinedDate: '03/07/2025',
    projects: 4,
    status: 'active',
  },
  // Thêm dữ liệu mẫu
  {
    name: 'Vũ Minh G',
    email: 'vug@example.com',
    role: 'Employee',
    joinedDate: '05/07/2025',
    projects: 2,
    status: 'active',
  },
  {
    name: 'Đặng Quang H',
    email: 'dangh@example.com',
    role: 'Admin',
    joinedDate: '01/06/2025',
    projects: 6,
    status: 'suspended',
  },
];

function AllUsers() {
  const [users, setUsers] = useState(sampleUsers);
  const [searchTerm, setSearchTerm] = useState('');
  const [roleFilter, setRoleFilter] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [modalVisible, setModalVisible] = useState(false);
  const [sortColumn, setSortColumn] = useState(null);
  const [sortOrder, setSortOrder] = useState('asc');

  const handleSort = (column) => {
    const newOrder = sortOrder === 'asc' ? 'desc' : 'asc';
    setSortOrder(newOrder);
    setSortColumn(column);
    const sorted = [...users].sort((a, b) => {
      const valA = a[column];
      const valB = b[column];
      if (typeof valA === 'number') return newOrder === 'asc' ? valA - valB : valB - valA;
      return newOrder === 'asc' ? valA.localeCompare(valB) : valB.localeCompare(valA);
    });
    setUsers(sorted);
  };

  const filteredUsers = users.filter(user => {
    const matchSearch = user.name.toLowerCase().includes(searchTerm.toLowerCase()) || user.email.toLowerCase().includes(searchTerm.toLowerCase());
    const matchRole = !roleFilter || user.role.toLowerCase() === roleFilter;
    const matchStatus = !statusFilter || user.status === statusFilter;
    return matchSearch && matchRole && matchStatus;
  });

  return (
    <div className="user-management">
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
            <h2 className="section-title">Quản lý Người dùng</h2>
            <div className="filter-bar">
              <input
                type="text"
                className="search-input"
                placeholder="Tìm kiếm người dùng..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
              <select className="filter-select" onChange={(e) => setRoleFilter(e.target.value)}>
                <option value="">Tất cả vai trò</option>
                <option value="admin">Admin</option>
                <option value="project manager">Project Manager</option>
                <option value="employee">Employee</option>
              </select>
              <select className="filter-select" onChange={(e) => setStatusFilter(e.target.value)}>
                <option value="">Tất cả trạng thái</option>
                <option value="active">Hoạt động</option>
                <option value="inactive">Không hoạt động</option>
                <option value="suspended">Tạm ngưng</option>
              </select>
              <button className="action-btn" onClick={() => setModalVisible(true)}>Thêm người dùng</button>
            </div>
          </div>

          <div className="table-container">
            <table>
              <thead>
                <tr>
                  <th onClick={() => handleSort('name')}>Tên</th>
                  <th onClick={() => handleSort('email')}>Email</th>
                  <th onClick={() => handleSort('role')}>Vai trò</th>
                  <th onClick={() => handleSort('joinedDate')}>Ngày tham gia</th>
                  <th onClick={() => handleSort('projects')}>Số dự án</th>
                  <th onClick={() => handleSort('status')}>Trạng thái</th>
                  <th>Hành động</th>
                </tr>
              </thead>
              <tbody>
                {filteredUsers.map((user, index) => (
                  <tr key={index}>
                    <td>{user.name}</td>
                    <td>{user.email}</td>
                    <td>{user.role}</td>
                    <td>{user.joinedDate}</td>
                    <td>{user.projects}</td>
                    <td>
                      <span className={`status-badge status-${user.status}`}>
                        {
                          user.status === 'active' ? 'Hoạt động' :
                          user.status === 'inactive' ? 'Không hoạt động' :
                          'Tạm ngưng'
                        }
                      </span>
                    </td>
                    <td className="action-buttons">
                      <button className="view-btn" onClick={() => alert(`Xem chi tiết: ${user.name}`)}>Xem</button>
                      <button className="edit-btn" onClick={() => alert(`Chỉnh sửa: ${user.name}`)}>Sửa</button>
                      <button className="delete-btn" onClick={() => {
                        if (window.confirm('Bạn có chắc muốn xóa người dùng này?')) {
                          setUsers(users.filter((_, i) => i !== index));
                        }
                      }}>Xóa</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {modalVisible && (
          <div className="modal">
            <div className="modal-content">
              <span className="close-btn" onClick={() => setModalVisible(false)}>&times;</span>
              <h2 className="section-title">Thêm Người dùng</h2>
              <form className="modal-form" onSubmit={(e) => {
                e.preventDefault();
                setModalVisible(false);
              }}>
                <label>Tên</label>
                <input type="text" placeholder="Nhập tên người dùng" required />
                <label>Email</label>
                <input type="email" placeholder="Nhập email" required />
                <label>Vai trò</label>
                <select required>
                  <option value="admin">Admin</option>
                  <option value="project manager">Project Manager</option>
                  <option value="employee">Employee</option>
                </select>
                <label>Trạng thái</label>
                <select required>
                  <option value="active">Hoạt động</option>
                  <option value="inactive">Không hoạt động</option>
                  <option value="suspended">Tạm ngưng</option>
                </select>
                <button className="action-btn" type="submit">Lưu</button>
              </form>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}

export default AllUsers;
