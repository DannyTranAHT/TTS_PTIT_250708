const Task = require('../models/Task');
const Project = require('../models/Project');
const { createNotification } = require('../services/notificationService');

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
    const populatedTask = await Task.findById(task._id)
      .populate('project_id', 'name status')
      .populate('assigned_to_id', 'username full_name email avatar');

    if (task.assigned_to_id) {
      await createNotification({
        user_id: task.assigned_to_id,
        type: 'task_assigned',
        title: 'New Task Assigned',
        message: `You have been assigned a new task: ${task.name}`,
        related_entity: {
          entity_type: 'Task',
          entity_id: task._id
        }
      });
      const io = req.app.get('io');
      io.to(`user_${task.assigned_to_id}`).emit('task:assigned', {
        task: populatedTask,
        message: `New task assigned: ${task.name}`
      });
    }
    res.status(201).json({ message: 'Task created successfully', task });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Lấy tất cả task của 1 project kèm phân trang + populate + quyền truy cập
const getAllTasks = async (req, res) => {
  try {
    const { project_id } = req.params;
    const { page = 1, limit = 10, status, priority } = req.query;

    const project = await Project.findById(project_id);
    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }

    // Kiểm tra quyền
    const isMember = project.owner_id.toString() === req.user._id.toString() ||
      project.members.map(m => m.toString()).includes(req.user._id.toString()) ||
      req.user.role === 'Admin';
    if (!isMember) {
      return res.status(403).json({ message: 'Permission denied' });
    }

    // Query filter
    const query = { project_id };
    if (status) query.status = status;
    if (priority) query.priority = priority;

    const total = await Task.countDocuments(query);
    const tasks = await Task.find(query)
      .populate('assigned_to_id', 'username full_name email avatar')
      .sort({ due_date: 1 }) // Sắp xếp theo hạn
      .skip((page - 1) * limit)
      .limit(parseInt(limit));

    res.json({
      tasks,
      total,
      currentPage: parseInt(page),
      totalPages: Math.ceil(total / limit)
    });
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

// Cập nhật task
const updateTask = async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;
    const task = await Task.findById(id);
    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }
    const project = await Project.findById(task.project_id);
    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }
    // Chỉ người tạo task mới được cập nhật
    if (task.createdBy && task.createdBy.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Only the creator can update this task' });
    }
    // Không cho cập nhật project_id trực tiếp qua API này
    delete updates.project_id;
    const updatedTask = await Task.findByIdAndUpdate(id, updates, { new: true, runValidators: true });
    
    const populatedTask = await Task.findById(task._id)
      .populate('project_id', 'name status')
      .populate('assigned_to_id', 'username full_name email avatar');

    if (task.assigned_to_id) {
      await createNotification({
        user_id: task.assigned_to_id,
        type: 'task_assigned',
        title: 'New Task Assigned',
        message: `You have been assigned a new task: ${task.name}`,
        related_entity: {
          entity_type: 'Task',
          entity_id: task._id
        }
      });
      const io = req.app.get('io');
      io.to(`user_${task.assigned_to_id}`).emit('task:assigned', {
        task: populatedTask,
        message: `New task assigned: ${task.name}`
      });
    }
 
    res.json({ message: 'Task updated successfully', task: updatedTask });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


// gửi yêu cầu hoàn thành task
const requestCompleteTask = async (req, res) => {
  try {
    const { id } = req.params;
    const task = await Task.findById(id);
    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }
    // Chỉ người được giao mới gửi yêu cầu hoàn thành
    if (!task.assigned_to_id || task.assigned_to_id.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Only assignee can request completion' });
    }
    // Đánh dấu trạng thái yêu cầu hoàn thành (dùng status hoặc thêm trường tạm thời)
    task.status = 'In Review';
    await task.save();
    
    await createNotification({
      user_id: task.createdBy,
      type: 'task_completion_requested',
      title: 'Task Completion Requested',
      message: `Task ${task.name} has been requested for completion by ${req.user.username}`,
      related_entity: {
        entity_type: 'Task',
        entity_id: task._id
      }
    });

    res.json({ message: 'Completion request sent. Waiting for confirmation from creator.', task });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// xác nhận hoàn thành hoặc không hoàn thành
const confirmCompleteTask = async (req, res) => {
  try {
    const { id } = req.params;
    const { confirm } = req.body; // true: hoàn thành, false: không hoàn thành
    const task = await Task.findById(id);
    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }
    // Chỉ creator mới xác nhận
    if (!task.createdBy || task.createdBy.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Only creator can confirm completion' });
    }
    if (task.status !== 'In Review') {
      return res.status(400).json({ message: 'Task must be in review before confirmation' });
    }
    if (confirm === true) {
      task.status = 'Done';
      await createNotification({
        user_id: task.assigned_to_id,
        type: 'task_completed',
        title: 'Task Completed',
        message: `Task ${task.name} has been confirmed as completed by ${req.user.username}`,
        related_entity: {
          entity_type: 'Task',
          entity_id: task._id
        }
      });
    } else {
      task.status = 'Blocked';
      await createNotification({
        user_id: task.assigned_to_id,
        type: 'task_not_completed',
        title: 'Task Not Completed',
        message: `Task ${task.name} has been marked as not completed by ${req.user.username}`,
        related_entity: {
          entity_type: 'Task',
          entity_id: task._id
        }
      });
    }
    await task.save();
    
    
    res.json({ message: confirm ? 'Task confirmed as completed.' : 'Task marked as not completed.', task });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getMyTasks = async (req, res) => {
  try {
    const { page = 1, limit = 10, status, priority } = req.query;

    const query = {
      assigned_to_id: req.user._id
    };

    if (status) query.status = status;
    if (priority) query.priority = priority;

    const total = await Task.countDocuments(query);

    const tasks = await Task.find(query)
      .populate('project_id', 'name status')
      .populate('assigned_to_id', 'username full_name email avatar')
      .sort({ due_date: 1 })
      .skip((page - 1) * limit)
      .limit(parseInt(limit));

    // phần thống kê 
    const completedTasks = await Task.countDocuments({
      assigned_to_id: req.user._id,
      status: 'Completed'
    });

    const today = new Date();

    const overdueTasks = await Task.countDocuments({
      assigned_to_id: req.user._id,
      due_date: { $lt: today },
      status: { $ne: 'Completed' }
    });

    res.json({
      tasks,
      total,
      currentPage: parseInt(page),
      totalPages: Math.ceil(total / limit),
      completedTasks,
      overdueTasks
    });

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};



module.exports = {
  createTask,
  getAllTasks,
  getTaskById,
  assignMemberToTask,
  unassignMemberFromTask,
  updateTask,
  requestCompleteTask,
  confirmCompleteTask,
  getMyTasks
};
