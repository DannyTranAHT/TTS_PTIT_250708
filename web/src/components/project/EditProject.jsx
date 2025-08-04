import React, { useState, useEffect, useRef } from 'react';
import '../../styles/project/EditProject.css';
import { getProjectById, updateProject } from '../../services/projectService';
import { getAllUsers } from '../../services/userService';
import { useParams, useNavigate } from 'react-router-dom';

const EditProject = () => {
  const { id } = useParams(); // Lấy ID dự án từ URL
  const navigate = useNavigate();
  const [projectData, setProjectData] = useState(null);
  const [availableMembers, setAvailableMembers] = useState([]);
  const [selectedMembers, setSelectedMembers] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [showResults, setShowResults] = useState(false);
  const searchRef = useRef(null);

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

  useEffect(() => {
    const fetchProject = async () => {
      try {
        const res = await getProjectById(id);
        setProjectData(res.project);
        console.log('Project data:', res.project);
        setSelectedMembers(res.project.members.map((member) => member._id));
        console.log('Selected members:', res.project.members.map((member) => member._id));
      } catch (error) {
        console.error('Lỗi khi lấy thông tin dự án:', error);
      }
    };

    const fetchUsers = async () => {
      try {
        const res = await getAllUsers();
        setAvailableMembers(res.users);
      } catch (error) {
        console.error('Lỗi khi lấy danh sách người dùng:', error);
      }
    };

    fetchProject();
    fetchUsers();
  }, [id]);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setProjectData({ ...projectData, [name]: value });
  };

  const handleAddMember = (memberId) => {
    if (!selectedMembers.includes(memberId)) {
      setSelectedMembers([...selectedMembers, memberId]);
      setSearchTerm('');
    }
  };

  const handleRemoveMember = (memberId) => {
    setSelectedMembers(selectedMembers.filter((id) => id !== memberId));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    // Chuẩn bị dữ liệu cập nhật
    const updatedProject = {
      name: projectData.name,
      description: projectData.description,
      start_date: projectData.start_date,
      end_date: projectData.end_date,
      status: projectData.status,
      priority: projectData.priority,
      members: selectedMembers, // Chỉ gửi danh sách _id
      progress: projectData.progress || 0, // Nếu không có, mặc định là 0
      budget: projectData.budget || 0, // Nếu không có, mặc định là 0
    };

    try {
      await updateProject(id, updatedProject);
      alert('Dự án đã được cập nhật thành công!');
      navigate('/projects');
    } catch (error) {
      console.error('Lỗi khi cập nhật dự án:', error);
      alert('Có lỗi xảy ra khi cập nhật dự án. Vui lòng thử lại!');
    }
  };

  if (!projectData) {
    return <div>Đang tải dữ liệu...</div>;
  }

  return (
    <main className="main-content-create-project">
      <div className="edit-project">
        <form id="editProjectForm" onSubmit={handleSubmit}>
          <div className="page-header">
            <h1 className="page-title">Chỉnh sửa Dự án</h1>
          </div>
          <div className="form-group">
            <label htmlFor="projectName">Tên Dự án</label>
            <input
              type="text"
              id="projectName"
              name="name"
              value={projectData.name || ''}
              onChange={handleInputChange}
              required
              maxLength="100"
              placeholder="Nhập tên dự án..."
            />
          </div>

          <div className="form-group">
            <label htmlFor="projectDescription">Mô tả</label>
            <textarea
              id="projectDescription"
              name="description"
              value={projectData.description || ''}
              onChange={handleInputChange}
              placeholder="Mô tả chi tiết dự án..."
            ></textarea>
          </div>

          <div className="form-group">
            <label htmlFor="startDate">Ngày Bắt đầu</label>
            <input
              type="date"
              id="startDate"
              name="start_date"
              value={projectData.start_date ? new Date(projectData.start_date).toISOString().split('T')[0] : ''}
              onChange={handleInputChange}
            />
          </div>

          <div className="form-group">
            <label htmlFor="endDate">Hạn Hoàn thành</label>
            <input
              type="date"
              id="endDate"
              name="end_date"
              value={projectData.end_date ? new Date(projectData.end_date).toISOString().split('T')[0] : ''}
              onChange={handleInputChange}
            />
          </div>

          <div className="form-group">
            <label htmlFor="projectStatus">Trạng thái</label>
            <select
              id="projectStatus"
              name="status"
              value={projectData.status || ''}
              onChange={handleInputChange}
            >
              <option value="Not Started">Chưa bắt đầu</option>
              <option value="In Progress">Đang thực hiện</option>
              <option value="Completed">Hoàn thành</option>
            </select>
          </div>

          <div className="form-group">
            <label htmlFor="projectPriority">Mức độ ưu tiên</label>
            <select
              id="projectPriority"
              name="priority"
              value={projectData.priority || 'Medium'}
              onChange={handleInputChange}
            >
              <option value="Low">Thấp</option>
              <option value="Medium">Trung bình</option>
              <option value="High">Cao</option>
              <option value="Critical">Khẩn cấp</option>
            </select>
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
                if (!member) return null;
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

          <div className="form-group">
            <label htmlFor="projectBudget">Ngân sách (VND)</label>
            <input
              type="number"
              id="projectBudget"
              name="budget"
              value={
                projectData.budget && projectData.budget.$numberDecimal
                    ? parseFloat(projectData.budget.$numberDecimal.toString())
                    : projectData.budget || ''
                }
              onChange={handleInputChange}
              min="0"
              step="500"
              placeholder="Nhập ngân sách..."
            />
          </div>

          <div className="form-actions">
            <button type="submit" className="submit-btn">
              Lưu thay đổi
            </button>
            <button
              type="button"
              className="cancel-btn"
              onClick={() => navigate('/projects')}
            >
              Hủy
            </button>
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
                  <div className="assignee-avatar">{projectData.owner_id.full_name.split(" ")[0][0]}{projectData.owner_id.full_name.split(" ").slice(-1)[0][0]}</div>
                  <span>{projectData.owner_id.full_name}</span>
                </div>
              </div>
            </div>
            <div className="meta-item">
              <span className="meta-label">Ngày tạo</span>
              <div className="meta-value"><span>{new Date(projectData.created_at).toLocaleString()}</span></div>
            </div>
          </div>
        </aside>
    </main>
  );
};

export default EditProject;