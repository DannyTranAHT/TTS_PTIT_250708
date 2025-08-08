import React, { useEffect, useState } from 'react';
import './ProjectManagement.css';
import { getAllProjects } from '../../services/projectService';
import { useNavigate } from 'react-router-dom';

const ProjectManagement = () => {
  const [selectedProject, setSelectedProject] = useState([]);
  const [modalOpen, setModalOpen] = useState(false);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [managerFilter, setManagerFilter] = useState('');
  const [sortOrder, setSortOrder] = useState('asc');
  const [projects, setProjects] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const projectsPerPage = 10;
  const navigate = useNavigate();

  useEffect(() => {
    const fetchData = async () => {
      try {
        const data = await getAllProjects({ page: 1, limit: 100 });
        setSelectedProject(data.projects);
        setProjects(data.projects);
        console.log('Fetched projects:', data.projects);
      } catch (error) {
        console.error('Error fetching projects:', error);
      }
    };
    fetchData();
  }, []);

  const filteredProjects = projects
    .filter(p =>
      p.name.toLowerCase().includes(search.toLowerCase()) &&
      (!statusFilter || p.status === statusFilter) &&
      (!managerFilter || p.manager.toLowerCase().includes(managerFilter.toLowerCase()))
    );

  const handleSort = (column) => {
    const isAsc = sortOrder === 'asc';
    const sorted = [...filteredProjects].sort((a, b) => {
      const valA = a[column] || ''; // Giá trị mặc định nếu undefined
      const valB = b[column] || ''; // Giá trị mặc định nếu undefined

      if (column === 'progress') return isAsc ? a.progress - b.progress : b.progress - a.progress;
      if (column === 'tasks') return isAsc ? a.tasks - b.tasks : b.tasks - a.tasks;
      if (column === 'budget') return isAsc ? a.budget - b.budget : b.budget - a.budget;

      // Sử dụng localeCompare cho các giá trị chuỗi
      return isAsc
        ? valA.toString().localeCompare(valB.toString())
        : valB.toString().localeCompare(valA.toString());
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

  // Pagination logic
  const indexOfLastProject = currentPage * projectsPerPage;
  const indexOfFirstProject = indexOfLastProject - projectsPerPage;
  const currentProjects = filteredProjects.slice(indexOfFirstProject, indexOfLastProject);

  const totalPages = Math.ceil(filteredProjects.length / projectsPerPage);

  const handlePageChange = (pageNumber) => {
    setCurrentPage(pageNumber);
  };

  return (
    <div>
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
                  <th onClick={() => handleSort('start_date')}>Ngày bắt đầu</th>
                  <th onClick={() => handleSort('end_date')}>Hạn chót</th>
                  <th onClick={() => handleSort('budget')}>Ngân sách (VNĐ)</th>
                  <th>Trạng thái</th>
                  <th>Hành động</th>
                </tr>
              </thead>
              <tbody>
                {currentProjects.map((p, index) => (
                  <tr key={index}>
                    <td>{p.name}</td>
                    <td>{p.owner_id?.full_name || 'N/A'}</td>
                    <td>
                      <div className="progress-bar">
                        <div className="progress-fill" style={{ width: `${p.progress}%` }}></div>
                      </div>
                    </td>
                    <td>{new Date(p.start_date).toLocaleDateString()}</td>
                    <td>{new Date(p.end_date).toLocaleDateString()}</td>
                    <td>{p.budget.toLocaleString()}</td>
                    <td>
                      <span className={`status-badge status-${p.status}`}>
                        {p.status === 'progress' ? 'Đang thực hiện' : p.status === 'overdue' ? 'Quá hạn' : 'Hoàn thành'}
                      </span>
                    </td>
                    <td className="action-buttons">
                      <button className="view-btn" onClick={() => navigate(`/admin/projects/${p._id}`)}>Xem</button>
                      {/* <button className="edit-btn" onClick={() => { setModalOpen(true); alert(`Chỉnh sửa dự án: ${p.name}`); }}>Sửa</button>
                      <button className="delete-btn" onClick={() => handleDelete(index)}>Xóa</button> */}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="pagination">
            {Array.from({ length: totalPages }, (_, i) => (
              <button
                key={i}
                className={`page-btn ${currentPage === i + 1 ? 'active' : ''}`}
                onClick={() => handlePageChange(i + 1)}
              >
                {i + 1}
              </button>
            ))}
          </div>
        </div>
      </main>
    </div>
  );
};

export default ProjectManagement;
