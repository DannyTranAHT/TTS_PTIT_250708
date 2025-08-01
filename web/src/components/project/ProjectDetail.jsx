import React, { useEffect, useState } from 'react';
import '../../styles/project/projectdetail.css';
import { useParams } from 'react-router-dom';
import { getProjectById } from '../../services/projectService';
import { getAllTasks } from '../../services/taskService';
import { useNavigate } from 'react-router-dom';

const ProjectDetail = () => {
  const { id } = useParams(); // Lấy id từ URL
  const [project, setProject] = useState(null);
  const [tasks, setTasks] = useState([]);
  const [pagination, setPagination] = useState({});
  const navigator = useNavigate();

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
    const fetchTasks = async (page = 1) => {
      try {
        const res = await getAllTasks(id, page);
        setTasks(res.tasks);
        console.log('Tasks:', res.tasks);
        setPagination({
          currentPage: res.currentPage,
          totalPages: res.totalPages,
          total: res.total,
        });
      } catch (error) {
        console.error('Lỗi khi lấy danh sách task:', error);
      }
    };

    fetchProject();
    fetchTasks();
  }, [id]);

  const handlePageChange = (page) => {
    fetchTasks(page); // Gọi API để lấy dữ liệu trang mới
  };

  const showTab = (tabName) => {
    // Loại bỏ lớp 'active' khỏi tất cả nội dung tab
    document.querySelectorAll('.tab-content').forEach((content) => {
      content.classList.remove('active');
    });

    // Loại bỏ lớp 'active' khỏi tất cả nút tab
    document.querySelectorAll('.tab-btn').forEach((btn) => {
      btn.classList.remove('active');
    });

    // Thêm lớp 'active' vào tab được chọn
    document.getElementById(`${tabName}-tab`).classList.add('active');

    // Thêm lớp 'active' vào nút tab được chọn
    document.querySelector(`.tab-btn[data-tab="${tabName}"]`).classList.add('active');
  };

  if (!project) {
    return <div>Đang tải thông tin dự án...</div>;
  }

  return (
    <div>
      <main className="main-content-project-detail">
        <div className="project-header">
          <div className="project-title-section">
            <div>
              <h1 className="project-title">📱 {project.name}</h1>
              <p className="project-description">{project.description}</p>
            </div>
            <div className="project-actions">
              <button className="action-btn">👥 Mời thành viên</button>
              <button className="action-btn">📊 Báo cáo</button>
              <button className="action-btn primary">⚙️ Cài đặt</button>
            </div>
          </div>

          <div className="project-stats">
            <div className="stat-item">
              <div className="stat-number">{tasks.length}</div>
              <div className="stat-label">Tổng Tasks</div>
            </div>
            <div className="stat-item">
              <div className="stat-number">{project.members?.length || 0}</div>
              <div className="stat-label">Thành viên</div>
            </div>
            <div className="stat-item">
              <div className="stat-number">{project.progress || 0}%</div>
              <div className="stat-label">Tiến độ</div>
            </div>
            <div className="stat-item">
              <div className="stat-number">{parseFloat(project.budget.$numberDecimal.toString()) || 'Không xác định'}</div>
              <div className="stat-label">Ngân sách</div>
            </div>
          </div>

          <div className="progress-section">
            <div className="progress-bar">
              <div className="progress-fill" style={{ width: `${project.progress || 0}%` }}></div>
            </div>
            <div className="progress-text">
              <span>Tiến độ dự án</span>
              <span>{project.progress || 0}%</span>
            </div>
          </div>
        </div>

        <div className="content-tabs">
          <button className="tab-btn active" data-tab="overview" onClick={() => showTab('overview')}>📊 Tổng quan</button>
          <button className="tab-btn" data-tab="tasks" onClick={() => showTab('tasks')}>📋 Tasks</button>
          <button className="tab-btn" data-tab="team" onClick={() => showTab('team')}>👥 Team</button>
        </div>

        <div className="tab-content active" id="overview-tab">
          <div className="overview-section">
            <div className="timeline-section">
              <h3 className="section-title">Timeline dự án</h3>
              {/* Timeline items */}
            </div>

            <div className="project-info">
              <h3 className="section-title">Thông tin dự án</h3>
              <div className="info-item">
                <span className="info-label">Trạng thái</span>
                <span className="info-value">
                  <span className="status-badge status-active">{project.status}</span>
                </span>
              </div>
              <div className="info-item">
                <span className="info-label">Độ ưu tiên</span>
                <span className="info-value">{project.priority}</span>
              </div>
              <div className="info-item">
                <span className="info-label">Ngày tạo</span>
                <span className="info-value">{new Date(project.created_at).toLocaleDateString()}</span>
              </div>
            </div>
          </div>
        </div>

        <div className="tab-content" id="tasks-tab">
          <div className="tasks-section">
            <div className="section-header">
              <h3 className="section-title">Quản lý Tasks</h3>
              <button className="action-btn primary" onClick={() => navigator('/tasks/create')}>➕ Thêm task</button>
            </div>
            <div className="task-board">
              {tasks.map((task) => (
                <div key={task._id} className="task-card" onClick={() => navigator(`/tasks/${task._id}`)}>
                  <div className="task-card-header">
                    <div className="task-card-title">{task.name}</div>
                    <div className={`task-priority priority-${task.priority.toLowerCase()}`}>{task.priority}</div>
                  </div>
                  <div className="task-card-meta">
                    <div className="task-assignee">
                      {task.assigned_to_id?.full_name
                        ? `${task.assigned_to_id.full_name.split(" ")[0][0]}${task.assigned_to_id.full_name.split(" ").slice(-1)[0][0]}`
                        : "KĐ"}
                    </div>
                    <div className="task-due-date">{new Date(task.due_date).toLocaleDateString() || 'Không xác định'}</div>
                  </div>
                </div>
              ))}
            </div>
            <div className="pagination">
              {pagination.currentPage > 1 && (
                <button onClick={() => handlePageChange(pagination.currentPage - 1)}>Trang trước</button>
              )}
              <span>Trang {pagination.currentPage} / {pagination.totalPages}</span>
              {pagination.currentPage < pagination.totalPages && (
                <button onClick={() => handlePageChange(pagination.currentPage + 1)}>Trang sau</button>
              )}
            </div>
          </div>
        </div>

        <div className="tab-content" id="team-tab">
          <div className="team-section">
            <div className="section-header">
              <h3 className="section-title">Thành viên dự án</h3>
              <button className="action-btn primary">➕ Mời thành viên</button>
            </div>
            <div className="team-grid">
              {project.members?.map((member) => (
                <div key={member._id} className="team-card">
                  <div className="team-avatar">{member.full_name[0]}</div>
                  <div className="team-name">{member.full_name}</div>
                  <div className="team-role">Thành viên</div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </main>
    </div>
  );
};

export default ProjectDetail;