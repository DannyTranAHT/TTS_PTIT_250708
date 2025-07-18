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
    email: Joi.string().email().required(),
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
    members: Joi.array().items(Joi.string()),
    budget: Joi.number().min(0)
  })
};

module.exports = { validate, authSchemas, projectSchemas };