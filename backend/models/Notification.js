const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  type: {
    type: String,
    enum: ['task_assigned', 'task_updated', 'project_updated', 'comment_added', 'due_date_reminder'],
    required: true
  },
  title: {
    type: String,
    required: true,
    maxlength: 200
  },
  message: {
    type: String,
    required: true,
    maxlength: 500
  },
  is_read: {
    type: Boolean,
    default: false
  },
  related_entity: {
    entity_type: {
      type: String,
      enum: ['Project', 'Task', 'Comment']
    },
    entity_id: {
      type: mongoose.Schema.Types.ObjectId
    }
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
});

// Indexes
notificationSchema.index({ user_id: 1, is_read: 1 });
notificationSchema.index({ created_at: -1 });

module.exports = mongoose.model('Notification', notificationSchema);