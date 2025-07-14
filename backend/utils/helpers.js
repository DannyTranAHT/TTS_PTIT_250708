const { PAGINATION } = require('./constants');

// Pagination helper
const getPaginationOptions = (query) => {
  const page = parseInt(query.page) || PAGINATION.DEFAULT_PAGE;
  const limit = Math.min(
    parseInt(query.limit) || PAGINATION.DEFAULT_LIMIT,
    PAGINATION.MAX_LIMIT
  );
  const skip = (page - 1) * limit;

  return { page, limit, skip };
};

// Create pagination metadata
const createPaginationMeta = (page, limit, total) => {
  return {
    currentPage: page,
    totalPages: Math.ceil(total / limit),
    totalItems: total,
    itemsPerPage: limit,
    hasNextPage: page < Math.ceil(total / limit),
    hasPrevPage: page > 1
  };
};

// Format validation errors
const formatValidationErrors = (error) => {
  if (error.name === 'ValidationError') {
    const errors = Object.values(error.errors).map(err => ({
      field: err.path,
      message: err.message
    }));
    return { message: 'Validation failed', errors };
  }
  return { message: error.message };
};

// Generate random string
const generateRandomString = (length = 8) => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
};

// Check if date is within next N days
const isDateWithinDays = (date, days) => {
  const now = new Date();
  const targetDate = new Date(date);
  const diffTime = targetDate.getTime() - now.getTime();
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  
  return diffDays >= 0 && diffDays <= days;
};

// Get overdue tasks count
const getOverdueTasks = (tasks) => {
  const now = new Date();
  return tasks.filter(task => 
    task.due_date && 
    new Date(task.due_date) < now && 
    task.status !== 'Done'
  );
};

// Calculate project progress
const calculateProjectProgress = (tasks) => {
  if (!tasks || tasks.length === 0) return 0;
  
  const completedTasks = tasks.filter(task => task.status === 'Done').length;
  return Math.round((completedTasks / tasks.length) * 100);
};

// Sanitize user input
const sanitizeInput = (input) => {
  if (typeof input !== 'string') return input;
  
  return input
    .trim()
    .replace(/[<>]/g, '') // Remove potential HTML tags
    .slice(0, 1000); // Limit length
};

// Create search regex
const createSearchRegex = (searchTerm) => {
  if (!searchTerm) return null;
  
  const escapedTerm = searchTerm.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  return new RegExp(escapedTerm, 'i');
};

// Format file size
const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 Bytes';
  
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

// Generate file path
const generateFilePath = (originalName, folder = 'uploads') => {
  const timestamp = Date.now();
  const randomString = generateRandomString(6);
  const extension = originalName.split('.').pop();
  const filename = `${timestamp}-${randomString}.${extension}`;
  
  return `${folder}/${filename}`;
};

// Validate email format
const isValidEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

// Create response object
const createResponse = (success, message, data = null, meta = null) => {
  const response = { success, message };
  
  if (data !== null) {
    response.data = data;
  }
  
  if (meta !== null) {
    response.meta = meta;
  }
  
  return response;
};

// Extract user permissions
const getUserPermissions = (user, project = null) => {
  const permissions = {
    canCreateProject: ['Admin', 'Project Manager'].includes(user.role),
    canDeleteProject: user.role === 'Admin',
    canManageUsers: user.role === 'Admin',
    canViewAllProjects: ['Admin', 'Project Manager'].includes(user.role)
  };

  if (project) {
    permissions.canEditProject = 
      user.role === 'Admin' || 
      project.owner_id.toString() === user._id.toString() ||
      user.role === 'Project Manager';
      
    permissions.canAddMembers = permissions.canEditProject;
    permissions.canRemoveMembers = permissions.canEditProject;
  }

  return permissions;
};

module.exports = {
  getPaginationOptions,
  createPaginationMeta,
  formatValidationErrors,
  generateRandomString,
  isDateWithinDays,
  getOverdueTasks,
  calculateProjectProgress,
  sanitizeInput,
  createSearchRegex,
  formatFileSize,
  generateFilePath,
  isValidEmail,
  createResponse,
  getUserPermissions
};