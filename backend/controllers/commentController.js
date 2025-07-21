const Comment = require('../models/Comment');
const Project = require('../models/Project');
const Task = require('../models/Task');
const { createNotification } = require('../services/notificationService');

const getComments = async (req, res) => {
  try {
    const { entity_type, entity_id, page = 1, limit = 20 } = req.query;

    if (!entity_type || !entity_id) {
      return res.status(400).json({ 
        message: 'entity_type and entity_id are required' 
      });
    }

    // Verify entity exists and user has access
    let entity;
    if (entity_type === 'Project') {
      entity = await Project.findById(entity_id);
    } else if (entity_type === 'Task') {
      entity = await Task.findById(entity_id).populate('project_id');
    }

    if (!entity) {
      return res.status(404).json({ message: `${entity_type} not found` });
    }

    // Check access permissions
    let hasAccess = false;
    if (entity_type === 'Project') {
      hasAccess = req.user.role === 'Admin' || 
                 entity.owner_id.toString() === req.user._id.toString() ||
                 entity.members.includes(req.user._id);
    } else if (entity_type === 'Task') {
      const project = entity.project_id;
      hasAccess = req.user.role === 'Admin' || 
                 project.owner_id.toString() === req.user._id.toString() ||
                 project.members.includes(req.user._id);
    }

    if (!hasAccess) {
      return res.status(403).json({ message: 'Access denied' });
    }

    const comments = await Comment.find({
      entity_type,
      entity_id,
      is_deleted: false
    })
    .populate('user_id', 'username full_name avatar')
    .populate('parent_id')
    .sort({ created_at: -1 })
    .limit(limit * 1)
    .skip((page - 1) * limit);

    const total = await Comment.countDocuments({
      entity_type,
      entity_id,
      is_deleted: false
    });

    res.json({
      comments,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createComment = async (req, res) => {
  try {
    const { entity_type, entity_id, content, parent_id } = req.body;

    // Verify entity exists and user has access
    let entity;
    let entityName;
    let notificationRecipients = [];

    if (entity_type === 'Project') {
      entity = await Project.findById(entity_id).populate('members', '_id');
      if (!entity) {
        return res.status(404).json({ message: 'Project not found' });
      }
      
      entityName = entity.name;
      notificationRecipients = entity.members.map(m => m._id);
      
      const hasAccess = req.user.role === 'Admin' || 
                       entity.owner_id.toString() === req.user._id.toString() ||
                       entity.members.some(m => m._id.toString() === req.user._id.toString());
      
      if (!hasAccess) {
        return res.status(403).json({ message: 'Access denied' });
      }
    } else if (entity_type === 'Task') {
      entity = await Task.findById(entity_id).populate('project_id');
      if (!entity) {
        return res.status(404).json({ message: 'Task not found' });
      }
      
      entityName = entity.name;
      const project = await Project.findById(entity.project_id._id).populate('members', '_id');
      notificationRecipients = project.members.map(m => m._id);
      
      const hasAccess = req.user.role === 'Admin' || 
                       project.owner_id.toString() === req.user._id.toString() ||
                       project.members.some(m => m._id.toString() === req.user._id.toString());
      
      if (!hasAccess) {
        return res.status(403).json({ message: 'Access denied' });
      }
    }

    const comment = await Comment.create({
      entity_type,
      entity_id,
      user_id: req.user._id,
      content,
      parent_id: parent_id || undefined
    });

    const populatedComment = await Comment.findById(comment._id)
      .populate('user_id', 'username full_name avatar')
      .populate('parent_id');

    // Send notifications to entity members (except comment author)
    const recipientIds = notificationRecipients.filter(
      id => id.toString() !== req.user._id.toString()
    );

    const notificationPromises = recipientIds.map(userId => 
      createNotification({
        user_id: userId,
        type: 'comment_added',
        title: 'New Comment',
        message: `${req.user.full_name} commented on ${entity_type.toLowerCase()}: ${entityName}`,
        related_entity: {
          entity_type: 'Comment',
          entity_id: comment._id
        }
      })
    );

    await Promise.all(notificationPromises);

    // Real-time notification
    const io = req.app.get('io');
    recipientIds.forEach(userId => {
      io.to(`user_${userId}`).emit('comment:new', {
        comment: populatedComment,
        entity_type,
        entity_name: entityName,
        author: req.user.full_name
      });
    });

    res.status(201).json({
      message: 'Comment created successfully',
      comment: populatedComment
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const updateComment = async (req, res) => {
  try {
    const { id } = req.params;
    const { content } = req.body;

    const comment = await Comment.findById(id);
    if (!comment) {
      return res.status(404).json({ message: 'Comment not found' });
    }

    // Only comment author or admin can update
    if (comment.user_id.toString() !== req.user._id.toString() && req.user.role !== 'Admin') {
      return res.status(403).json({ message: 'Permission denied' });
    }

    const updatedComment = await Comment.findByIdAndUpdate(
      id,
      { content },
      { new: true, runValidators: true }
    ).populate('user_id', 'username full_name avatar');

    res.json({
      message: 'Comment updated successfully',
      comment: updatedComment
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const deleteComment = async (req, res) => {
  try {
    const { id } = req.params;

    const comment = await Comment.findById(id);
    if (!comment) {
      return res.status(404).json({ message: 'Comment not found' });
    }

    // Only comment author or admin can delete
    if (comment.user_id.toString() !== req.user._id.toString() && req.user.role !== 'Admin') {
      return res.status(403).json({ message: 'Permission denied' });
    }

    // Soft delete
    await Comment.findByIdAndUpdate(id, { is_deleted: true });

    res.json({ message: 'Comment deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getComments,
  createComment,
  updateComment,
  deleteComment
};