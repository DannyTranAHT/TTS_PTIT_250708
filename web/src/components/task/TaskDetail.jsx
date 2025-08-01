import React, { useEffect, useState } from "react";
import "../../styles/task/taskdetail.css";
import { useNavigate } from 'react-router-dom';
import { getProjectById } from "../../services/projectService";
import { getTaskById, updateTask,requestCompleteTask } from "../../services/taskService";
import { getUserById } from "../../services/userService"; 
import { getComment } from "../../services/commentService"; 
import { useParams } from 'react-router-dom';

const formatTime = (timestamp) => {
  
  const now = Date.now();
  const diff = now - timestamp;
  const minutes = Math.floor(diff / (1000 * 60));
  const hours = Math.floor(diff / (1000 * 60 * 60));
  const days = Math.floor(diff / (1000 * 60 * 60 * 24));
  if (minutes < 60) return `${minutes} phút trước`;
  else if (hours < 24) return `${hours} giờ trước`;
  else return `${days} ngày trước`;
};

const TaskDetail = () => {
  const currentUser = JSON.parse(localStorage.getItem("user"));
  const { id } = useParams(); // Lấy id từ URL // Lấy id dự án từ URL
  const [comments, setComments] = useState([]);
  const [commentInput, setCommentInput] = useState("");
  const [task, setTask] = useState([]);
  const [project, setProject] = useState([]);
  const [user, setUser] = useState([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isConfirmModalOpen, setIsConfirmModalOpen] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
  const fetchTasksAndProject = async () => {
    try {
      // Lấy thông tin task
      const taskRes = await getTaskById(id);
      setTask(taskRes.task);

      // Lấy thông tin dự án sử dụng project_id của task
      const projectRes = await getProjectById(taskRes.task.project_id);
      setProject(projectRes.project);
      console.log('Project:', projectRes.project);

      // Lấy thông tin người dùng sử dụng user_id của task
      const userRes = await getUserById(taskRes.task.assigned_to_id);
      setUser(userRes.user);

      // Lấy danh sách bình luận của task
      const commentsRes = await getComment(taskRes.task._id);
      setComments(commentsRes.comments);
      
    } catch (error) {
      console.error('Lỗi khi lấy thông tin:', error);
    }
  };

  fetchTasksAndProject();
}, [id]);
  

  useEffect(() => {
    const interval = setInterval(() => {
      setComments((prev) =>
        prev.map((c) => ({ ...c, time: formatTime(c.timestamp) }))
      );
    }, 60000);
    return () => clearInterval(interval);
  }, []);


  useEffect(() => {
    setComments((prev) =>
      prev.map((c) => ({ ...c, time: formatTime(c.timestamp) }))
    );
  }, []);

  const addComment = () => {
    const content = commentInput.trim();
    if (!content) {
      alert("Vui lòng nhập nội dung bình luận");
      return;
    }

    const newComment = {
      id: comments.length + 1,
      author: "Nguyễn Văn A",
      avatar: "NA",
      content,
      timestamp: Date.now(),
      time: "Vừa xong",
    };
    setComments([...comments, newComment]);
    setCommentInput("");
  };

  const cancelComment = () => setCommentInput("");

  const saveTask = async () => {
    try {
      // Chỉ giữ lại các trường hợp hợp lệ theo schema
      const updatedTask = {
        name: task.name,
        description: task.description,
        due_date: task.due_date,
        status: task.status,
        priority: task.priority,
        assigned_to_id: task.assigned_to_id,
        hours: task.hours,
        attachments: task.attachments,
      };

      console.log("Dữ liệu gửi lên:", updatedTask); // Kiểm tra dữ liệu trước khi gửi
      await updateTask(task._id, updatedTask);
      alert("Cập nhật thành công!");
      setIsModalOpen(false);
    } catch (error) {
      console.error("Lỗi khi cập nhật task:", error.response?.data || error.message);
      alert("Cập nhật thất bại!");
    }
  };
  const handleCompleteTask = async () => {
    setIsConfirmModalOpen(true);
  };

