const Project = require('../models/Project');
const { createNotification } = require('../services/notificationService');

const getAllProjects = async (req, res) => {
  try {
    const { page = 1, limit = 10, status, search } = req.query;
    const query = {};

    // Filter by user role
    if (req.user.role === 'Employee'|| req.user.role === 'Project Manager') {
      query.$or = [
        { owner_id: req.user._id },
        { members: req.user._id }
      ];
    }

    // Add status filter
    if (status && status !== 'all') {
      query.status = status;
    }

    // Add search filter
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } }
      ];
    }

    // Don't show archived projects by default
    query.is_archived = false;

    const projects = await Project.find(query)
      .populate('owner_id', 'username full_name email')
      .populate('members', 'username full_name email role')
      .sort({ created_at: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await Project.countDocuments(query);

    res.json({
      projects,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getProjectById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const project = await Project.findById(id)
      .populate('owner_id', 'username full_name email role')
      .populate('members', 'username full_name email role avatar');

    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }

    // Check if user has access to this project
    const hasAccess = req.user.role === 'Admin' || 
                     project.owner_id._id.toString() === req.user._id.toString() ||
                     project.members.some(member => member._id.toString() === req.user._id.toString());

    if (!hasAccess) {
      return res.status(403).json({ message: 'Access denied to this project' });
    }

    res.json({
      project
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createProject = async (req, res) => {
  try {
    const projectData = {
      ...req.body,
      owner_id: req.user._id
    };

    // Ensure owner is included in members
    if (!projectData.members) {
      projectData.members = [req.user._id];
    } else if (!projectData.members.includes(req.user._id.toString())) {
      projectData.members.push(req.user._id);
    }

    const project = await Project.create(projectData);
    
    const populatedProject = await Project.findById(project._id)
      .populate('owner_id', 'username full_name email')
      .populate('members', 'username full_name email role');

    // Send notifications to all members
    const memberIds = project.members.filter(id => id.toString() !== req.user._id.toString());
    for (const memberId of memberIds) {
      await createNotification({
        user_id: memberId,
        type: 'project_updated',
        title: 'Added to New Project',
        message: `You have been added to project: ${project.name}`,
        related_entity: {
          entity_type: 'Project',
          entity_id: project._id
        }
      });
    }

    res.status(201).json({
      message: 'Project created successfully',
      project: populatedProject
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const updateProject = async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;

    const project = await Project.findById(id);
    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }

    // Check permissions
    const canUpdate = req.user.role === 'Admin' || 
                     project.owner_id.toString() === req.user._id.toString();

    if (!canUpdate) {
      return res.status(403).json({ message: 'Permission denied' });
    }

    const updatedProject = await Project.findByIdAndUpdate(
      id,
      updates,
      { new: true, runValidators: true }
    ).populate('owner_id', 'username full_name email')
     .populate('members', 'username full_name email role');


    res.json({
      message: 'Project updated successfully',
      project: updatedProject
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const deleteProject = async (req, res) => {
  try {
    const { id } = req.params;

    const project = await Project.findById(id);
    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }

    // Check permissions - only admin or owner can delete
    const canDelete = req.user.role === 'Admin' || 
                     project.owner_id.toString() === req.user._id.toString();

    if (!canDelete) {
      return res.status(403).json({ message: 'Permission denied' });
    }

    // Soft delete by archiving
    await Project.findByIdAndUpdate(id, { is_archived: true });

    res.json({ message: 'Project archived successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const addMember = async (req, res) => {
  try {
    const { id } = req.params;
    const { user_id } = req.body;

    const project = await Project.findById(id);
    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }

    // Check permissions
    const canAddMember = req.user.role === 'Admin' || 
                        project.owner_id.toString() === req.user._id.toString();

    if (!canAddMember) {
      return res.status(403).json({ message: 'Permission denied' });
    }

    // Check if user is already a member
    if (project.members.includes(user_id)) {
      return res.status(400).json({ message: 'User is already a member' });
    }

    project.members.push(user_id);
    await project.save();

    const updatedProject = await Project.findById(id)
      .populate('members', 'username full_name email role');

    // Notify the new member
    // await createNotification({
    //   user_id,
    //   type: 'project_updated',
    //   title: 'Added to Project',
    //   message: `You have been added to project: ${project.name}`,
    //   related_entity: {
    //     entity_type: 'Project',
    //     entity_id: project._id
    //   }
    // });

    res.json({
      message: 'Member added successfully',
      project: updatedProject
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const removeMember = async (req, res) => {
  try {
    const { id, user_id } = req.params;

    const project = await Project.findById(id);
    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }

    // Check permissions
    const canRemoveMember = req.user.role === 'Admin' || 
                           project.owner_id.toString() === req.user._id.toString() ;

    if (!canRemoveMember) {
      return res.status(403).json({ message: 'Permission denied' });
    }

    // Cannot remove owner
    if (project.owner_id.toString() === user_id) {
      return res.status(400).json({ message: 'Cannot remove project owner' });
    }

    project.members = project.members.filter(member => member.toString() !== user_id);
    await project.save();
    res.json({ message: 'Member removed successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getAllProjects,
  getProjectById,
  createProject,
  updateProject,
  deleteProject,
  addMember,
  removeMember
};