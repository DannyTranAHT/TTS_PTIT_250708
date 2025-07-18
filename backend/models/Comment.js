const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const commentSchema = new Schema({
  entity_type: {
    type: String,
    enum: ['Project', 'Task'],
    required: true
  },
  entity_id: {
    type: Schema.Types.ObjectId,
    required: true
  },
  user_id: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  content: {
    type: String,
    required: true
  },
  parent_id: {
    type: Schema.Types.ObjectId,
    ref: 'Comment',
    default: null
  },
  attachments: {
    type: [String], 
    default: []
  },
  created_at: {
    type: Date,
    default: Date.now
  },
  updated_at: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Comment', commentSchema);