const confirmCompleteTask = async () => {
  try {
    await requestCompleteTask(task._id);
    alert("Công việc đã được gửi yêu cầu hoàn thành!");
    setTask({ ...task, status: "In Review" });
  } catch (error) {
    console.error("Lỗi khi gửi yêu cầu hoàn thành:", error);
    alert("Không thể gửi yêu cầu hoàn thành. Vui lòng thử lại!");
  } finally {
    setIsConfirmModalOpen(false);
  }
};

  return (
    <div className="page-container">
      <main className="main-content-task-detail">
        <div className="task-detail">
          <div className="task-header">
            <div>
              <h1 className="task-title">🎨 {task?.name}</h1>
              <div className="task-project">{project?.name}</div>
            </div>
            <div className="task-actions">
              {currentUser?.id === task?.created_by && (
                <button className="action-btn" onClick={() => setIsModalOpen(true)}>
                  ✏️ Chỉnh sửa
                </button>
              )}
              {currentUser?.id === task?.assigned_to_id && (
                <button className="action-btn primary" onClick={handleCompleteTask}>
                  ✅ Hoàn thành
                </button>
              )}
            </div>
          </div>
          {/* Task Meta */}
          <div className="task-meta">
            <div className="meta-item">
              <span className="meta-label">Trạng thái</span>
              <div className="meta-value">
                <span className={`status-badge ${task?.status?.toLowerCase().replace(/\s+/g, '-')}`}>
                  {task?.status || "Chưa xác định"}
                </span>
              </div>
            </div>
            <div className="meta-item">
              <span className="meta-label">Độ ưu tiên</span>
              <div className="meta-value">
                <span className={`priority-badge ${task?.priority?.toLowerCase()}`}>
                  {task?.priority || "Chưa xác định"}
                </span>
              </div>
            </div>
            <div className="meta-item">
              <span className="meta-label">Được gán cho</span>
              <div className="meta-value">
                <div className="assignee-info">
                  <div className="assignee-avatar">{user?.full_name
                  ? `${user.full_name.split(" ")[0][0]}${user.full_name.split(" ").slice(-1)[0][0]}`
                  : ""}
                  </div>
                  <span>{user?.full_name || "Chưa xác định"}</span>
                </div>
              </div>
            </div>
            <div className="meta-item">
              <span className="meta-label">Hạn hoàn thành</span>
              <div className="meta-value">
                <div className="time-info overdue">
                  <span>⏰</span>
                  <span>{new Date(task?.due_date).toLocaleDateString() || "Chưa xác định"}</span>
                </div>
              </div>
            </div>
            <div className="meta-item">
              <span className="meta-label">Thời gian ước tính</span>
              <div className="meta-value">{task?.hours || 0} giờ</div>
            </div>
          </div>

          {/* Description */}
          <div className="task-description">
            <h3 className="section-title">Mô tả</h3>
            <div className="description-text">
              {task?.description || "Chưa có mô tả"}
              <br />
              <br />
              • Tổng quan doanh số và metrics quan trọng
              <br />
              • Biểu đồ thống kê tương tác
              <br />
              • Responsive design cho nhiều kích thước màn hình
              <br />
              • Dark mode support
              <br />
              • Animation và micro-interactions
              <br />
              <br />
              Sử dụng design system hiện có và tuân thủ Material Design
              guidelines.
            </div>
          </div>

          {/* Attachments */}
          <div className="task-attachments">
            <h3 className="section-title">Tệp đính kèm</h3>
            {[
              { name: "Dashboard_Mockup_v1.fig", size: "2.5 MB" },
              { name: "Design_System_Guide.pdf", size: "1.2 MB" },
              { name: "User_Flow_Diagram.jpg", size: "850 KB" },
            ].map((file, i) => (
              <div key={i} className="attachment-item">
                <div className="attachment-icon">📎</div>
                <div className="attachment-info">
                  <div className="attachment-name">{file.name}</div>
                  <div className="attachment-size">{file.size}</div>
                </div>
              </div>
            ))}
          </div>

          {/* Comments */}
          <div className="comments-section">
            <h3 className="section-title">Bình luận</h3>
            <div className="comment-form">
              <textarea
                className="comment-input"
                placeholder="Viết bình luận..."
                value={commentInput}
                onChange={(e) => setCommentInput(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === "Enter" && e.ctrlKey) addComment();
                }}
              />
              <div className="comment-actions">
                <button className="comment-btn" onClick={cancelComment}>
                  Hủy
                </button>
                <button className="comment-btn primary" onClick={addComment}>
                  Gửi bình luận
                </button>
              </div>
            </div>
            <div className="comments-list">
              {comments && comments.map((c) => (
                <div key={c._id} className="comment-item">
                  <div className="comment-avatar">
                    {c.user_id?.full_name
                      ? `${c.user_id.full_name.split(" ")[0][0]}${c.user_id.full_name.split(" ").slice(-1)[0][0]}`
                      : ""}
                  </div>
                  <div className="comment-content">
                    <div className="comment-header">
                      <span className="comment-author">{c.user_id?.full_name || "Người dùng không xác định"}</span>
                      <span className="comment-time">{new Date(c.created_at).toLocaleString()}</span>
                    </div>
                    <div className="comment-text">{c.content}</div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Sidebar */}
        <div className="sidebar">
          <div className="sidebar-card">
            <h3 className="section-title">Hoạt động gần đây</h3>
            <div className="activity-feed">
              {[
                {
                  name: "John Doe",
                  avatar: "JD",
                  text: 'đã cập nhật trạng thái thành "Đang thực hiện"',
                  time: "2 giờ trước",
                },
                {
                  name: "Nguyễn Văn A",
                  avatar: "NA",
                  text: "đã thêm tệp đính kèm Dashboard_Mockup_v1.fig",
                  time: "5 giờ trước",
                },
                {
                  name: "Jane Smith",
                  avatar: "JS",
                  text: 'đã hoàn thành subtask "Phân tích requirements"',
                  time: "1 ngày trước",
                },
                {
                  name: "John Doe",
                  avatar: "JD",
                  text: "đã tạo task này",
                  time: "3 ngày trước",
                },
              ].map((a, i) => (
                <div key={i} className="activity-item">
                  <div className="activity-avatar">{a.avatar}</div>
                  <div className="activity-content">
                    <div className="activity-text">
                      <strong>{a.name}</strong> {a.text}
                    </div>
                    <div className="activity-time">{a.time}</div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="sidebar-card">
            <h3 className="section-title">Thông tin thêm</h3>
            <div className="meta-item">
              <span className="meta-label">Người tạo</span>
              <div className="meta-value">
                <div className="assignee-info">
                  <div className="assignee-avatar">{project.owner_id?.full_name.split(" ")[0][0]}{project.owner_id?.full_name.split(" ").slice(-1)[0][0]}</div>
                  <span>{project.owner_id?.full_name || "Người dùng không xác định"}</span>
                </div>
              </div>
            </div>
            <div className="meta-item" style={{ marginTop: 15 }}>
              <span className="meta-label">Ngày tạo</span>
              <div className="meta-value">{project.created_at ? new Date(project.created_at).toLocaleString() : "Không xác định"}</div>
            </div>
            <div className="meta-item" style={{ marginTop: 15 }}>
              <span className="meta-label">Lần cập nhật cuối</span>
              <div className="meta-value">{project.updated_at ? new Date(project.updated_at).toLocaleString() : "Không xác định"}</div>
            </div>
          </div>
        </div>
      </main>

      {/* Modal chỉnh sửa công việc */}
      {isModalOpen && (
        <div className="modal-overlay">
          <div className="modal-content">
            <div className="modal-header">
              <h2>Chỉnh sửa công việc</h2>
              <button className="modal-close-btn" onClick={() => setIsModalOpen(false)}>
                &times;
              </button>
            </div>
            <div className="modal-body">
              <input
                type="text"
                value={task?.name || ""}
                onChange={(e) => setTask({ ...task, name: e.target.value })}
                className="edit-task-input"
                placeholder="Tên công việc"
              />
              <textarea
                value={task?.description || ""}
                onChange={(e) => setTask({ ...task, description: e.target.value })}
                className="edit-task-input"
                placeholder="Mô tả công việc"
              />
              <input
                type="date"
                value={task?.due_date ? new Date(task.due_date).toISOString().split("T")[0] : ""}
                onChange={(e) => setTask({ ...task, due_date: e.target.value })}
                className="edit-task-input"
              />
              <select
                value={task?.status || ""}
                onChange={(e) => setTask({ ...task, status: e.target.value })}
                className="edit-task-input"
              >
                <option value="To Do">To Do</option>
                <option value="In Progress">In Progress</option>
                <option value="In Review">In Review</option>
                <option value="Blocked">Blocked</option>
                <option value="Done">Done</option>
              </select>
              <select
                value={task?.priority || ""}
                onChange={(e) => setTask({ ...task, priority: e.target.value })}
                className="edit-task-input"
              >
                <option value="Low">Low</option>
                <option value="Medium">Medium</option>
                <option value="High">High</option>
                <option value="Critical">Critical</option>
              </select>
              <input
                type="number"
                value={task?.hours || 0}
                onChange={(e) => setTask({ ...task, hours: e.target.value })}
                className="edit-task-input"
                placeholder="Thời gian ước tính (giờ)"
              />
            </div>
            <div className="modal-footer">
              <button className="action-btn" onClick={() => setIsModalOpen(false)}>
                ❌ Hủy
              </button>
              <button className="action-btn primary" onClick={saveTask}>
                💾 Lưu
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modal xác nhận hoàn thành công việc */}
      {isConfirmModalOpen && (
        <div className="confirm-modal-overlay">
          <div className="confirm-modal-content">
            <div className="confirm-modal-header">
              Bạn có muốn hoàn thành công việc này không?
            </div>
            <div className="confirm-modal-footer">
              <button
                className="confirm-modal-btn cancel"
                onClick={() => setIsConfirmModalOpen(false)}
              >
                Hủy
              </button>
              <button
                className="confirm-modal-btn confirm"
                onClick={confirmCompleteTask}
              >
                Xác nhận
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default TaskDetail;
