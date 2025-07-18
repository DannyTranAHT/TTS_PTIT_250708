# TypeScript & Express.js Coding Guidelines

## Table of Contents
1. [General Principles](#general-principles)
2. [TypeScript Guidelines](#typescript-guidelines)
3. [Express.js Guidelines](#express-guidelines)
4. [Project Structure](#project-structure)
5. [Error Handling](#error-handling)
6. [Security Best Practices](#security-best-practices)
7. [Testing Guidelines](#testing-guidelines)
8. [Performance Considerations](#performance-considerations)
9. [Documentation Standards](#documentation-standards)

## General Principles

### Code Quality
- Write self-documenting code with meaningful names
- Follow the DRY (Don't Repeat Yourself) principle
- Keep functions small and focused on a single responsibility
- Use consistent formatting and linting tools (ESLint, Prettier)
- Maintain test coverage above 80%

### Version Control
- Use semantic versioning for releases
- Write clear, descriptive commit messages
- Create feature branches for new development
- Require code reviews for all pull requests

## TypeScript Guidelines

### Type Definitions

#### Always Use Explicit Types
```typescript
// Good
const userId: string = req.params.id;
const userAge: number = 25;

// Avoid
const userId = req.params.id;
const userAge = 25;
```

#### Interface vs Type Aliases
- Use `interface` for object shapes that might be extended
- Use `type` for unions, primitives, and computed types

```typescript
// Good - Interface for extensible objects
interface User {
  id: string;
  name: string;
  email: string;
}

interface AdminUser extends User {
  permissions: string[];
}

// Good - Type for unions and computed types
type Status = 'pending' | 'approved' | 'rejected';
type UserKeys = keyof User;
```

#### Strict Type Checking
- Enable strict mode in `tsconfig.json`
- Avoid `any` type - use `unknown` or specific types
- Use type guards for runtime type checking

```typescript
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true
  }
}

// Good - Type guard
function isUser(obj: unknown): obj is User {
  return typeof obj === 'object' && 
         obj !== null && 
         'id' in obj && 
         'name' in obj && 
         'email' in obj;
}
```

### Naming Conventions

#### Variables and Functions
- Use camelCase for variables and functions
- Use descriptive names that indicate purpose

```typescript
// Good
const fetchUserById = async (userId: string): Promise<User> => {
  // implementation
};

const isValidEmail = (email: string): boolean => {
  // validation logic
};
```

#### Classes and Interfaces
- Use PascalCase for classes and interfaces
- Prefix interfaces with 'I' only when necessary for disambiguation

```typescript
// Good
class UserService {
  // implementation
}

interface DatabaseConfig {
  host: string;
  port: number;
  database: string;
}
```

#### Constants
- Use UPPER_SNAKE_CASE for constants
- Group related constants in enums or const objects

```typescript
// Good
const MAX_RETRY_ATTEMPTS = 3;
const API_ENDPOINTS = {
  USERS: '/api/users',
  ORDERS: '/api/orders'
} as const;

enum UserRole {
  ADMIN = 'admin',
  USER = 'user',
  MODERATOR = 'moderator'
}
```

## Express.js Guidelines

### Application Structure

#### Router Organization
- Use Express Router for modular route organization
- Group related routes in separate files
- Use middleware for common functionality

```typescript
// routes/users.ts
import { Router } from 'express';
import { UserController } from '../controllers/UserController';
import { authMiddleware } from '../middleware/auth';

const router = Router();
const userController = new UserController();

router.get('/', userController.getAllUsers);
router.get('/:id', userController.getUserById);
router.post('/', authMiddleware, userController.createUser);
router.put('/:id', authMiddleware, userController.updateUser);
router.delete('/:id', authMiddleware, userController.deleteUser);

export default router;
```

#### Controller Pattern
- Use controller classes to handle route logic
- Keep controllers thin - delegate business logic to services
- Use dependency injection for better testability

```typescript
// controllers/UserController.ts
import { Request, Response, NextFunction } from 'express';
import { UserService } from '../services/UserService';

export class UserController {
  constructor(private userService: UserService = new UserService()) {}

  getAllUsers = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const users = await this.userService.getAllUsers();
      res.json({ success: true, data: users });
    } catch (error) {
      next(error);
    }
  };

  getUserById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { id } = req.params;
      const user = await this.userService.getUserById(id);
      
      if (!user) {
        return res.status(404).json({ success: false, message: 'User not found' });
      }
      
      res.json({ success: true, data: user });
    } catch (error) {
      next(error);
    }
  };
}
```

### Middleware Guidelines

#### Custom Middleware
- Create reusable middleware functions
- Use proper TypeScript types for middleware
- Handle errors appropriately

```typescript
// middleware/auth.ts
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

interface AuthRequest extends Request {
  user?: User;
}

export const authMiddleware = (req: AuthRequest, res: Response, next: NextFunction): void => {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    res.status(401).json({ success: false, message: 'Access token required' });
    return;
  }
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as User;
    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({ success: false, message: 'Invalid token' });
  }
};
```

#### Request Validation
- Use middleware for input validation
- Leverage libraries like Joi or Yup for schema validation

```typescript
// middleware/validation.ts
import { Request, Response, NextFunction } from 'express';
import Joi from 'joi';

export const validateUser = (req: Request, res: Response, next: NextFunction): void => {
  const schema = Joi.object({
    name: Joi.string().required().min(2).max(50),
    email: Joi.string().email().required(),
    age: Joi.number().integer().min(18).max(120)
  });
  
  const { error } = schema.validate(req.body);
  
  if (error) {
    res.status(400).json({
      success: false,
      message: 'Validation error',
      details: error.details
    });
    return;
  }
  
  next();
};
```

## Project Structure

### Recommended Directory Structure
```
src/
├── controllers/     # Route handlers
├── services/        # Business logic
├── models/          # Data models/schemas
├── middleware/      # Custom middleware
├── routes/          # Route definitions
├── utils/           # Utility functions
├── types/           # TypeScript type definitions
├── config/          # Configuration files
├── tests/           # Test files
└── app.ts           # Application entry point
```

### Configuration Management
- Use environment variables for configuration
- Create typed configuration objects
- Validate configuration at startup

```typescript
// config/database.ts
interface DatabaseConfig {
  host: string;
  port: number;
  database: string;
  username: string;
  password: string;
}

export const databaseConfig: DatabaseConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'myapp',
  username: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || ''
};
```

## Error Handling

### Centralized Error Handling
- Use a global error handler middleware
- Create custom error classes for different error types
- Log errors appropriately

```typescript
// middleware/errorHandler.ts
import { Request, Response, NextFunction } from 'express';

export class AppError extends Error {
  public statusCode: number;
  public isOperational: boolean;
  
  constructor(message: string, statusCode: number) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;
    
    Error.captureStackTrace(this, this.constructor);
  }
}

export const errorHandler = (
  err: AppError,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const { statusCode = 500, message } = err;
  
  // Log error
  console.error(`Error ${statusCode}: ${message}`);
  
  res.status(statusCode).json({
    success: false,
    message: statusCode === 500 ? 'Internal server error' : message
  });
};
```

### Async Error Handling
- Use try-catch blocks in async functions
- Create an async wrapper for route handlers

```typescript
// utils/asyncHandler.ts
import { Request, Response, NextFunction } from 'express';

type AsyncHandler = (req: Request, res: Response, next: NextFunction) => Promise<void>;

export const asyncHandler = (fn: AsyncHandler) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

// Usage
router.get('/users', asyncHandler(async (req, res, next) => {
  const users = await userService.getAllUsers();
  res.json({ success: true, data: users });
}));
```

## Security Best Practices

### Input Validation and Sanitization
- Validate all input data
- Sanitize data to prevent injection attacks
- Use parameterized queries for database operations

```typescript
// middleware/security.ts
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import mongoSanitize from 'express-mongo-sanitize';

export const securityMiddleware = [
  helmet(),
  rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100 // limit each IP to 100 requests per windowMs
  }),
  mongoSanitize()
];
```

### Authentication and Authorization
- Use JWT tokens for stateless authentication
- Implement proper session management
- Use role-based access control

```typescript
// middleware/authorize.ts
export const authorize = (roles: string[]) => {
  return (req: AuthRequest, res: Response, next: NextFunction): void => {
    if (!req.user) {
      res.status(401).json({ success: false, message: 'Authentication required' });
      return;
    }
    
    if (!roles.includes(req.user.role)) {
      res.status(403).json({ success: false, message: 'Insufficient permissions' });
      return;
    }
    
    next();
  };
};
```

## Testing Guidelines

### Unit Testing
- Test individual functions and methods
- Use Jest and Supertest for testing Express applications
- Mock external dependencies

```typescript
// tests/UserController.test.ts
import request from 'supertest';
import app from '../app';
import { UserService } from '../services/UserService';

jest.mock('../services/UserService');

describe('UserController', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });
  
  describe('GET /api/users', () => {
    it('should return all users', async () => {
      const mockUsers = [
        { id: '1', name: 'John Doe', email: 'john@example.com' }
      ];
      
      (UserService.prototype.getAllUsers as jest.Mock).mockResolvedValue(mockUsers);
      
      const response = await request(app).get('/api/users');
      
      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toEqual(mockUsers);
    });
  });
});
```

### Integration Testing
- Test complete request-response cycles
- Use test databases for integration tests
- Test error scenarios and edge cases

## Performance Considerations

### Caching
- Implement appropriate caching strategies
- Use Redis for session storage and caching
- Cache database queries where appropriate

```typescript
// utils/cache.ts
import Redis from 'ioredis';

const redis = new Redis(process.env.REDIS_URL);

export const cache = {
  get: async (key: string): Promise<string | null> => {
    return await redis.get(key);
  },
  
  set: async (key: string, value: string, ttl: number = 3600): Promise<void> => {
    await redis.setex(key, ttl, value);
  },
  
  del: async (key: string): Promise<void> => {
    await redis.del(key);
  }
};
```

### Database Optimization
- Use connection pooling
- Implement proper indexing
- Use pagination for large datasets

```typescript
// controllers/UserController.ts
export const getAllUsers = async (req: Request, res: Response): Promise<void> => {
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 10;
  const skip = (page - 1) * limit;
  
  const users = await userService.getAllUsers({ skip, limit });
  const total = await userService.getUserCount();
  
  res.json({
    success: true,
    data: users,
    pagination: {
      page,
      limit,
      total,
      pages: Math.ceil(total / limit)
    }
  });
};
```

## Documentation Standards

### Code Documentation
- Use JSDoc comments for functions and classes
- Document complex business logic
- Keep documentation up to date

```typescript
/**
 * Creates a new user in the system
 * @param userData - The user data to create
 * @returns Promise resolving to the created user
 * @throws AppError when user creation fails
 */
async createUser(userData: CreateUserDto): Promise<User> {
  // Implementation
}
```

### API Documentation
- Use OpenAPI/Swagger for API documentation
- Document all endpoints, parameters, and responses
- Include example requests and responses

### README Files
- Include setup instructions
- Document environment variables
- Provide examples of common use cases

## Conclusion

These guidelines serve as a foundation for maintaining high-quality, scalable TypeScript and Express.js applications. Regular code reviews and adherence to these standards will help ensure consistent, maintainable codebases across development teams.

Remember to:
- Keep guidelines updated as the project evolves
- Regularly review and refactor existing code
- Stay updated with TypeScript and Express.js best practices
- Encourage team discussion and feedback on these guidelines