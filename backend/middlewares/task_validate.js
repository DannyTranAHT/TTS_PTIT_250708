const Joi = require('joi');
const Task = require('../models/Task');
const Project = require('../models/Project');
// Base schemas
const taskSchemas = {
  // Schema cho Manager - có thể update tất cả fields
  managerUpdate: Joi.object({
    name: Joi.string().max(200).trim(),
    description: Joi.string().trim(),
    due_date: Joi.date(),
    status: Joi.string().valid('To Do', 'In Progress', 'In Review', 'Blocked', 'Done'),
    priority: Joi.string().valid('Low', 'Medium', 'High', 'Critical'),
    assigned_to_id: Joi.string().regex(/^[0-9a-fA-F]{24}$/),
    hours: Joi.number().min(0),
    attachments: Joi.array().items(
      Joi.object({
        filename: Joi.string(),
        original_name: Joi.string(),
        path: Joi.string(),
        size: Joi.number(),
        mimetype: Joi.string(),
        uploaded_at: Joi.date()
      })
    )
  }).min(1),

  // Schema cho Employee - chỉ có thể update status và attachments
  employeeUpdate: Joi.object({
    status: Joi.string().valid('To Do', 'In Progress', 'In Review', 'Blocked', 'Done'),
    attachments: Joi.array().items(
      Joi.object({
        filename: Joi.string(),
        original_name: Joi.string(),
        path: Joi.string(),
        size: Joi.number(),
        mimetype: Joi.string(),
        uploaded_at: Joi.date()
      })
    )
  }).min(1).unknown(false), // unknown(false) sẽ reject các fields không được phép

 
};

// **DYNAMIC VALIDATION MIDDLEWARE** - Tự động chọn schema dựa trên user role
const validateTaskUpdate = async (req, res, next) => {
  try {
    const { id } = req.params;

    // Get task và project để check permissions
    const task = await Task.findById(id).populate('project_id');
    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }

    const project = task.project_id;
    
    // Determine user type dựa trên role và relationship với project
    const isManager =project.owner_id.toString() === req.user._id.toString() ;
    
    // Chọn schema phù hợp
    const schema = isManager ? taskSchemas.managerUpdate : taskSchemas.employeeUpdate;
    
    // Validate request body
    const { error, value } = schema.validate(req.body);
    
    if (error) {
      const errorDetails = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message,
        value: detail.context?.value
      }));

      return res.status(400).json({
        message: 'Validation error',
        details: errorDetails,
        userType: isManager ? 'manager' : 'employee',
        allowedFields: isManager 
          ? ['name', 'description', 'due_date', 'status', 'priority', 'assigned_to_id', 'hours', 'attachments']
          : ['status', 'attachments']
      });
    }
    
    // Replace req.body với validated data
    req.body = value;
    
    // Add user type info for controller
    req.userType = isManager ? 'manager' : 'employee';
    
    next();
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


module.exports = {
  taskSchemas,
  validateTaskUpdate,   
};