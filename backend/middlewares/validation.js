const Joi = require('joi');

const validate = (schema) => {
  return (req, res, next) => {
    const { error } = schema.validate(req.body);
    if (error) {
      return res.status(400).json({
        message: 'Validation error',
        details: error.details.map(detail => detail.message)
      });
    }
    next();
  };
};

// Validation schemas
const authSchemas = {
  register: Joi.object({
    username: Joi.string().min(3).max(30).required(),
    email: Joi.string().email().required(),
    password: Joi.string().min(6).required(),
    full_name: Joi.string().max(100).required(),
    role: Joi.string().valid('Admin', 'Project Manager', 'Employee'),
    major: Joi.string().max(255)
  }),
  
  login: Joi.object({
    // username: Joi.string().min(3).max(30).required(),
    email: Joi.string().email(),
    password: Joi.string().required()
  })
};

const projectSchemas = {
  create: Joi.object({
    name: Joi.string().max(100).required(),
    description: Joi.string(),
    start_date: Joi.date(),
    end_date: Joi.date(),
    status: Joi.string().valid('Not Started', 'In Progress', 'Completed', 'On Hold', 'Cancelled'),
    priority: Joi.string().valid('Low', 'Medium', 'High', 'Critical'),
    budget: Joi.number().min(0)
  }),
  update: Joi.object({
    name: Joi.string().max(100),
    description: Joi.string().allow(null, ''),
    start_date: Joi.date(),
    end_date: Joi.date(),
    status: Joi.string().valid('Not Started', 'In Progress', 'Completed'),
    priority: Joi.string().valid('Low', 'Medium', 'High', 'Critical'),
    members: Joi.array().items(Joi.string().length(24)),
    progress: Joi.number().min(0).max(100),
    budget: Joi.number().min(0)
  }).min(1)
};

const taskSchemas = {
  create: Joi.object({
    project_id: Joi.string().length(24).required(),
    name: Joi.string().max(200).required(),
    description: Joi.string().allow(null, ''),
    due_date: Joi.date().required(),
    status: Joi.string().valid('To Do', 'In Progress', 'In Review', 'Blocked', 'Done').default('To Do'),
    priority: Joi.string().valid('Low', 'Medium', 'High', 'Critical').default('Medium'),
    assigned_to_id: Joi.string().length(24).optional().allow(null),
    hours: Joi.number().min(0).default(0),
    attachments: Joi.string().optional().allow(null)
  }),

  update: Joi.object({
    name: Joi.string().max(200),
    description: Joi.string().allow(null, ''),
    due_date: Joi.date(),
    status: Joi.string().valid('To Do', 'In Progress', 'In Review', 'Blocked', 'Done'),
    priority: Joi.string().valid('Low', 'Medium', 'High', 'Critical'),
    assigned_to_id: Joi.string().length(24).allow(null),
    hours: Joi.number().min(0),
    attachments: Joi.string().allow(null)
  }).min(1)
};

const commentSchemas = {
  create: Joi.object({
    entity_type: Joi.string().valid('Project', 'Task').required(),
    entity_id: Joi.string().length(24).required(),
    content: Joi.string().required(),
    parent_id: Joi.string().length(24).optional(),
    attachments: Joi.string().optional().allow(null),

    parent_id: Joi.string().length(24).optional().allow(null),
  }),

  update: Joi.object({
    content: Joi.string().required()
  })
};

const notificationSchemas = {
  create: Joi.object({
    user_id: Joi.string().length(24).required(),
    type: Joi.string().valid('Notification', 'Remind').required(),
    title: Joi.string().max(200).required(),
    message: Joi.string().max(500).required(),
    is_read: Joi.boolean().optional()
  }),

  updateRead: Joi.object({
    is_read: Joi.boolean().required()
  })
};



module.exports = { validate, authSchemas, projectSchemas, taskSchemas, commentSchemas, notificationSchemas };