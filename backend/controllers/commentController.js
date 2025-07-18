const Comment = require('../models/Comment');
const Project = require('../models/Project');
const Task = require('../models/Task');

// Tạo comment mới (cả bình luận và trả lời)
const createComment = async (req, res) => {
  try {
    const { entity_type, entity_id, content, parent_id, attachments } = req.body;

    // Kiểm tra entity_type và entity_id có hợp lệ không
    if (entity_type === 'Project') {
      const project = await Project.findById(entity_id);
      if (!project) {
        return res.status(400).json({ message: 'Invalid project id' });
      }
    } else if (entity_type === 'Task') {
      const task = await Task.findById(entity_id);
      if (!task) {
        return res.status(400).json({ message: 'Invalid task id' });
      }
    } else {
      return res.status(400).json({ message: 'Invalid entity_type' });
    }

    const comment = await Comment.create({
      entity_type,
      entity_id,
      user_id: req.user._id,
      content,
      parent_id: parent_id || null,
      attachments: attachments || []
    });
    res.status(201).json({ message: 'Comment created', comment });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Sửa comment
const updateComment = async (req, res) => {
  try {
    const { id } = req.params;
    const { content, attachments } = req.body;
    const comment = await Comment.findById(id);
    if (!comment) {
      return res.status(404).json({ message: 'Comment not found' });
    }
    // Chỉ chủ comment mới được sửa
    if (comment.user_id.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Permission denied' });
    }
    comment.content = content || comment.content;
    comment.attachments = attachments || comment.attachments;
    comment.updated_at = Date.now();
    await comment.save();
    res.json({ message: 'Comment updated', comment });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Xóa comment
const deleteComment = async (req, res) => {
  try {
    const { id } = req.params;
    const comment = await Comment.findById(id);
    if (!comment) {
      return res.status(404).json({ message: 'Comment not found' });
    }
    // Chỉ chủ comment hoặc admin mới được xóa
    if (
      comment.user_id.toString() !== req.user._id.toString() &&
      req.user.role !== 'Admin'
    ) {
      return res.status(403).json({ message: 'Permission denied' });
    }
    await Comment.deleteOne({ _id: id });
    // Xóa luôn các reply (nếu có)
    await Comment.deleteMany({ parent_id: id });
    res.json({ message: 'Comment deleted' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Lấy danh sách comment theo entity (project/task)
const getComments = async (req, res) => {
  try {
    const { entity_type, entity_id } = req.query;
    const comments = await Comment.find({
      entity_type,
      entity_id,
      parent_id: null
    })
      .populate('user_id', 'username full_name avatar')
      .sort({ created_at: -1 });

    // Lấy replies cho từng comment
    const commentIds = comments.map(c => c._id);
    const replies = await Comment.find({ parent_id: { $in: commentIds } })
      .populate('user_id', 'username full_name avatar')
      .sort({ created_at: 1 });

    // Gắn replies vào từng comment
    const commentsWithReplies = comments.map(comment => {
      const commentReplies = replies.filter(r => r.parent_id && r.parent_id.toString() === comment._id.toString());
      return { ...comment.toObject(), replies: commentReplies };
    });

    res.json({ comments: commentsWithReplies });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  createComment,
  updateComment,
  deleteComment,
  getComments
};