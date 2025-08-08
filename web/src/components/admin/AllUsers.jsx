import React, { useEffect, useState } from 'react';
import './AllUsers.css';
import { getAllUsers, getUserById,updateUser,deactivateUser,activateUser } from '../../services/userService';
import { useNavigate } from 'react-router-dom';

function AllUsers() {
  const [users, setUsers] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [roleFilter, setRoleFilter] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [modalVisible, setModalVisible] = useState(false);
  const [sortColumn, setSortColumn] = useState(null);
  const [sortOrder, setSortOrder] = useState('asc');
  const [selectedUser, setSelectedUser] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(0);
  const navigate = useNavigate();

  const handleSort = (column) => {
    const newOrder = sortOrder === 'asc' ? 'desc' : 'asc';
    setSortOrder(newOrder);
    setSortColumn(column);

    const sorted = [...users].sort((a, b) => {
      const valA = a[column] || ''; // Giá trị mặc định nếu undefined
      const valB = b[column] || ''; // Giá trị mặc định nếu undefined

      // Xử lý giá trị boolean
      if (typeof valA === 'boolean' && typeof valB === 'boolean') {
        return newOrder === 'asc' ? valA - valB : valB - valA;
      }

      // Xử lý giá trị số
      if (typeof valA === 'number' && typeof valB === 'number') {
        return newOrder === 'asc' ? valA - valB : valB - valA;
      }

      // Xử lý giá trị chuỗi
      if (typeof valA === 'string' && typeof valB === 'string') {
        return newOrder === 'asc' ? valA.localeCompare(valB) : valB.localeCompare(valA);
      }

      // Giá trị mặc định nếu không xác định được kiểu
      return 0;
    });

    setUsers(sorted);
  };

  const filteredUsers = users.filter(user => {
    const matchSearch = user.full_name.toLowerCase().includes(searchTerm.toLowerCase()) || user.email.toLowerCase().includes(searchTerm.toLowerCase());
    const matchRole = !roleFilter || user.role.toLowerCase() === roleFilter;
    const matchStatus = !statusFilter || (statusFilter === 'active' ? user.is_active : !user.is_active);
    return matchSearch && matchRole && matchStatus;
  });
  const handlePreviousPage = () => {
    if (currentPage > 1) {
      setCurrentPage(currentPage - 1);
    }
  };

  const handleNextPage = () => {
    if (currentPage < totalPages) {
      setCurrentPage(currentPage + 1);
    }
  };

  useEffect(() => {
    const fetchData = async () => {
      const data = await getAllUsers({ page: currentPage, limit: 10 }); // Lấy 10 người dùng mỗi trang
      setUsers(data.users);
      setTotalPages(data.totalPages); // Tổng số trang
    };
    fetchData();
  }, [currentPage]);

  return (
    <div className="user-management">
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
                  <th onClick={() => handleSort('full_name')}>Tên</th>
                  <th onClick={() => handleSort('email')}>Email</th>
                  <th onClick={() => handleSort('role')}>Vai trò</th>
                  <th onClick={() => handleSort('created_at')}>Ngày tham gia</th>
                  <th onClick={() => handleSort('is_active')}>Trạng thái</th>
                  <th>Hành động</th>
                </tr>
              </thead>
              <tbody>
                {filteredUsers.map((user, index) => (
                  <tr key={index}>
                    <td>{user.full_name}</td>
                    <td>{user.email}</td>
                    <td>{user.role}</td>
                    <td>{new Date(user.created_at).toLocaleDateString()}</td>
                    <td>
                      <span className={`status-badge status-${user.is_active}`}>
                        {user.is_active ? 'Hoạt động' : 'Không hoạt động'}
                      </span>
                    </td>
                    <td className="action-buttons">
                      <button className="view-btn" onClick={() => navigate(`/admin/users/${user._id}`)}>Xem</button>
                      {/* <button className="edit-btn" onClick={() => alert(`Chỉnh sửa: ${user.full_name}`)}>Sửa</button>
                      <button className="delete-btn" onClick={() => {
                        if (window.confirm('Bạn có chắc muốn xóa người dùng này?')) {
                          setUsers(users.filter((_, i) => i !== index));
                        }
                      }}>Xóa</button> */}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="pagination">
            <button
              className="pagination-btn"
              onClick={handlePreviousPage}
              disabled={currentPage === 1}
            >
              Trang trước
            </button>
            <span>Trang {currentPage} / {totalPages}</span>
            <button
              className="pagination-btn"
              onClick={handleNextPage}
              disabled={currentPage === totalPages}
            >
              Trang sau
            </button>
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
