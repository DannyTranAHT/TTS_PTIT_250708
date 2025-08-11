import React, { useEffect, useState } from 'react';
import '../../styles/task/MyTasks.css';
import { getAllProjects,getProjectById } from '../../services/projectService';
import { getAllTasks } from '../../services/taskService';
import { getAllUsers } from '../../services/userService';
import { useParams } from 'react-router-dom';
import { useNavigate } from 'react-router-dom';

const MyTasks = () => {
  const { id } = useParams();
  const [project, setProject] = useState(null);
  const [tasks, setTasks] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [availableMembers, setAvailableMembers] = useState([]);   
  const [filters, setFilters] = useState({
    status: '',
    priority: '',
    sort: 'newest',
    search: ''
  });
  const navigate = useNavigate();

  const tasksPerPage = 6;

  const normalizeString = (str) => {
  return str
    .normalize('NFD') // Tách các ký tự có dấu thành ký tự cơ bản và dấu
    .replace(/[\u0300-\u036f]/g, '') // Loại bỏ dấu
    .toLowerCase(); // Chuyển về chữ thường
};

  const filteredTasks = tasks.filter(task => {
    const matchesStatus = !filters.status || task.status === filters.status;
    const matchesPriority = !filters.priority || task.priority === filters.priority;
    const matchesSearch = !filters.search || (
      (task.title && normalizeString(task.title).includes(normalizeString(filters.search))) ||
      (task.description && normalizeString(task.description).includes(normalizeString(filters.search))) ||
      (task.project && normalizeString(task.project).includes(normalizeString(filters.search)))
    );
    return matchesStatus && matchesPriority && matchesSearch;
  }).sort((a, b) => {
    switch (filters.sort) {
      case 'newest':
        return new Date(b.due_date) - new Date(a.due_date);
      case 'oldest':
        return new Date(a.due_date) - new Date(b.due_date); 
      case 'name':
        return a.name.localeCompare(b.name);
      case 'priority':
        const order = { High: 3, Medium: 2, Low: 1 };
        return order[b.priority] - order[a.priority];
      default:
        return 0;
    }
  });

  const totalPages = Math.ceil(filteredTasks.length / tasksPerPage);
  const paginatedTasks = filteredTasks.slice(
    (currentPage - 1) * tasksPerPage,
    currentPage * tasksPerPage
  );

  const handleFilterChange = (e) => {
    setCurrentPage(1);
    setFilters(prev => ({ ...prev, [e.target.name]: e.target.value }));
  };

  const handleSearchChange = (e) => {
    setCurrentPage(1);
    setFilters(prev => ({ ...prev, search: e.target.value }));
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('vi-VN');
  };

  useEffect(() => {
      // Lấy thông tin dự án
      const fetchProject = async () => {
        try {
          const res = await getProjectById(id);
          setProject(res.project);
        } catch (error) {
          console.error('Lỗi khi lấy thông tin dự án:', error);
        }
      };
  
      // Lấy danh sách task liên quan đến dự án
      const fetchTasks = async () => {
        try {
          const res = await getAllTasks(id);
          setTasks(res.tasks);
          setPagination({
            currentPage: res.currentPage,
            totalPages: res.totalPages,
            total: res.total,
          });
        } catch (error) {
          console.error('Lỗi khi lấy danh sách task:', error);
        }
      };
  
      // Lấy danh sách người dùng
      const fetchUsers = async () => {
        try {
          const res = await getAllUsers();
          setAvailableMembers(res.users); // Lưu danh sách người dùng
        } catch (error) {
          console.error('Lỗi khi lấy danh sách người dùng:', error);
        }
      };
  
      fetchProject();
      fetchTasks();
      fetchUsers();
    }, [id]);

const getStatusClass = (status) => ({
  'To Do': 'status-todo',
  'In Progress': 'status-in-progress',
  'In Review': 'status-in-review',
  'Blocked': 'status-blocked',
  'Done': 'status-done'
}[status]);

const getPriorityClass = (priority) => ({
  'low': 'priority-low',
  'medium': 'priority-medium',
  'high': 'priority-high',
  'critical': 'priority-critical'
}[priority.toLowerCase()]);

const getStatusText = (status) => ({
  'To Do': 'Chưa làm',
  'In Progress': 'Đang thực hiện',
  'In Review': 'Đang xem xét',
  'Blocked': 'Bị chặn',
  'Done': 'Hoàn thành'
}[status]);

const getPriorityText = (priority) => ({
  'low': 'Thấp',
  'medium': 'Trung bình',
  'high': 'Cao',
  'critical': 'Rất cao'
}[priority.toLowerCase()]);

  return (
    <>
    <div className="main-content-my-tasks">
      <div className="page-header">
        <h1 className="page-title">Task Của Tôi</h1>
      </div>

      <div className="filters-bar">
        <div className="filter-group">
          <label>Trạng thái</label>
          <select name="status" onChange={handleFilterChange}>
            <option value="">Tất cả</option>
            <option value="To Do">Chưa làm</option>
            <option value="In Progress">Đang thực hiện</option>
            <option value="In Review">Đang xem xét</option>
            <option value="Blocked">Bị chặn</option>
            <option value="Done">Hoàn thành</option>
          </select>
        </div>

        <div className="filter-group">
          <label>Ưu tiên</label>
          <select name="priority" onChange={handleFilterChange}>
            <option value="">Tất cả</option>
            <option value="Low">Thấp</option>
            <option value="Medium">Trung bình</option>
            <option value="High">Cao</option>
            <option value="Critical">Rất cao</option>
          </select>
        </div>

        <div className="filter-group">
          <label>Sắp xếp</label>
          <select name="sort" onChange={handleFilterChange}>
            <option value="newest">Mới nhất</option>
            <option value="oldest">Cũ nhất</option>
            <option value="name">Tên A-Z</option>
            <option value="priority">Ưu tiên</option>
          </select>
        </div>
        <div className="search-box">
          <input
            type="text"
            placeholder="Tìm kiếm task..."
            value={filters.search}
            onChange={handleSearchChange}
          />
        </div>
      </div>

      <div className="tasks-grid">
        {paginatedTasks.length > 0 ? paginatedTasks.map(task => (
          <div key={task._id} className="task-card" onClick={() => navigate(`/tasks/${task._id}`)}>
            <div className="task-header">
              <div>
                <h3 className="task-title">{task.name}</h3>
                <div className={`status-badge ${getStatusClass(task.status)}`}>
                  {getStatusText(task.status)}
                </div>
              </div>
              <div className={`priority-badge ${getPriorityClass(task.priority)}`}>
                {getPriorityText(task.priority)}
              </div>
            </div>

            <p className="task-description">{task.description}</p>

            <div className="task-meta">
              <div className="task-stats">
                <span>📋 {task.project}</span>
                <span>👤 {task.assignee}</span>
              </div>
            </div>

            <div className="assignee-avatar">📁</div>
            <div className="task-date">Hạn: {formatDate(task.due_date)}</div>

            <div className="task-actions">
              <button
                className="action-btn"
                onClick={(e) => {
                  e.stopPropagation();
                  alert(`Xem chi tiết task #${task.id}`);
                }}
              >
                📋 Xem chi tiết
              </button>
            </div>
          </div>
        )) : (
          <div className="empty-state">
            <h3>Không có task nào</h3>
            <p>Bạn hiện không được gán task nào</p>
          </div>
        )}
      </div>

      {totalPages > 1 && (
        <div className="pagination">
          <button
            className={`page-btn ${currentPage === 1 ? 'disabled' : ''}`}
            onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
          >
            ‹
          </button>
          {Array.from({ length: totalPages }, (_, i) => i + 1).map(i => (
            <button
              key={i}
              className={`page-btn ${i === currentPage ? 'active' : ''}`}
              onClick={() => setCurrentPage(i)}
            >
              {i}
            </button>
          ))}
          <button
            className={`page-btn ${currentPage === totalPages ? 'disabled' : ''}`}
            onClick={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))}
          >
            ›
          </button>
        </div>
      )}
    </div>
    </>
  );
};

export default MyTasks;
