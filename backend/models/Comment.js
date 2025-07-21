const mongoose = require('mongoose');

const commentSchema = new mongoose.Schema({
  entity_type: {
    type: String,
    enum: ['Project', 'Task'],
    required: true
  },
  entity_id: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    refPath: 'entity_type'
  },
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  content: {
    type: String,
    required: true,
    trim: true
  },
  parent_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Comment'
  },
  attachments: [{
    filename: String,
    original_name: String,
    path: String,
    size: Number,
    mimetype: String,
    uploaded_at: { type: Date, default: Date.now }
  }],
  is_deleted: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
});

// Indexes
commentSchema.index({ entity_type: 1, entity_id: 1 });
commentSchema.index({ user_id: 1 });
commentSchema.index({ parent_id: 1 });

module.exports = mongoose.model('Comment', commentSchema);