import React, { useEffect, useState } from 'react';
import '../../styles/project/projectdetail.css';
import { useParams } from 'react-router-dom';
import { getProjectById, addMemberToProject, removeMemberFromProject} from '../../services/projectService';
import { getAllUsers } from '../../services/userService'; // Lấy danh sách người dùng
import { getAllTasks } from '../../services/taskService';
import { useNavigate } from 'react-router-dom';

const ProjectDetail = () => {
  const { id } = useParams(); // Lấy id từ URL
  const [project, setProject] = useState(null);
  const [tasks, setTasks] = useState([]);
  const [pagination, setPagination] = useState({});
  const [showInviteModal, setShowInviteModal] = useState(false); // State để hiển thị modal
  const [availableMembers, setAvailableMembers] = useState([]); // Danh sách người dùng
  const [selectedMemberId, setSelectedMemberId] = useState(''); // ID của thành viên được mời
  const [showRemoveModal, setShowRemoveModal] = useState(false); // Hiển thị modal xóa
  const [selectedMember, setSelectedMember] = useState(null); // Thành viên được chọn để xóa
  const navigator = useNavigate();

  useEffect(() => {
    // Lấy thông tin dự án
    const fetchProject = async () => {
      try {
        const res = await getProjectById(id);
        setProject(res.project);
        console.log('Dự án:', res.project);
      } catch (error) {
        console.error('Lỗi khi lấy thông tin dự án:', error);
      }
    };

    // Lấy danh sách task liên quan đến dự án
    const fetchTasks = async (page = 1) => {
      try {
        const res = await getAllTasks(id, page);
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
        const res = await getAllUsers({page: 1, limit: 100});
        setAvailableMembers(res.users); // Lưu danh sách người dùng
      } catch (error) {
        console.error('Lỗi khi lấy danh sách người dùng:', error);
      }
    };

    fetchProject();
    fetchTasks();
    fetchUsers();
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

  const handleInviteMember = async () => {
    try {
      await addMemberToProject(id, selectedMemberId); // Gửi yêu cầu mời thành viên bằng ID
      alert('Đã mời thành viên thành công!');
      setSelectedMemberId('');
      setShowInviteModal(false);

      // Gọi lại API để cập nhật danh sách thành viên
      const updatedProject = await getProjectById(id);
      setProject(updatedProject.project); // Cập nhật state project
    } catch (error) {
      console.error('Lỗi khi mời thành viên:', error);
      alert('Có lỗi xảy ra khi mời thành viên. Vui lòng thử lại!');
    }
  };

  const handleRemoveMemberClick = (member) => {
    setSelectedMember(member); // Lưu thông tin thành viên được chọn
    setShowRemoveModal(true); // Hiển thị modal
  };

  const handleConfirmRemoveMember = async () => {
    try {
      await removeMemberFromProject(id, selectedMember._id); // Gửi yêu cầu xóa thành viên
      alert(`Đã xóa thành viên ${selectedMember.full_name} khỏi dự án.`);
      setShowRemoveModal(false); // Đóng modal
      setSelectedMember(null); // Xóa thông tin thành viên được chọn

      // Cập nhật danh sách thành viên
      setProject((prevProject) => ({
        ...prevProject,
        members: prevProject.members.filter((m) => m._id !== selectedMember._id),
      }));
    } catch (error) {
      console.error('Lỗi khi xóa thành viên:', error);
      alert('Có lỗi xảy ra khi xóa thành viên. Vui lòng thử lại!');
    }
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
              <div className="stat-number">
                {project.budget
                  ? parseFloat(project.budget.toString())
                  : 'Không xác định'}
              </div>
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
              <button className="action-btn primary" onClick={() => navigator('/tasks/create', { state: { projectId: id } })}>➕ Thêm task</button>
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
              <button className="action-btn primary" onClick={() => setShowInviteModal(true)}>➕ Mời thành viên</button>
            </div>
            <div className="team-grid">
              {project.members?.map((member) => (
                <div key={member._id} className="team-card">
                  <div className="team-avatar">{member.full_name[0]}</div>
                  <div className="team-name">{member.full_name}</div>
                  <div className="team-role">Thành viên</div>
                  <button
                    className="remove-member-btn"
                    onClick={() => handleRemoveMemberClick(member)} // Gọi hàm trung gian
                  >
                    ✖
                  </button>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Modal mời thành viên */}
        {showInviteModal && (
          <div className="modal">
            <div className="modal-content">
              <h3>Mời thành viên</h3>
              <select
                value={selectedMemberId}
                onChange={(e) => setSelectedMemberId(e.target.value)}
              >
                <option value="">Chọn thành viên</option>
                {availableMembers.map((member) => (
                  <option key={member._id} value={member._id}>
                    {member.full_name} ({member.email})
                  </option>
                ))}
              </select>
              <div className="modal-actions">
                <button
                  className="action-btn primary"
                  onClick={handleInviteMember}
                  disabled={!selectedMemberId}
                >
                  Mời
                </button>
                <button
                  className="action-btn"
                  onClick={() => setShowInviteModal(false)}
                >
                  Hủy
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Modal xác nhận xóa thành viên */}
        {showRemoveModal && selectedMember && (
          <div className="modal">
            <div className="modal-content">
              <h3>Xác nhận xóa thành viên</h3>
              <p>Bạn có chắc chắn muốn xóa thành viên <strong>{selectedMember.full_name}</strong> khỏi dự án không?</p>
              <div className="modal-actions">
                <button
                  className="action-btn primary"
                  onClick={handleConfirmRemoveMember}
                >
                  Xóa
                </button>
                <button
                  className="action-btn"
                  onClick={() => setShowRemoveModal(false)}
                >
                  Hủy
                </button>
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  );
};

export default ProjectDetail;