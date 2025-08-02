import React, { useEffect, useState } from 'react';
import '../../styles/task/MyTasks.css';

const TASKS = [
            {
                id: 1,
                title: "Thiết kế giao diện người dùng",
                description: "Tạo wireframe và mockup cho ứng dụng di động",
                status: "in-progress",
                priority: "high",
                assignee: "NA",
                project: "Mobile App Development",
                dueDate: "2025-08-10",
                createdDate: "2025-07-01"
            },
            {
                id: 2,
                title: "Thiết kế biểu đồ",
                description: "Tạo biểu đồ tương tác cho dashboard",
                status: "todo",
                priority: "low",
                assignee: "NA",
                project: "Data Analytics Dashboard",
                dueDate: "2025-08-25",
                createdDate: "2025-07-15"
            },
            {
                id: 3,
                title: "Cập nhật tài liệu API",
                description: "Viết tài liệu cho API mới",
                status: "todo",
                priority: "medium",
                assignee: "NA",
                project: "API Integration",
                dueDate: "2025-08-15",
                createdDate: "2025-07-05"
            },
            {
                id: 4,
                title: "Kiểm tra bảo mật",
                description: "Kiểm tra lỗ hổng bảo mật cho ứng dụng web",
                status: "in-progress",
                priority: "high",
                assignee: "NA",
                project: "Web Security",
                dueDate: "2025-08-20",
                createdDate: "2025-07-10"
            },
            {
                id: 5,
                title: "Thiết kế logo",
                description: "Tạo logo mới cho thương hiệu",
                status: "completed",
                priority: "medium",
                assignee: "NA",
                project: "Branding",
                dueDate: "2025-07-30",
                createdDate: "2025-06-25"
            },
            {
                id: 6,
                title: "Tối ưu hóa giao diện",
                description: "Cải thiện UX cho trang đăng nhập",
                status: "todo",
                priority: "low",
                assignee: "NA",
                project: "Website Redesign",
                dueDate: "2025-09-01",
                createdDate: "2025-07-20"
            },
            {
                id: 7,
                title: "Phát triển tính năng tìm kiếm",
                description: "Thêm tính năng tìm kiếm theo từ khóa",
                status: "in-progress",
                priority: "high",
                assignee: "NA",
                project: "Mobile App Development",
                dueDate: "2025-08-30",
                createdDate: "2025-07-12"
            },
            {
                id: 8,
                title: "Kiểm thử hiệu suất",
                description: "Kiểm tra tốc độ tải trang trên các thiết bị",
                status: "completed",
                priority: "medium",
                assignee: "NA",
                project: "Website Redesign",
                dueDate: "2025-07-25",
                createdDate: "2025-06-30"
            },
            {
                id: 9,
                title: "Cập nhật cơ sở dữ liệu",
                description: "Tối ưu hóa schema cơ sở dữ liệu",
                status: "todo",
                priority: "medium",
                assignee: "NA",
                project: "Database Optimization",
                dueDate: "2025-09-10",
                createdDate: "2025-07-18"
            },
            {
                id: 10,
                title: "Thiết lập CI/CD",
                description: "Cấu hình pipeline CI/CD cho dự án",
                status: "in-progress",
                priority: "high",
                assignee: "NA",
                project: "DevOps",
                dueDate: "2025-08-28",
                createdDate: "2025-07-15"
            },
            {
                id: 11,
                title: "Phân tích dữ liệu người dùng",
                description: "Tạo báo cáo phân tích hành vi người dùng",
                status: "todo",
                priority: "low",
                assignee: "NA",
                project: "Data Analytics Dashboard",
                dueDate: "2025-09-15",
                createdDate: "2025-07-22"
            },
            {
                id: 12,
                title: "Tích hợp thanh toán",
                description: "Kết nối với cổng thanh toán VNPay",
                status: "in-progress",
                priority: "high",
                assignee: "NA",
                project: "E-commerce Platform",
                dueDate: "2025-08-25",
                createdDate: "2025-07-10"
            },
            {
                id: 13,
                title: "Thiết kế banner quảng cáo",
                description: "Tạo banner cho chiến dịch marketing",
                status: "completed",
                priority: "medium",
                assignee: "NA",
                project: "Marketing Campaign",
                dueDate: "2025-07-20",
                createdDate: "2025-06-28"
            },
            {
                id: 14,
                title: "Kiểm tra giao diện responsive",
                description: "Đảm bảo giao diện hoạt động tốt trên mobile",
                status: "todo",
                priority: "medium",
                assignee: "NA",
                project: "Website Redesign",
                dueDate: "2025-09-05",
                createdDate: "2025-07-25"
            },
            {
                id: 15,
                title: "Viết unit test",
                description: "Viết unit test cho module thanh toán",
                status: "in-progress",
                priority: "high",
                assignee: "NA",
                project: "E-commerce Platform",
                dueDate: "2025-08-22",
                createdDate: "2025-07-08"
            },
            {
                id: 16,
                title: "Cập nhật giao diện dashboard",
                description: "Tùy chỉnh giao diện dashboard theo yêu cầu",
                status: "todo",
                priority: "low",
                assignee: "NA",
                project: "Data Analytics Dashboard",
                dueDate: "2025-09-20",
                createdDate: "2025-07-28"
            },
            {
                id: 17,
                title: "Tích hợp chatbot",
                description: "Thêm chatbot hỗ trợ khách hàng",
                status: "in-progress",
                priority: "medium",
                assignee: "NA",
                project: "Customer Support",
                dueDate: "2025-08-30",
                createdDate: "2025-07-15"
            },
            {
                id: 18,
                title: "Thiết kế email template",
                description: "Tạo template email cho thông báo",
                status: "completed",
                priority: "low",
                assignee: "NA",
                project: "Marketing Campaign",
                dueDate: "2025-07-15",
                createdDate: "2025-06-20"
            },
            {
                id: 19,
                title: "Kiểm tra API",
                description: "Kiểm tra tính ổn định của API mới",
                status: "todo",
                priority: "high",
                assignee: "NA",
                project: "API Integration",
                dueDate: "2025-09-01",
                createdDate: "2025-07-20"
            },
            {
                id: 20,
                title: "Cập nhật tài liệu người dùng",
                description: "Viết hướng dẫn sử dụng cho ứng dụng",
                status: "in-progress",
                priority: "medium",
                assignee: "NA",
                project: "Mobile App Development",
                dueDate: "2025-08-28",
                createdDate: "2025-07-12"
            }
        ];

