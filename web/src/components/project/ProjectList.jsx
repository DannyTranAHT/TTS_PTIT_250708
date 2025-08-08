import React, { useState, useEffect  } from 'react';
import { useNavigate } from 'react-router-dom';
import '../../styles/project/ProjectList.css';
import { getAllProjects } from '../../services/projectService';

const ProjectList = () => {
  const user = JSON.parse(localStorage.getItem('user'));
  const [projects, setProjects] = useState([]);
  const [filters, setFilters] = useState({
    status: '',
    sort: 'newest',
    member: '',
    search: '',
  });

  useEffect(() => {
    const fetchProjects = async () => {
      try {
        const res = await getAllProjects({page: 1, limit: 100});
        const formatted = res.projects.map(p => ({
          id: p._id,
          title: p.name,
          description: p.description,
          icon: "📁", // có thể thêm icon động sau
          status: formatStatus(p.status),
          progress: p.progress,
          members: p.members.map(m => m.full_name || m.username),
          totalTasks: 0, // cần cập nhật từ task API nếu có
          completedTasks: 0, // cần cập nhật từ task API nếu có
          dueDate: p.end_date,
          createdDate: p.created_at
        }));
        setProjects(formatted);
      } catch (error) {
        console.error('Lỗi khi lấy danh sách project:', error);
      }
    };

    fetchProjects();
  }, []);
  const formatStatus = (status) => {
    const s = status.toLowerCase();
    switch (s) {
      case 'not started': return 'planning';
      case 'in progress': return 'active';
      case 'on hold': return 'on-hold';
      case 'completed': return 'completed';
      default: return 'planning';
    }
  };

  const navigate = useNavigate();

  const handleClick = (id) => {
    navigate(`/projects/${id}`);
  };
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 6;

  const handleFilterChange = (e) => {
    setFilters({ ...filters, [e.target.id.replace('Filter', '')]: e.target.value });
    setCurrentPage(1);
  };

  const handleSearchChange = (e) => {
    setFilters({ ...filters, search: e.target.value });
    setCurrentPage(1);
  };

  const filteredProjects = () => {
    let result = [...projects];
    const { status, member, search, sort } = filters;

    if (status) result = result.filter(p => p.status === status);
    if (member === 'me') result = result.filter(p => p.members.includes('NA'));
    if (member && member !== 'me') result = result.filter(p => p.members.includes(member));
    if (search) {
      const query = search.toLowerCase();
      result = result.filter(p =>
        p.title.toLowerCase().includes(query) ||
        p.description.toLowerCase().includes(query)
      );
    }

    switch (sort) {
      case 'newest': result.sort((a, b) => new Date(b.createdDate) - new Date(a.createdDate)); break;
      case 'oldest': result.sort((a, b) => new Date(a.createdDate) - new Date(b.createdDate)); break;
      case 'name': result.sort((a, b) => a.title.localeCompare(b.title)); break;
      case 'progress': result.sort((a, b) => b.progress - a.progress); break;
      default: break;
    }

    return result;
  };

  const paginatedProjects = () => {
    const all = filteredProjects();
    const start = (currentPage - 1) * itemsPerPage;
    return all.slice(start, start + itemsPerPage);
  };

  const totalPages = Math.ceil(filteredProjects().length / itemsPerPage);

  const getStatusClass = (status) => ({
    active: 'status-active',
    completed: 'status-completed',
    'on-hold': 'status-on-hold',
    planning: 'status-planning'
  }[status] || 'status-active');

  const getStatusText = (status) => ({
    active: 'Đang thực hiện',
    completed: 'Hoàn thành',
    'on-hold': 'Tạm dừng',
    planning: 'Lên kế hoạch'
  }[status] || 'Đang thực hiện');

  const formatDate = (str) => new Date(str).toLocaleDateString('vi-VN');

  const renderProjects = () => {
    const list = paginatedProjects();
    if (list.length === 0) {
      return (
        <div className="empty-state">
          <h3>Không tìm thấy dự án nào</h3>
          <p>Thử thay đổi bộ lọc hoặc tạo dự án mới</p>
          {/* Chỉ hiển thị nút tạo dự án mới nếu người dùng có quyền */}
          {user && (user.role === 'Admin' || user.role === 'Project Manager') && (
            <button className="create-btn" onClick={() => navigate('/projects/create')}>➕ Tạo dự án mới</button>
          )}
        </div>
      );
    }

    return list.map(project => (
      <div key={project.id} className="project-card" onClick={() => handleClick(project.id)}>
        <div className="project-icon">{project.icon}</div>
        <div className="project-header">
          <div>
            <h3 className="project-title">{project.title}</h3>
            <div className={`status-badge ${getStatusClass(project.status)}`}>
              {getStatusText(project.status)}
            </div>
          </div>
        </div>
        <p className="project-description">{project.description}</p>
        <div className="progress-bar">
          <div className="progress-fill" style={{ width: `${project.progress}%` }} />
        </div>
        <div className="progress-text">{project.progress}% hoàn thành</div>
        <div className="project-meta">
          <div className="project-stats">
            <span>📋 {project.completedTasks}/{project.totalTasks} tasks</span>
            <span>👥 {project.members.length} thành viên</span>
          </div>
        </div>
        <div className="team-avatars">
          {project.members.slice(0, 3).map((m, i) => {
            const initials = m.split(' ').map((word, index, arr) => {
              if (index === 0 || index === arr.length - 1) {
                return word.charAt(0).toUpperCase();
              }
              return '';
            }).join('');
            return <div className="team-avatar" key={i}>{initials}</div>;
          })}
          {project.members.length > 3 && <div className="team-avatar more-members">+{project.members.length - 3}</div>}
        </div>
        <div className="project-date">Hạn: {formatDate(project.dueDate)}</div>
        <div className="project-actions">
          {/* Chỉ hiển thị nút chỉnh sửa và xem tasks nếu người dùng có quyền */}
          {user && (user.role === 'Admin' || user.role === 'Project Manager') && (
            <button className="action-btn" onClick={(e) => { e.stopPropagation(); navigate(`/projects/${project.id}/edit`); }}>✏️ Chỉnh sửa</button>
          )}
          <button className="action-btn" onClick={(e) => { e.stopPropagation(); navigate(`/projects/${project.id}/tasks`); }}>📋 Xem tasks</button>
        </div>
      </div>
    ));
  };

  return (
    <div className="main-content-project-list">
      <div className="page-header">
        <h1 className="page-title">Danh sách Dự án</h1>
        {/* Chỉ hiển thị nút tạo dự án mới nếu người dùng có quyền */}
        {user && (user.role === 'Admin' || user.role === 'Project Manager') &&
          <button className="create-btn" onClick={() => navigate('/projects/create')}>➕ Tạo dự án mới</button>
        }
      </div>

      <div className="filters-bar">
        <div className="filter-group">
          <label>Trạng thái</label>
          <select id="statusFilter" onChange={handleFilterChange}>
            <option value="">Tất cả</option>
            <option value="active">Đang thực hiện</option>
            <option value="completed">Hoàn thành</option>
            <option value="on-hold">Tạm dừng</option>
            <option value="planning">Lên kế hoạch</option>
          </select>
        </div>

        <div className="filter-group">
          <label>Sắp xếp</label>
          <select id="sortFilter" onChange={handleFilterChange}>
            <option value="newest">Mới nhất</option>
            <option value="oldest">Cũ nhất</option>
            <option value="name">Tên A-Z</option>
            <option value="progress">Tiến độ</option>
          </select>
        </div>

        <div className="filter-group">
          <label>Thành viên</label>
          <select id="memberFilter" onChange={handleFilterChange}>
            <option value="">Tất cả</option>
            <option value="me">Dự án của tôi</option>
            <option value="john">John Doe</option>
            <option value="jane">Jane Smith</option>
          </select>
        </div>

        <div className="search-box">
          <input type="text" placeholder="Tìm kiếm dự án..." onChange={handleSearchChange} />
        </div>
      </div>

      <div className="projects-grid">
        {renderProjects()}
      </div>

      {/* Phân trang */}
      <div className="pagination">
        {Array.from({ length: totalPages }, (_, i) => (
          <button
            key={i}
            className={`page-btn ${currentPage === i + 1 ? 'active' : ''}`}
            onClick={() => setCurrentPage(i + 1)}
          >
            {i + 1}
          </button>
        ))}
      </div>
    </div>
  );
};

export default ProjectList;
