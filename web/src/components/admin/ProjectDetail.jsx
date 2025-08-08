import React, { useEffect, useState } from 'react';
import './projectdetail.css';
import { getProjectById } from '../../services/projectService';
import { useNavigate, useParams } from 'react-router-dom';
import { getAllTasks } from '../../services/taskService';

const ProjectDetail = () => {
  const { id } = useParams();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [project, setProject] = useState(null);
  const [tasks, setTasks] = useState([]);

  useEffect(() => {
    const fetchProjectData = async () => {
      const data = await getProjectById(id);
      setProject(data.project);
      console.log('Fetched project:', data.project);
    };

    const fetchTasks = async () => {
      const data = await getAllTasks(id);
      setTasks(data.tasks);
      console.log('Fetched tasks:', data.tasks);
    };

    fetchProjectData();
    fetchTasks();
  }, [id]);

  const openModal = () => {
    setIsModalOpen(true);
    console.log('Modal opened:', isModalOpen);
  };

  const closeModal = () => {
    setIsModalOpen(false);
  };

  const handleSaveModal = (e) => {
    const btn = e.target;
    btn.style.background = 'linear-gradient(135deg, #4CAF50, #45a049)';
    btn.textContent = 'Đang lưu...';
    setTimeout(() => {
      btn.style.background = 'linear-gradient(135deg, #667eea, #764ba2)';
      btn.textContent = 'Lưu';
      closeModal();
    }, 1500);
  };

  if (!project) {
    return <div>Đang tải dữ liệu...</div>;
  }

  return (
    <>
      <main className="main-content-admin-project-detail">
        <div className="project-section">
          <div className="project-header">
            <div className="project-info">
              <h1>{project.name}</h1>
              <p>Người phụ trách: {project.owner_id?.full_name || 'N/A'}</p>
              <span className={`status-badge status-${project.status.toLowerCase()}`}>
                {project.status === 'Completed' ? 'Hoàn thành' : project.status}
              </span>
            </div>
            <div className="action-buttons">
              <button className="edit-btn" onClick={openModal}>Sửa dự án</button>
            </div>
          </div>
          <div className="project-details">
            <p><strong>Tiến độ:</strong> {project.progress}%</p>
            <div className="progress-bar">
              <div className="progress-fill" style={{ width: `${project.progress}%` }}></div>
            </div>
            <p><strong>Hạn chót:</strong> {new Date(project.end_date).toLocaleDateString()}</p>
            <p><strong>Số task:</strong> {tasks.length}</p>
            <p><strong>Ngân sách:</strong> {project.budget.toLocaleString()} VNĐ</p>
            <p><strong>Mô tả:</strong> {project.description}</p>
          </div>
        </div>

        <div className="section-card">
          <div className="section-header">
            <h2 className="section-title">Thành viên dự án</h2>
          </div>
          <div className="table-container">
            <table>
              <thead>
                <tr>
                  <th>Tên</th>
                  <th>Vai trò</th>
                  <th>Email</th>
                </tr>
              </thead>
              <tbody>
                {project.members.map((member, index) => (
                  <tr key={index}>
                    <td>{member.full_name}</td>
                    <td>{member.role}</td>
                    <td>{member.email}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        <div className="section-card">
          <div className="section-header">
            <h2 className="section-title">Danh sách Task</h2>
          </div>
          <div className="table-container">
            <table>
              <thead>
                <tr>
                  <th>Tên Task</th>
                  <th>Người thực hiện</th>
                  <th>Tiến độ</th>
                  <th>Hạn chót</th>
                  <th>Trạng thái</th>
                </tr>
              </thead>
              <tbody>
                {tasks.map((task, index) => (
                  <tr key={index}>
                    <td>{task.name}</td>
                    <td>{task.assigned_to_id?.full_name || 'N/A'}</td>
                    <td>
                      <div className="progress-bar">
                        <div className="progress-fill" style={{ width: `${task.progress}%` }}></div>
                      </div>
                    </td>
                    <td>{new Date(task.due_date).toLocaleDateString()}</td>
                    <td>
                      <span className={`status-badge status-${task.status.toLowerCase()}`}>
                        {task.status}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {isModalOpen && (
          <div className="modal">
            <div className="modal-content">
              <span className="close-btn" onClick={closeModal}>&times;</span>
              <h2 className="section-title">Sửa Dự án</h2>
              <div className="modal-form">
                <label>Tên dự án</label>
                <input type="text" defaultValue={project.name} />
                <label>Người phụ trách</label>
                <select defaultValue={project.owner_id?._id}>
                  {project.members.map((member) => (
                    <option key={member._id} value={member._id}>
                      {member.full_name}
                    </option>
                  ))}
                </select>
                <label>Hạn chót</label>
                <input type="date" defaultValue={new Date(project.end_date).toISOString().split('T')[0]} />
                <label>Ngân sách (VNĐ)</label>
                <input type="number" defaultValue={project.budget} />
                <label>Trạng thái</label>
                <select defaultValue={project.status.toLowerCase()}>
                  <option value="progress">Đang thực hiện</option>
                  <option value="overdue">Quá hạn</option>
                  <option value="completed">Hoàn thành</option>
                </select>
                <label>Mô tả</label>
                <textarea defaultValue={project.description}></textarea>
                <button className="action-btn" onClick={handleSaveModal}>Lưu</button>
              </div>
            </div>
          </div>
        )}
      </main>
    </>
  );
};

export default ProjectDetail;
