import React, { useState, useEffect } from 'react';
import '../../styles/forms/createtask.css';
import {createTask} from '../../services/taskService';
import { getProjectById } from '../../services/projectService';
import { useLocation } from 'react-router-dom';

const CreateTask = () => {
  const [files, setFiles] = useState([]);
  const [currentTime, setCurrentTime] = useState(new Date().toLocaleTimeString('vi-VN'));
  const location = useLocation();
  const { projectId } = location.state;
  const [project, setProject] = useState(null);
  const [projectMembers, setProjectMembers] = useState([]);
  const currentUser = JSON.parse(localStorage.getItem("user"));

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date().toLocaleTimeString('vi-VN'));
    }, 60000);
    return () => clearInterval(timer);
  }, []);

  const handleFileChange = (e) => {
    const newFiles = Array.from(e.target.files);
    setFiles([...files, ...newFiles]);
  };

  const removeFile = (index) => {
    setFiles(files.filter((_, i) => i !== index));
  };

  const resetForm = () => {
    document.querySelector('.task-form').reset();
    setFiles([]);
  };

  // lấy thông in project để hiển thị
  useEffect(() => {
    const fetchProject = async () => {
      try {
        const res = await getProjectById(projectId);
        setProject(res.project);
        setProjectMembers(res.project.members || []);
        // Hiển thị thông tin dự án
        console.log('Thông tin dự án:', res.project);
      } catch (error) {
        console.error('Lỗi khi lấy thông tin dự án:', error);
      }
    };

    fetchProject();
  }, [projectId]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    const form = e.target;

    const task = {
      project_id: projectId,
      name: form.taskName.value.trim(),
      description: form.taskDescription.value.trim() || null,
      due_date: form.taskDueDate.value,
      status: form.taskStatus.value,
      priority: form.taskPriority.value,
      assigned_to_id: form.assignedToId.value || null,
      hours: parseInt(form.taskHours.value) || 0,
      attachments: files.map((file) => file.name).join(',') || null,
    };

    // Kiểm tra các trường bắt buộc
    if (!task.name) return alert('Vui lòng nhập tên công việc');
    if (!task.project_id) return alert('Vui lòng chọn dự án');
    if (!task.due_date) return alert('Vui lòng chọn hạn chót');

    try {
      console.log('Dữ liệu gửi lên:', task);
      await createTask(task); // Gọi API tạo task
      // Lưu task vào localStorage
      const storedTasks = localStorage.getItem("alltasks");
      const tasks = storedTasks ? JSON.parse(storedTasks) : [];
      const updatedTasks = [...tasks, task];
      localStorage.setItem("alltasks", JSON.stringify(updatedTasks)); // Cập nhật localStorage
      alert('Task đã được tạo thành công!');
      resetForm();
      window.location.href = `/tasks/${projectId}`; // Chuyển hướng đến trang danh sách task
    } catch (error) {
      console.error('Lỗi khi tạo task:', error.response?.data || error.message);
      alert('Không thể tạo task. Vui lòng thử lại!');
    }
  };

  const cancelTask = () => {
  window.history.back(); // Quay lại trang trước
};

  return (
    <div>
      <main className="main-content-create-task">
        <form className="task-form" onSubmit={handleSubmit}>
          <div className="form-header">
            <h1 className="form-title">Tạo Task Mới</h1>
            <div className="form-actions">
              <button type="button" className="action-btn" onClick={cancelTask}>Hủy</button>
              <button type="submit" className="action-btn primary">Tạo Task</button>
            </div>
          </div>

          <div className="form-section">
            <div className="form-group">
              <label className="form-label">Tên công việc</label>
              <input type="text" className="form-input" id="taskName" name="taskName" placeholder="Nhập tên công việc" maxLength="200" />
            </div>
            <div className="form-group">
              <label className="form-label">Mô tả</label>
              <textarea className="form-textarea" id="taskDescription" name="taskDescription" placeholder="Nhập mô tả công việc"></textarea>
            </div>
          </div>

          <div className="form-section">
            <h3 className="section-title">Thông tin chi tiết</h3>
            <div className="form-grid">
              <div className="form-group">
                <label className="form-label">Trạng thái</label>
                <select className="form-select" id="taskStatus" name="taskStatus">
                  <option value="To Do">Chưa làm</option>
                  <option value="In Progress">Đang thực hiện</option>
                  <option value="In Review">Đang xem xét</option>
                  <option value="Blocked">Bị chặn</option>
                  <option value="Done">Hoàn thành</option>
                </select>
              </div>
              <div className="form-group">
                <label className="form-label">Độ ưu tiên</label>
                <select className="form-select" id="taskPriority" name="taskPriority">
                  <option value="Low">Thấp</option>
                  <option value="Medium">Trung bình</option>
                  <option value="High">Cao</option>
                  <option value="Critical">Rất cao</option>
                </select>
              </div>
              <div className="form-group">
                <label className="form-label">Người thực hiện</label>
                <select className="form-select" id="assignedToId" name="assignedToId">
                  <option value="">Chọn người thực hiện</option>
                  {projectMembers.map((member) => (
                    <option key={member._id} value={member._id}>
                      {member.full_name} ({member.email})
                    </option>
                  ))}
                </select>
              </div>
              <div className="form-group">
                <label className="form-label">Hạn chót</label>
                <input type="date" className="form-input" id="taskDueDate" name="taskDueDate" />
              </div>
              <div className="form-group">
                <label className="form-label">Số giờ dự kiến</label>
                <input type="number" className="form-input" id="taskHours" name="taskHours" placeholder="Số giờ" min="0" />
              </div>
            </div>
          </div>

          <div className="form-section">
            <h3 className="section-title">Tệp đính kèm</h3>
            <div className="file-upload">
              <input type="file" id="fileInput" multiple onChange={handleFileChange} />
              <label className="file-upload-label" htmlFor="fileInput">Chọn tệp để tải lên</label>
              <div className="uploaded-files">
                {files.map((file, index) => (
                  <div key={index} className="uploaded-file">
                    <div className="file-icon">📎</div>
                    <div className="file-info">
                      <div className="file-name">{file.name}</div>
                      <div className="file-size">{(file.size / 1024).toFixed(1)} KB</div>
                    </div>
                    <button type="button" className="remove-file-btn" onClick={() => removeFile(index)}>🗑️</button>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </form>

        <aside className="sidebar">
          <div className="sidebar-card">
            <h3 className="section-title">Thông tin người tạo</h3>
            <div className="meta-item">
              <span className="meta-label">Người tạo</span>
              <div className="meta-value">
                <div className="assignee-info">
                  <div className="assignee-avatar">{currentUser.full_name.split(" ")[0][0]}{currentUser.full_name.split(" ").slice(-1)[0][0]}</div>
                  <span>{currentUser.full_name}</span>
                </div>
              </div>
            </div>
            <div className="meta-item">
              <span className="meta-label">Ngày tạo</span>
              <div className="meta-value">Hôm nay, <span>{currentTime}</span></div>
            </div>
          </div>
          <div className="sidebar-card">
            <h3 className="section-title">Thông tin Dự án</h3>
            <div className="meta-item">
              <span className="meta-label">Tên Dự án</span>
              <div className="meta-value">{project?.name || 'Đang tải...'}</div>
            </div>
            <div className="meta-item">
              <span className="meta-label">Người tạo</span>
              <div className="meta-value">{project?.owner_id.full_name || 'Đang tải...'}</div>
            </div>
            <div className="meta-item">
              <span className="meta-label">Hạn chót</span>
              <div className="meta-value">{new Date(project?.end_date).toLocaleDateString() || 'Đang tải...'}</div>
            </div>
            <div className="meta-item">
              <span className="meta-label">Trạng thái</span>
              <div className="meta-value">{project?.status || 'Đang tải...'}</div>
            </div>
            <div className="meta-item">
              <span className="meta-label">Độ ưu tiên</span>
              <div className="meta-value">{project?.priority || 'Đang tải...'}</div>
            </div>
          </div>
        </aside>
        
      </main>
    </div>
  );
};

export default CreateTask;
