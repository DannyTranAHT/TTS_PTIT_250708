const swaggerJSDoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

// Swagger definition
const swaggerDefinition = {
  openapi: '3.0.0',
  info: {
    title: 'ProjectHub API',
    version: '1.0.0',
    description: 'API documentation for ProjectHub - Project Management System',
    contact: {
      name: 'API Support',
      email: 'support@projecthub.com',
    },
    license: {
      name: 'MIT',
      url: 'https://opensource.org/licenses/MIT',
    },
  },
  servers: [
    {
      url: process.env.NODE_ENV === 'production' ? 'https://api.projecthub.com' : `http://localhost:${process.env.PORT || 5000}`,
      description: process.env.NODE_ENV === 'production' ? 'Production server' : 'Development server',
    },
  ],
  components: {
    securitySchemes: {
      bearerAuth: {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        description: 'Enter your JWT token in the format: Bearer <token>',
      },
    },
    schemas: {
      // Error response schema
      Error: {
        type: 'object',
        properties: {
          success: {
            type: 'boolean',
            example: false,
          },
          message: {
            type: 'string',
            example: 'Error message',
          },
          error: {
            type: 'string',
            example: 'Detailed error information',
          },
        },
      },
      // Success response schema
      Success: {
        type: 'object',
        properties: {
          success: {
            type: 'boolean',
            example: true,
          },
          message: {
            type: 'string',
            example: 'Operation successful',
          },
          data: {
            type: 'object',
          },
        },
      },
      // User schema
      User: {
        type: 'object',
        properties: {
          _id: {
            type: 'string',
            example: '64f123abc123def456789012',
          },
          username: {
            type: 'string',
            example: 'john_doe',
          },
          email: {
            type: 'string',
            format: 'email',
            example: 'john@example.com',
          },
          full_name: {
            type: 'string',
            example: 'John Doe',
          },
          role: {
            type: 'string',
            enum: ['Admin', 'Project Manager', 'Employee'],
            example: 'Employee',
          },
          major: {
            type: 'string',
            example: 'Computer Science',
          },
          avatar: {
            type: 'string',
            example: 'uploads/avatars/avatar.jpg',
          },
          is_active: {
            type: 'boolean',
            example: true,
          },
          created_at: {
            type: 'string',
            format: 'date-time',
            example: '2023-12-01T10:30:00.000Z',
          },
          updated_at: {
            type: 'string',
            format: 'date-time',
            example: '2023-12-01T10:30:00.000Z',
          },
        },
      },
      // Project schema
      Project: {
        type: 'object',
        properties: {
          _id: {
            type: 'string',
            example: '64f123abc123def456789012',
          },
          name: {
            type: 'string',
            example: 'ProjectHub Development',
          },
          description: {
            type: 'string',
            example: 'A comprehensive project management system',
          },
          start_date: {
            type: 'string',
            format: 'date',
            example: '2023-12-01',
          },
          end_date: {
            type: 'string',
            format: 'date',
            example: '2024-03-01',
          },
          status: {
            type: 'string',
            enum: ['Not Started', 'In Progress', 'Completed', 'On Hold', 'Cancelled'],
            example: 'In Progress',
          },
          priority: {
            type: 'string',
            enum: ['Low', 'Medium', 'High', 'Critical'],
            example: 'High',
          },
          owner_id: {
            type: 'string',
            example: '64f123abc123def456789012',
          },
          members: {
            type: 'array',
            items: {
              type: 'string',
            },
            example: ['64f123abc123def456789012', '64f123abc123def456789013'],
          },
          progress: {
            type: 'integer',
            minimum: 0,
            maximum: 100,
            example: 65,
          },
          budget: {
            type: 'number',
            format: 'decimal',
            example: 50000.00,
          },
          created_at: {
            type: 'string',
            format: 'date-time',
            example: '2023-12-01T10:30:00.000Z',
          },
          updated_at: {
            type: 'string',
            format: 'date-time',
            example: '2023-12-01T10:30:00.000Z',
          },
        },
      },
      // Task schema
      Task: {
        type: 'object',
        properties: {
          _id: {
            type: 'string',
            example: '64f123abc123def456789012',
          },
          project_id: {
            type: 'string',
            example: '64f123abc123def456789012',
          },
          name: {
            type: 'string',
            example: 'Implement user authentication',
          },
          description: {
            type: 'string',
            example: 'Create JWT-based authentication system',
          },
          due_date: {
            type: 'string',
            format: 'date',
            example: '2024-01-15',
          },
          status: {
            type: 'string',
            enum: ['To Do', 'In Progress', 'In Review', 'Blocked', 'Done'],
            example: 'In Progress',
          },
          priority: {
            type: 'string',
            enum: ['Low', 'Medium', 'High', 'Critical'],
            example: 'High',
          },
          assigned_to_id: {
            type: 'string',
            example: '64f123abc123def456789012',
          },
          hours: {
            type: 'integer',
            example: 8,
          },
          attachments: {
            type: 'string',
            example: 'uploads/tasks/document.pdf',
          },
          created_at: {
            type: 'string',
            format: 'date-time',
            example: '2023-12-01T10:30:00.000Z',
          },
          updated_at: {
            type: 'string',
            format: 'date-time',
            example: '2023-12-01T10:30:00.000Z',
          },
        },
      },
      // Comment schema
      Comment: {
        type: 'object',
        properties: {
          _id: {
            type: 'string',
            example: '64f123abc123def456789012',
          },
          entity_type: {
            type: 'string',
            enum: ['Project', 'Task'],
            example: 'Task',
          },
          entity_id: {
            type: 'string',
            example: '64f123abc123def456789012',
          },
          user_id: {
            type: 'string',
            example: '64f123abc123def456789012',
          },
          content: {
            type: 'string',
            example: 'This task is progressing well',
          },
          parent_id: {
            type: 'string',
            nullable: true,
            example: '64f123abc123def456789013',
          },
          attachments: {
            type: 'string',
            nullable: true,
            example: 'uploads/comments/image.jpg',
          },
          created_at: {
            type: 'string',
            format: 'date-time',
            example: '2023-12-01T10:30:00.000Z',
          },
          updated_at: {
            type: 'string',
            format: 'date-time',
            example: '2023-12-01T10:30:00.000Z',
          },
        },
      },
      // Notification schema
      Notification: {
        type: 'object',
        properties: {
          _id: {
            type: 'string',
            example: '64f123abc123def456789012',
          },
          user_id: {
            type: 'string',
            example: '64f123abc123def456789012',
          },
          type: {
            type: 'string',
            enum: ['task_assigned', 'task_updated', 'project_updated', 'comment_added', 'due_date_reminder', 'message_received'],
            example: 'task_assigned',
          },
          title: {
            type: 'string',
            example: 'New task assigned',
          },
          message: {
            type: 'string',
            example: 'You have been assigned to a new task: Implement user authentication',
          },
          is_read: {
            type: 'boolean',
            example: false,
          },
          created_at: {
            type: 'string',
            format: 'date-time',
            example: '2023-12-01T10:30:00.000Z',
          },
          updated_at: {
            type: 'string',
            format: 'date-time',
            example: '2023-12-01T10:30:00.000Z',
          },
        },
      },
      // Pagination response
      PaginationMeta: {
        type: 'object',
        properties: {
          totalPages: {
            type: 'integer',
            example: 5,
          },
          currentPage: {
            type: 'integer',
            example: 1,
          },
          total: {
            type: 'integer',
            example: 50,
          },
          hasNext: {
            type: 'boolean',
            example: true,
          },
          hasPrev: {
            type: 'boolean',
            example: false,
          },
        },
      },
    },
  },
  security: [
    {
      bearerAuth: [],
    },
  ],
};

// Options for the swagger docs
const options = {
  definition: swaggerDefinition,
  // Paths to files containing OpenAPI definitions
  apis: [
    './routes/*.js',
    './controllers/*.js',
    './swagger/paths/*.js',
  ],
};

// Initialize swagger-jsdoc
const swaggerSpec = swaggerJSDoc(options);

// Swagger UI options
const swaggerUiOptions = {
  customCss: `
    .swagger-ui .topbar { display: none; }
    .swagger-ui .info .title { color: #2c3e50; }
    .swagger-ui .scheme-container { background: #f8f9fa; }
  `,
  customSiteTitle: 'ProjectHub API Documentation',
  customfavIcon: '/favicon.ico',
  swaggerOptions: {
    persistAuthorization: true,
    displayRequestDuration: true,
    filter: true,
    showExtensions: true,
    showCommonExtensions: true,
  },
};

module.exports = {
  swaggerSpec,
  swaggerUi,
  swaggerUiOptions,
};