const Task = require('../models/Task');
const Project = require('../models/Project');

// Tạo task mới cho 1 project
const createTask = async (req, res) => {
  try {
    const { project_id, name, description, due_date, status, priority, assigned_to_id, hours, attachments } = req.body;

    const project = await Project.findById(project_id);
    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }
    // Chỉ owner, admin hoặc thành viên mới được tạo task
    const isMember = project.owner_id.toString() === req.user._id.toString() ||
      project.members.map(m => m.toString()).includes(req.user._id.toString()) ||
      req.user.role === 'Admin';
    if (!isMember) {
      return res.status(403).json({ message: 'Permission denied' });
    }

    const task = await Task.create({
      project_id,
      name,
      description,
      due_date,
      status,
      priority,
      assigned_to_id,
      hours,
      attachments
    });
    res.status(201).json({ message: 'Task created successfully', task });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Lấy tất cả task của 1 project
const getAllTasks = async (req, res) => {
  try {
    const { project_id } = req.params;
    const project = await Project.findById(project_id);
    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }
    // Chỉ thành viên, owner, admin mới xem được
    const isMember = project.owner_id.toString() === req.user._id.toString() ||
      project.members.map(m => m.toString()).includes(req.user._id.toString()) ||
      req.user.role === 'Admin';
    if (!isMember) {
      return res.status(403).json({ message: 'Permission denied' });
    }
    const tasks = await Task.find({ project_id });
    res.json({ tasks });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Lấy task theo id
const getTaskById = async (req, res) => {
  try {
    const { id } = req.params;
    const task = await Task.findById(id);
    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }
    // Kiểm tra quyền truy cập project
    const project = await Project.findById(task.project_id);
    const isMember = project.owner_id.toString() === req.user._id.toString() ||
      project.members.map(m => m.toString()).includes(req.user._id.toString()) ||
      req.user.role === 'Admin';
    if (!isMember) {
      return res.status(403).json({ message: 'Permission denied' });
    }
    res.json({ task });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Gán người làm cho task
const assignMemberToTask = async (req, res) => {
  try {
    const { id } = req.params; // id của task
    const { user_id } = req.body; // id của user muốn gán
    const task = await Task.findById(id);
    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }
    const project = await Project.findById(task.project_id);
    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }
    // Chỉ owner, admin hoặc thành viên mới được gán
    const isMember = project.owner_id.toString() === req.user._id.toString() ||
      project.members.map(m => m.toString()).includes(req.user._id.toString()) ||
      req.user.role === 'Admin';
    if (!isMember) {
      return res.status(403).json({ message: 'Permission denied' });
    }
    // Chỉ gán cho thành viên trong project
    const isTargetMember = project.owner_id.toString() === user_id ||
      project.members.map(m => m.toString()).includes(user_id);
    if (!isTargetMember) {
      return res.status(400).json({ message: 'User is not a member of this project' });
    }
    task.assigned_to_id = user_id;
    await task.save();
    res.json({ message: 'Assigned member to task successfully', task });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Xóa người làm khỏi task
const unassignMemberFromTask = async (req, res) => {
  try {
    const { id } = req.params; // id của task
    const task = await Task.findById(id);
    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }
    const project = await Project.findById(task.project_id);
    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }
    // Chỉ owner, admin hoặc thành viên mới được xóa
    const isMember = project.owner_id.toString() === req.user._id.toString() ||
      project.members.map(m => m.toString()).includes(req.user._id.toString()) ||
      req.user.role === 'Admin';
    if (!isMember) {
      return res.status(403).json({ message: 'Permission denied' });
    }
    task.assigned_to_id = null;
    await task.save();
    res.json({ message: 'Unassigned member from task successfully', task });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  createTask,
  getAllTasks,
  getTaskById,
  assignMemberToTask,
  unassignMemberFromTask
};