const MyTasks = () => {
  const [tasks, setTasks] = useState(TASKS);
  const [currentPage, setCurrentPage] = useState(1);
  const [filters, setFilters] = useState({
    status: '',
    priority: '',
    sort: 'newest',
    search: ''
  });

  const tasksPerPage = 6;

  const filteredTasks = tasks.filter(task => {
    const matchesStatus = !filters.status || task.status === filters.status;
    const matchesPriority = !filters.priority || task.priority === filters.priority;
    const matchesSearch = !filters.search || (
      task.title.toLowerCase().includes(filters.search.toLowerCase()) ||
      task.description.toLowerCase().includes(filters.search.toLowerCase()) ||
      task.project.toLowerCase().includes(filters.search.toLowerCase())
    );
    return matchesStatus && matchesPriority && matchesSearch;
  }).sort((a, b) => {
    switch (filters.sort) {
      case 'newest':
        return new Date(b.createdDate) - new Date(a.createdDate);
      case 'oldest':
        return new Date(a.createdDate) - new Date(b.createdDate);
      case 'name':
        return a.title.localeCompare(b.title);
      case 'priority':
        const order = { high: 3, medium: 2, low: 1 };
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

  const getStatusClass = (status) => ({
    'todo': 'status-todo',
    'in-progress': 'status-in-progress',
    'completed': 'status-completed'
  }[status]);

  const getPriorityClass = (priority) => ({
    'high': 'priority-high',
    'medium': 'priority-medium',
    'low': 'priority-low'
  }[priority]);

  const getStatusText = (status) => ({
    'todo': 'Chưa làm',
    'in-progress': 'Đang thực hiện',
    'completed': 'Hoàn thành'
  }[status]);

  const getPriorityText = (priority) => ({
    'high': 'Cao',
    'medium': 'Trung bình',
    'low': 'Thấp'
  }[priority]);

  return (
    <>
    {/* <header className="header">
        <div className="header-content">
          <div className="logo">🛠️ Project Hub</div>
          <nav className="nav-links">
            <a href="#">Dự án</a>
            <a href="#" className="active">Task Của Tôi</a>
            <a href="#">Báo cáo</a>
          </nav>
          <div className="user-info">
            <strong>Nguyễn Văn A</strong>
            <div className="user-avatar">NA</div>
          </div>
        </div>
      </header> */}
    <div className="main-content-my-tasks">
      <div className="page-header">
        <h1 className="page-title">Task Của Tôi</h1>
      </div>

      <div className="filters-bar">
        <div className="filter-group">
          <label>Trạng thái</label>
          <select name="status" onChange={handleFilterChange}>
            <option value="">Tất cả</option>
            <option value="todo">Chưa làm</option>
            <option value="in-progress">Đang thực hiện</option>
            <option value="completed">Hoàn thành</option>
          </select>
        </div>

        <div className="filter-group">
          <label>Ưu tiên</label>
          <select name="priority" onChange={handleFilterChange}>
            <option value="">Tất cả</option>
            <option value="high">Cao</option>
            <option value="medium">Trung bình</option>
            <option value="low">Thấp</option>
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
          <div key={task.id} className="task-card" onClick={() => alert(`Mở chi tiết task #${task.id}`)}>
            <div className="task-header">
              <div>
                <h3 className="task-title">{task.title}</h3>
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

            <div className="assignee-avatar">{task.assignee}</div>
            <div className="task-date">Hạn: {formatDate(task.dueDate)}</div>

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
