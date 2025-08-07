import React, { useState, useEffect, useRef } from 'react';
import '../../styles/forms/createproject.css';
import { getAllUsers } from '../../services/userService';
import { createProject } from '../../services/projectService';
import { useParams } from 'react-router-dom';


const CreateProject = () => {
  const currentUser = JSON.parse(localStorage.getItem("user"));
  const [availableMembers, setAvailableMembers] = useState([]);
  const [selectedMembers, setSelectedMembers] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [showResults, setShowResults] = useState(false);
  const searchRef = useRef(null);
  const [currentTime, setCurrentTime] = useState(new Date().toLocaleTimeString('vi-VN'));

  const filteredMembers = availableMembers.filter(
    (member) =>
      !selectedMembers.includes(member._id) &&
      (member.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
        member.full_name.toLowerCase().includes(searchTerm.toLowerCase()))
  );

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (searchRef.current && !searchRef.current.contains(e.target)) {
        setShowResults(false);
      }
    };
    document.addEventListener('click', handleClickOutside);
    return () => document.removeEventListener('click', handleClickOutside);
  }, []);

  const handleAddMember = (memberId) => {
    if (!selectedMembers.includes(memberId)) {
      setSelectedMembers([...selectedMembers, memberId]);
      setSearchTerm('');
    }
  };

  const handleRemoveMember = (memberId) => {
    setSelectedMembers(selectedMembers.filter((id) => id !== memberId));
  };

  const handleSubmit = async(e) => {
    e.preventDefault();
    const form = e.target;

    const newProject = {
      name: form.name.value, // Tên dự án
      description: form.description.value, // Mô tả
      start_date: form.start_date.value || null, // Ngày bắt đầu
      end_date: form.end_date.value, // Ngày kết thúc
      status: form.status.value, // Trạng thái
      priority: form.priority.value, // Mức độ ưu tiên
      members: selectedMembers, // Danh sách thành viên
      budget: parseFloat(form.budget.value) || 0, // Ngân sách
    };

    try {
    const response = await createProject(newProject); // Gửi dữ liệu đến API
    // Lấy danh sách projects từ localStorage
    const storedProjects = localStorage.getItem("projects");
    const projects = storedProjects ? JSON.parse(storedProjects) : [];

    // Thêm dự án mới vào danh sách
    const updatedProjects = [...projects, response.data.project];

    // Lưu danh sách cập nhật vào localStorage
    localStorage.setItem("projects", JSON.stringify(updatedProjects));
    alert('Dự án đã được tạo thành công!');
    window.location.href = '/projects'; // Chuyển hướng đến trang danh sách dự án
  } catch (error) {
    console.error('Error creating project:', error);
    alert('Có lỗi xảy ra khi tạo dự án. Vui lòng thử lại!');
  }
  };

  useEffect(() => {
    const fetchUsers = async () => {
      try {
        const users = await getAllUsers();
        console.log('Available Users:', users);
        setAvailableMembers(users.users);
      } catch (error) {
        console.error('Error fetching users:', error);
      }
    };

    fetchUsers();
  }, []);

  return (
    <>
      <main className="main-content-create-project">
        <div className="form-container">
          <form id="createProjectForm" onSubmit={handleSubmit}>
            <div className="page-header">
              <h1 className="page-title">Tạo Dự án Mới</h1>
            </div>
            <div className="form-group">
              <label htmlFor="projectName">Tên Dự án</label>
              <input type="text" id="projectName" name="name" required maxLength="100" placeholder="Nhập tên dự án..." />
            </div>

            <div className="form-group">
              <label htmlFor="projectDescription">Mô tả</label>
              <textarea id="projectDescription" name="description" placeholder="Mô tả chi tiết dự án..."></textarea>
            </div>

            <div className="form-group">
              <label htmlFor="startDate">Ngày Bắt đầu</label>
              <input type="date" id="startDate" name="start_date" />
            </div>

            <div className="form-group">
              <label htmlFor="endDate">Hạn Hoàn thành</label>
              <input type="date" id="endDate" name="end_date" required />
            </div>

            <div className="form-group">
              <label htmlFor="projectStatus">Trạng thái</label>
              <select id="projectStatus" name="status">
                <option value="Not Started">Chưa bắt đầu</option>
                <option value="In Progress">Đang thực hiện</option>
                <option value="Completed">Hoàn thành</option>
                <option value="On Hold">Tạm dừng</option>
                <option value="Cancelled">Đã hủy</option>
              </select>
            </div>

            <div className="form-group">
              <label htmlFor="projectPriority">Mức độ ưu tiên</label>
              <select id="projectPriority" name="priority" defaultValue="Medium">
                <option value="Low">Thấp</option>
                <option value="Medium">Trung bình</option>
                <option value="High">Cao</option>
                <option value="Critical">Khẩn cấp</option>
              </select>
            </div>

            <div className="form-group">
              <label htmlFor="projectBudget">Ngân sách (VND)</label>
              <input type="number" id="projectBudget" name="budget" min="0" step="0.01" placeholder="Nhập ngân sách..." />
            </div>

            <div className="form-group">
              <label htmlFor="memberSearch">Thành viên (Tìm theo email)</label>
              <div className="member-search-container" ref={searchRef}>
                <input
                  type="text"
                  id="memberSearch"
                  className="member-search"
                  placeholder="Nhập email để tìm..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  onFocus={() => setShowResults(true)}
                />
                {showResults && filteredMembers.length > 0 && (
                  <div className="member-results">
                    {filteredMembers.map((member) => (
                      <div
                        key={member._id}
                        className="member-result-item"
                        onClick={() => handleAddMember(member._id)}
                      >
                        <div className="name">{member.full_name}</div>
                        <div className="email">{member.email}</div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
              <div className="selected-members">
                {selectedMembers.map((_id) => {
                  const member = availableMembers.find((m) => m._id === _id);
                  return (
                    <div key={_id} className="selected-member">
                      <div>
                        <div>{member.full_name}</div>
                        <div className="email">{member.email}</div>
                      </div>
                      <span className="remove-member" onClick={() => handleRemoveMember(_id)}>×</span>
                    </div>
                  );
                })}
              </div>
            </div>

            <div className="form-actions">
              <button type="submit" className="submit-btn">Tạo Dự án</button>
              <button type="button" className="cancel-btn" onClick={() => navigator('/projects')}>Hủy</button>
            </div>
          </form>
        </div>
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
        </aside>
        
      </main>
    </>
  );
};

export default CreateProject;
