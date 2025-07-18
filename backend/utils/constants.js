// User roles
const USER_ROLES = {
    ADMIN: 'Admin',
    PROJECT_MANAGER: 'Project Manager',
    EMPLOYEE: 'Employee'
  };
  
  // Project statuses
  const PROJECT_STATUSES = {
    NOT_STARTED: 'Not Started',
    IN_PROGRESS: 'In Progress',
    COMPLETED: 'Completed',
    ON_HOLD: 'On Hold',
    CANCELLED: 'Cancelled'
  };
  
  // Task statuses
  const TASK_STATUSES = {
    TODO: 'To Do',
    IN_PROGRESS: 'In Progress',
    IN_REVIEW: 'In Review',
    BLOCKED: 'Blocked',
    DONE: 'Done'
  };
  
  // Priority levels
  const PRIORITY_LEVELS = {
    LOW: 'Low',
    MEDIUM: 'Medium',
    HIGH: 'High',
    CRITICAL: 'Critical'
  };
  
  // Notification types
  const NOTIFICATION_TYPES = {
    TASK_ASSIGNED: 'task_assigned',
    TASK_UPDATED: 'task_updated',
    PROJECT_UPDATED: 'project_updated',
    COMMENT_ADDED: 'comment_added',
    DUE_DATE_REMINDER: 'due_date_reminder',
    MESSAGE_RECEIVED: 'message_received'
  };
  
  // File upload limits
  const UPLOAD_LIMITS = {
    MAX_FILE_SIZE: 5 * 1024 * 1024, // 5MB
    ALLOWED_FILE_TYPES: ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx', 'txt', 'csv', 'xlsx']
  };
  
  // Pagination defaults
  const PAGINATION = {
    DEFAULT_PAGE: 1,
    DEFAULT_LIMIT: 10,
    MAX_LIMIT: 100
  };
  
  // Date formats
  const DATE_FORMATS = {
    ISO: 'YYYY-MM-DDTHH:mm:ss.sssZ',
    DISPLAY: 'DD/MM/YYYY',
    DISPLAY_WITH_TIME: 'DD/MM/YYYY HH:mm'
  };
  
  // Error messages
  const ERROR_MESSAGES = {
    VALIDATION_ERROR: 'Validation error',
    AUTHENTICATION_FAILED: 'Authentication failed',
    AUTHORIZATION_FAILED: 'Insufficient permissions',
    RESOURCE_NOT_FOUND: 'Resource not found',
    DUPLICATE_RESOURCE: 'Resource already exists',
    SERVER_ERROR: 'Internal server error'
  };
  
  module.exports = {
    USER_ROLES,
    PROJECT_STATUSES,
    TASK_STATUSES,
    PRIORITY_LEVELS,
    NOTIFICATION_TYPES,
    UPLOAD_LIMITS,
    PAGINATION,
    DATE_FORMATS,
    ERROR_MESSAGES
  };