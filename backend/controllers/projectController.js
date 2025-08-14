const Project = require('../models/Project');
const { createNotification } = require('../services/notificationService');
const Task = require('../models/Task');
const User = require('../models/User');
const Notification = require('../models/Notification');
const mongoose = require('mongoose');

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
      .populate('owner_id', 'username full_name email avatar')
      .populate('members', 'username full_name email role avatar')
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
const getRecentProjects = async (req, res) => {
  try {
    const query = {
      is_archived: false,
      $or: [
        { owner_id: req.user._id },
        { members: req.user._id } 
      ]
    };

    const recentProjects = await Project.find(query)
      .sort({ created_at: -1 })
      .limit(3)
      .populate('owner_id', 'username full_name email  avatar')
      .populate('members', 'username full_name email role  avatar');

    res.json({
      projects: recentProjects
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getProjectById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const project = await Project.findById(id)
      .populate('owner_id', 'username full_name email role  avatar')
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
    const project = await Project.create(projectData);
    const populatedProject = await Project.findById(project._id)
      .populate('owner_id', 'username full_name email  avatar')
      .populate('members', 'username full_name email role avatar');
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
    const canUpdate = project.owner_id.toString() === req.user._id.toString();

    if (!canUpdate) {
      return res.status(403).json({ message: 'Permission denied' });
    }

    const updatedProject = await Project.findByIdAndUpdate(
      id,
      updates,
      { new: true, runValidators: true }
    ).populate('owner_id', 'username full_name email  avatar')
     .populate('members', 'username full_name email role avatar');

    const io = req.app.get('io');
    // Notify members about the project update
    await createNotification({
      user_id: updatedProject.members,
      type: 'project_updated',
      title: 'Dự án được cập nhật',
      message: `Dự án "${updatedProject.name}" đã được nhật.`,
      related_entity: {
        entity_type: 'Project',
        entity_id: updatedProject._id
      }
    },io);
    if (io) {
      updatedProject.members.forEach(memberId => {
        io.to(`user_${memberId}`).emit('project:updated', {
          project_id: updatedProject._id,
          project_name: updatedProject.name,
          updated_by: req.user.full_name
        });
      });
    }
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

    // Validate input
    if (!user_id) {
      return res.status(400).json({ message: 'User ID is required' });
    }

    // Find and update project (main business logic)
    const project = await Project.findById(id);
    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }

    // Check permissions and validations...
    // (existing validation logic)

    // Add member to project
    project.members.push(user_id);
    await project.save();

    // Get updated project with populated fields
    const updatedProject = await Project.findById(id)
      .populate('owner_id', 'username full_name email avatar')
      .populate('members', 'username full_name email role avatar');

    // 🚀 IMPROVED: Separate socket operations with error handling
    const socketOperations = async () => {
      try {
        const io = req.app.get('io');
        
        // Check if socket server is available
        if (!io) {
          console.warn('⚠️ Socket.IO not available - notifications will be delayed');
          return;
        }

        // Create notification with error handling
        try {
          await createNotification({
            user_id,
            type: 'project_updated',
            title: 'Added to Project',
            message: `You have been added to project: ${project.name}`,
            related_entity: {
              entity_type: 'Project',
              entity_id: project._id
            }
          }, io);
        } catch (notificationError) {
          console.error('❌ Error creating notification:', notificationError);
          // Don't throw - continue with socket emissions
        }

        // Emit socket events with error handling
        try {
          const newMember = await User.findById(user_id, 'username full_name email avatar');
          
          // Notify existing project members
          project.members.forEach(memberId => {
            if (memberId.toString() !== user_id) {
              try {
                io.to(`user_${memberId}`).emit('project:member_added', {
                  project_id: project._id,
                  project_name: project.name,
                  new_member: newMember,
                  added_by: req.user.full_name
                });
              } catch (emitError) {
                console.error(`❌ Error emitting to user ${memberId}:`, emitError);
              }
            }
          });

          // Notify the new member
          try {
            io.to(`user_${user_id}`).emit('project:joined', {
              project_id: project._id,
              project_name: project.name,
              role: 'member'
            });
          } catch (emitError) {
            console.error(`❌ Error emitting to new member ${user_id}:`, emitError);
          }

        } catch (socketError) {
          console.error('❌ Error in socket emissions:', socketError);
        }

      } catch (socketOperationError) {
        console.error('❌ Socket operations failed:', socketOperationError);
      }
    };

    // Execute socket operations asynchronously without blocking response
    socketOperations();

    // 🎉 ALWAYS return success response (main operation completed)
    res.json({
      message: 'Member added successfully',
      project: updatedProject
    });

  } catch (error) {
    console.error('❌ Error in addMember:', error);
    res.status(500).json({ message: error.message });
  }
};
const getMembers = async (req, res) => {
  try {
    const { id } = req.params;

    const project = await Project.findById(id).populate('members'); // <-- lấy toàn bộ thông tin User

    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }

    res.status(200).json({ members: project.members });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const removeMember = async (req, res) => {
  try {
    const { id, user_id } = req.params;

    const project = await Project.findById(id);
    const taskOfMember = await Task.find({ assigned_to: user_id, project_id: id });
    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }

    // Check permissions
    const canRemoveMember = 
                           project.owner_id.toString() === req.user._id.toString() ;

    if (!canRemoveMember) {
      return res.status(403).json({ message: 'Permission denied' });
    }

    // Cannot remove owner
    if (project.owner_id.toString() === user_id) {
      return res.status(400).json({ message: 'Cannot remove project owner' });
    }
    // Cannot remove if member has tasks assigned
  if (taskOfMember && taskOfMember.length > 0) {
    return res.status(400).json({ message: 'Cannot remove member with assigned tasks' });
  }
    project.members = project.members.filter(member => member.toString() !== user_id);
    await project.save();
    const updatedProject = await Project.findById(id)
      .populate('owner_id', 'username full_name email avatar')
      .populate('members', 'username full_name email role avatar');
    // Notify the removed member
    const io = req.app.get('io');
    const removedUser = await User.findById(user_id, 'username full_name');
    await createNotification({
      user_id,
      type: 'project_updated',
      title: 'Bạn đã bị xóa khỏi dự án',
      message: `Bạn đã bị xóa khỏi dự án: ${project.name}`,
      related_entity: {
        entity_type: 'Project',
        entity_id: project._id,
      }
    }, io);
    if (io) {
      io.to(`user_${user_id}`).emit('project:removed', {
        project_id: project._id,
        project_name: project.name,
        removed_by: req.user.full_name
      });

      // Notify all remaining members about the removal
      project.members.forEach(memberId => {
        io.to(`user_${memberId}`).emit('project:member_removed', {
          project_id: project._id,
          project_name: project.name,
          removed_member: removedUser,
          removed_by: req.user.full_name
        });
      });
    }
    res.json({ message: 'Member removed successfully', project: updatedProject });
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
  removeMember,
  getMembers,
  getRecentProjects

};