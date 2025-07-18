const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const TaskSchema = new Schema({
  project_id: {
    type: Schema.Types.ObjectId,
    ref: 'Project',
    required: true
  },
  name: {
    type: String,
    required: true,
    maxlength: 200
  },
  description: {
    type: String,
    default: null
  },
  due_date: {
    type: Date,
    required: true
  },
  status: {
    type: String,
    enum: ['To Do', 'In Progress', 'In Review', 'Blocked', 'Done'],
    default: 'To Do'
  },
  priority: {
    type: String,
    enum: ['Low', 'Medium', 'High', 'Critical'],
    default: 'Medium'
  },
  assigned_to_id: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    default: null
  },
  hours: {
    type: Number,
    default: 0
  },
  attachments: {
    type: String,
    default: null
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
});

module.exports = mongoose.model('Task', TaskSchema);
