import React, { useState, useEffect } from 'react';
import '../../styles/forms/createtask.css';
import {createTask} from '../../services/taskService';

const CreateTask = () => {
  const [files, setFiles] = useState([]);
  const [currentTime, setCurrentTime] = useState(new Date().toLocaleTimeString('vi-VN'));

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

  const createTask = async () => {
    const task = {
      project_id: document.getElementById('projectId').value.trim(),
      name: document.getElementById('taskName').value.trim(),
      description: document.getElementById('taskDescription').value.trim() || null,
      due_date: document.getElementById('taskDueDate').value,
      status: document.getElementById('taskStatus').value,
      priority: document.getElementById('taskPriority').value,
      assigned_to_id: document.getElementById('assignedToId').value || null,
      hours: parseInt(document.getElementById('taskHours').value) || 0,
      attachments: JSON.stringify(
        files.map(file => ({ name: file.name, size: (file.size / 1024).toFixed(1) + ' KB' }))
      )
    };

    // Kiểm tra các trường bắt buộc
    if (!task.name) return alert('Vui lòng nhập tên công việc');
    if (!task.project_id) return alert('Vui lòng chọn dự án');
    if (!task.due_date) return alert('Vui lòng chọn hạn chót');

    try {
      console.log('Dữ liệu gửi lên:', task);
      await createTask(task); // Gọi API tạo task
      alert('Task đã được tạo thành công!');
      resetForm();
    } catch (error) {
      console.error('Lỗi khi tạo task:', error.response?.data || error.message);
      alert('Không thể tạo task. Vui lòng thử lại!');
    }
  };

  const cancelTask = () => {
    if (window.confirm('Bạn có chắc muốn hủy? Các thay đổi sẽ không được lưu.')) {
      resetForm();
    }
  };

  return (
    <div>
      <main className="main-content-create-task">
        <form className="task-form" onSubmit={(e) => e.preventDefault()}>
          <div className="form-header">
            <h1 className="form-title">Tạo Task Mới</h1>
            <div className="form-actions">
              <button type="button" className="action-btn" onClick={cancelTask}>Hủy</button>
              <button type="button" className="action-btn primary" onClick={createTask}>Tạo Task</button>
            </div>
          </div>

          <div className="form-section">
            <div className="form-group">
              <label className="form-label">Tên công việc</label>
              <input type="text" className="form-input" id="taskName" placeholder="Nhập tên công việc" maxLength="200" />
            </div>
            <div className="form-group">
              <label className="form-label">Mô tả</label>
              <textarea className="form-textarea" id="taskDescription" placeholder="Nhập mô tả công việc"></textarea>
            </div>
          </div>

          <div className="form-section">
            <h3 className="section-title">Thông tin chi tiết</h3>
            <div className="form-grid">
              <div className="form-group">
                <label className="form-label">Dự án</label>
                <input type="text" className="form-input" id="projectId" placeholder="Nhập ID dự án" />
              </div>
              <div className="form-group">
                <label className="form-label">Trạng thái</label>
                <select className="form-select" id="taskStatus">
                  <option value="To Do">Chưa làm</option>
                  <option value="In Progress">Đang thực hiện</option>
                  <option value="In Review">Đang xem xét</option>
                  <option value="Blocked">Bị chặn</option>
                  <option value="Done">Hoàn thành</option>
                </select>
              </div>
              <div className="form-group">
                <label className="form-label">Độ ưu tiên</label>
                <select className="form-select" id="taskPriority">
                  <option value="Low">Thấp</option>
                  <option value="Medium">Trung bình</option>
                  <option value="High">Cao</option>
                  <option value="Critical">Rất cao</option>
                </select>
              </div>
              <div className="form-group">
                <label className="form-label">Người thực hiện</label>
                <input type="text" className="form-input" id="assignedToId" placeholder="Nhập ID người thực hiện (nếu có)" />
              </div>
              <div className="form-group">
                <label className="form-label">Hạn chót</label>
                <input type="date" className="form-input" id="taskDueDate" />
              </div>
              <div className="form-group">
                <label className="form-label">Số giờ dự kiến</label>
                <input type="number" className="form-input" id="taskHours" placeholder="Số giờ" min="0" />
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
                  <div className="assignee-avatar">NA</div>
                  <span>Nguyễn Văn A</span>
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
              <div className="meta-value">Dự án Mẫu</div>
            </div>
            <div className="meta-item">
              <span className="meta-label">Người thực hiện</span>
              <div className="meta-value">Nguyễn Văn A</div>
            </div>
            <div className="meta-item">
              <span className="meta-label">Hạn chót</span>
              <div className="meta-value">31/12/2023</div>
            </div>
            <div className="meta-item">
              <span className="meta-label">Trạng thái</span>
              <div className="meta-value">Đang thực hiện</div>
            </div>
            <div className="meta-item">
              <span className="meta-label">Độ ưu tiên</span>
              <div className="meta-value">Cao</div>
            </div>
          </div>
        </aside>
        
      </main>
    </div>
  );
};

export default CreateTask;
