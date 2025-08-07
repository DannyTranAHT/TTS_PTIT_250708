import React, { useState } from 'react';
import './ProjectManagement.css';

const ProjectManagement = () => {
  const [modalOpen, setModalOpen] = useState(false);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [managerFilter, setManagerFilter] = useState('');
  const [sortOrder, setSortOrder] = useState('asc');
  const [projects, setProjects] = useState([
    {
      name: 'API Integration',
      manager: 'Trần Thị B',
      progress: 40,
      deadline: '05/07/2025',
      tasks: 15,
      budget: 50000000,
      status: 'overdue'
    },
    {
      name: 'Marketing Campaign',
      manager: 'Lê Văn C',
      progress: 20,
      deadline: '15/07/2025',
      tasks: 8,
      budget: 30000000,
      status: 'progress'
    },
    {
      name: 'Website Redesign',
      manager: 'Nguyễn Thị D',
      progress: 80,
      deadline: '20/08/2025',
      tasks: 12,
      budget: 75000000,
      status: 'progress'
    },
    {
      name: 'Mobile App Dev',
      manager: 'Phạm Văn E',
      progress: 95,
      deadline: '30/06/2025',
      tasks: 20,
      budget: 100000000,
      status: 'completed'
    },
    {
      name: 'Data Migration',
      manager: 'Hoàng Thị F',
      progress: 60,
      deadline: '10/08/2025',
      tasks: 10,
      budget: 45000000,
      status: 'progress'
    }
  ]);

  const filteredProjects = projects
    .filter(p =>
      p.name.toLowerCase().includes(search.toLowerCase()) &&
      (!statusFilter || p.status === statusFilter) &&
      (!managerFilter || p.manager.toLowerCase().includes(managerFilter.toLowerCase()))
    );

  const handleSort = (column) => {
    const isAsc = sortOrder === 'asc';
    const sorted = [...filteredProjects].sort((a, b) => {
      if (column === 'progress') return isAsc ? a.progress - b.progress : b.progress - a.progress;
      if (column === 'tasks') return isAsc ? a.tasks - b.tasks : b.tasks - a.tasks;
      if (column === 'budget') return isAsc ? a.budget - b.budget : b.budget - a.budget;
      return isAsc
        ? a[column].localeCompare(b[column])
        : b[column].localeCompare(a[column]);
    });
    setProjects(sorted);
    setSortOrder(isAsc ? 'desc' : 'asc');
  };

  const handleDelete = (index) => {
    if (window.confirm('Bạn có chắc muốn xóa dự án này?')) {
      const updated = [...projects];
      updated.splice(index, 1);
      setProjects(updated);
    }
  };

  return (
    <div>
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
            <h2 className="section-title">Quản lý Dự án</h2>
            <div className="filter-bar">
              <input
                type="text"
                className="search-input"
                placeholder="Tìm kiếm dự án..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
              />
              <select className="filter-select" onChange={(e) => setStatusFilter(e.target.value)}>
                <option value="">Tất cả trạng thái</option>
                <option value="progress">Đang thực hiện</option>
                <option value="overdue">Quá hạn</option>
                <option value="completed">Hoàn thành</option>
              </select>
              <select className="filter-select" onChange={(e) => setManagerFilter(e.target.value)}>
                <option value="">Tất cả người phụ trách</option>
                <option value="Trần Thị B">Trần Thị B</option>
                <option value="Lê Văn C">Lê Văn C</option>
                <option value="Nguyễn Thị D">Nguyễn Thị D</option>
              </select>
              <button className="action-btn" onClick={() => setModalOpen(true)}>Thêm dự án</button>
            </div>
          </div>
          <div className="table-container">
            <table>
              <thead>
                <tr>
                  <th onClick={() => handleSort('name')}>Tên dự án</th>
                  <th onClick={() => handleSort('manager')}>Người phụ trách</th>
                  <th onClick={() => handleSort('progress')}>Tiến độ</th>
                  <th onClick={() => handleSort('deadline')}>Hạn chót</th>
                  <th onClick={() => handleSort('tasks')}>Số task</th>
                  <th onClick={() => handleSort('budget')}>Ngân sách (VNĐ)</th>
                  <th>Trạng thái</th>
                  <th>Hành động</th>
                </tr>
              </thead>
              <tbody>
                {filteredProjects.map((p, index) => (
                  <tr key={index}>
                    <td>{p.name}</td>
                    <td>{p.manager}</td>
                    <td>
                      <div className="progress-bar">
                        <div className="progress-fill" style={{ width: `${p.progress}%` }}></div>
                      </div>
                    </td>
                    <td>{p.deadline}</td>
                    <td>{p.tasks}</td>
                    <td>{p.budget.toLocaleString()}</td>
                    <td>
                      <span className={`status-badge status-${p.status}`}>
                        {p.status === 'progress' ? 'Đang thực hiện' : p.status === 'overdue' ? 'Quá hạn' : 'Hoàn thành'}
                      </span>
                    </td>
                    <td className="action-buttons">
                      <button className="view-btn" onClick={() => alert(`Xem chi tiết dự án: ${p.name}`)}>Xem</button>
                      <button className="edit-btn" onClick={() => { setModalOpen(true); alert(`Chỉnh sửa dự án: ${p.name}`); }}>Sửa</button>
                      <button className="delete-btn" onClick={() => handleDelete(index)}>Xóa</button>
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

        {modalOpen && (
          <div className="modal" onClick={() => setModalOpen(false)}>
            <div className="modal-content" onClick={(e) => e.stopPropagation()}>
              <span className="close-btn" onClick={() => setModalOpen(false)}>&times;</span>
              <h2 className="section-title">Thêm Dự án</h2>
              <div className="modal-form">
                <label>Tên dự án</label>
                <input type="text" placeholder="Nhập tên dự án" />
                <label>Người phụ trách</label>
                <select>
                  <option value="tranb">Trần Thị B</option>
                  <option value="levanc">Lê Văn C</option>
                  <option value="nguyend">Nguyễn Thị D</option>
                </select>
                <label>Hạn chót</label>
                <input type="date" />
                <label>Ngân sách (VNĐ)</label>
                <input type="number" placeholder="Nhập ngân sách" />
                <label>Trạng thái</label>
                <select>
                  <option value="progress">Đang thực hiện</option>
                  <option value="overdue">Quá hạn</option>
                  <option value="completed">Hoàn thành</option>
                </select>
                <button className="action-btn">Lưu</button>
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  );
};

export default ProjectManagement;
