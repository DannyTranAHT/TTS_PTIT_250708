# TypeScript & React.js Coding Guidelines

## Table of Contents
1. [General Principles](#general-principles)
2. [TypeScript Guidelines](#typescript-guidelines)
3. [React Component Guidelines](#react-component-guidelines)
4. [Hooks Guidelines](#hooks-guidelines)
5. [State Management](#state-management)
6. [Project Structure](#project-structure)
7. [Styling Guidelines](#styling-guidelines)
8. [Performance Optimization](#performance-optimization)
9. [Testing Guidelines](#testing-guidelines)
10. [Accessibility Guidelines](#accessibility-guidelines)
11. [Error Handling](#error-handling)

## General Principles

### Code Quality
- Write declarative, composable components
- Follow the single responsibility principle
- Use functional components with hooks over class components
- Prefer composition over inheritance
- Keep components small and focused
- Use TypeScript strict mode for type safety

### Development Standards
- Use ESLint with React and TypeScript rules
- Use Prettier for consistent formatting
- Follow semantic versioning
- Write meaningful commit messages
- Maintain test coverage above 80%

## TypeScript Guidelines

### Component Props and State Types

#### Define Clear Prop Interfaces
```typescript
// Good - Explicit prop interface
interface UserCardProps {
  user: User;
  onEdit: (userId: string) => void;
  onDelete: (userId: string) => void;
  isEditable?: boolean;
  className?: string;
}

const UserCard: React.FC<UserCardProps> = ({ 
  user, 
  onEdit, 
  onDelete, 
  isEditable = false,
  className 
}) => {
  // Component implementation
};
```

#### Use Generic Components When Appropriate
```typescript
// Good - Generic component for reusability
interface ListProps<T> {
  items: T[];
  renderItem: (item: T, index: number) => React.ReactNode;
  keyExtractor: (item: T) => string;
  emptyMessage?: string;
}

function List<T>({ items, renderItem, keyExtractor, emptyMessage }: ListProps<T>) {
  if (items.length === 0) {
    return <div className="empty-state">{emptyMessage || 'No items found'}</div>;
  }

  return (
    <ul>
      {items.map((item, index) => (
        <li key={keyExtractor(item)}>
          {renderItem(item, index)}
        </li>
      ))}
    </ul>
  );
}
```

#### Event Handler Types
```typescript
// Good - Proper event handler typing
interface FormProps {
  onSubmit: (data: FormData) => void;
  onInputChange: (field: string, value: string) => void;
}

const ContactForm: React.FC<FormProps> = ({ onSubmit, onInputChange }) => {
  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    // Handle form submission
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    onInputChange(e.target.name, e.target.value);
  };

  return (
    <form onSubmit={handleSubmit}>
      <input 
        type="text" 
        name="email" 
        onChange={handleInputChange} 
      />
    </form>
  );
};
```

### Custom Hook Types
```typescript
// Good - Typed custom hooks
interface UseApiResult<T> {
  data: T | null;
  loading: boolean;
  error: string | null;
  refetch: () => void;
}

function useApi<T>(url: string): UseApiResult<T> {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchData = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await fetch(url);
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const result = await response.json();
      setData(result);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setLoading(false);
    }
  }, [url]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  return { data, loading, error, refetch: fetchData };
}
```

## React Component Guidelines

### Component Structure

#### Functional Components with Hooks
```typescript
// Good - Functional component structure
import React, { useState, useEffect, useCallback } from 'react';
import { UserService } from '../services/UserService';
import { User } from '../types/User';

interface UserProfileProps {
  userId: string;
  onUserUpdate: (user: User) => void;
}

const UserProfile: React.FC<UserProfileProps> = ({ userId, onUserUpdate }) => {
  // State declarations
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Memoized callbacks
  const fetchUser = useCallback(async () => {
    try {
      setLoading(true);
      const userData = await UserService.getUserById(userId);
      setUser(userData);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load user');
    } finally {
      setLoading(false);
    }
  }, [userId]);

  // Effects
  useEffect(() => {
    fetchUser();
  }, [fetchUser]);

  // Event handlers
  const handleUpdateUser = useCallback((updatedUser: User) => {
    setUser(updatedUser);
    onUserUpdate(updatedUser);
  }, [onUserUpdate]);

  // Early returns for loading/error states
  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  if (!user) return <div>User not found</div>;

  // Main render
  return (
    <div className="user-profile">
      <h2>{user.name}</h2>
      <p>{user.email}</p>
      {/* Additional user details */}
    </div>
  );
};

export default UserProfile;
```

#### Component Composition
```typescript
// Good - Composition pattern
interface CardProps {
  children: React.ReactNode;
  className?: string;
}

const Card: React.FC<CardProps> = ({ children, className = '' }) => (
  <div className={`card ${className}`}>
    {children}
  </div>
);

const CardHeader: React.FC<CardProps> = ({ children, className = '' }) => (
  <div className={`card-header ${className}`}>
    {children}
  </div>
);

const CardBody: React.FC<CardProps> = ({ children, className = '' }) => (
  <div className={`card-body ${className}`}>
    {children}
  </div>
);

const CardFooter: React.FC<CardProps> = ({ children, className = '' }) => (
  <div className={`card-footer ${className}`}>
    {children}
  </div>
);

// Usage
const UserCard: React.FC<{ user: User }> = ({ user }) => (
  <Card className="user-card">
    <CardHeader>
      <h3>{user.name}</h3>
    </CardHeader>
    <CardBody>
      <p>{user.email}</p>
      <p>{user.role}</p>
    </CardBody>
    <CardFooter>
      <button>Edit</button>
      <button>Delete</button>
    </CardFooter>
  </Card>
);
```

### Props Guidelines

#### Default Props and Optional Properties
```typescript
// Good - Using default parameters
interface ButtonProps {
  children: React.ReactNode;
  variant?: 'primary' | 'secondary' | 'danger';
  size?: 'small' | 'medium' | 'large';
  disabled?: boolean;
  onClick?: () => void;
}

const Button: React.FC<ButtonProps> = ({
  children,
  variant = 'primary',
  size = 'medium',
  disabled = false,
  onClick
}) => {
  return (
    <button
      className={`btn btn-${variant} btn-${size}`}
      disabled={disabled}
      onClick={onClick}
    >
      {children}
    </button>
  );
};
```

#### Prop Validation with TypeScript
```typescript
// Good - Comprehensive prop interface
interface DataTableProps<T> {
  data: T[];
  columns: Column<T>[];
  onRowClick?: (row: T) => void;
  onSort?: (column: keyof T, direction: 'asc' | 'desc') => void;
  pagination?: {
    page: number;
    pageSize: number;
    total: number;
    onPageChange: (page: number) => void;
  };
  loading?: boolean;
  emptyMessage?: string;
}

interface Column<T> {
  key: keyof T;
  title: string;
  render?: (value: T[keyof T], row: T) => React.ReactNode;
  sortable?: boolean;
  width?: string;
}
```

## Hooks Guidelines

### Custom Hooks

#### State Management Hooks
```typescript
// Good - Custom hook for form handling
interface UseFormOptions<T> {
  initialValues: T;
  validate?: (values: T) => Partial<Record<keyof T, string>>;
  onSubmit: (values: T) => Promise<void> | void;
}

interface UseFormReturn<T> {
  values: T;
  errors: Partial<Record<keyof T, string>>;
  touched: Partial<Record<keyof T, boolean>>;
  isSubmitting: boolean;
  handleChange: (field: keyof T) => (e: React.ChangeEvent<HTMLInputElement>) => void;
  handleBlur: (field: keyof T) => () => void;
  handleSubmit: (e: React.FormEvent) => void;
  resetForm: () => void;
}

function useForm<T extends Record<string, any>>({
  initialValues,
  validate,
  onSubmit
}: UseFormOptions<T>): UseFormReturn<T> {
  const [values, setValues] = useState<T>(initialValues);
  const [errors, setErrors] = useState<Partial<Record<keyof T, string>>>({});
  const [touched, setTouched] = useState<Partial<Record<keyof T, boolean>>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleChange = useCallback((field: keyof T) => (e: React.ChangeEvent<HTMLInputElement>) => {
    setValues(prev => ({ ...prev, [field]: e.target.value }));
    if (touched[field]) {
      setErrors(prev => ({ ...prev, [field]: undefined }));
    }
  }, [touched]);

  const handleBlur = useCallback((field: keyof T) => () => {
    setTouched(prev => ({ ...prev, [field]: true }));
    if (validate) {
      const fieldErrors = validate(values);
      setErrors(prev => ({ ...prev, [field]: fieldErrors[field] }));
    }
  }, [values, validate]);

  const handleSubmit = useCallback(async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);

    if (validate) {
      const validationErrors = validate(values);
      if (Object.keys(validationErrors).length > 0) {
        setErrors(validationErrors);
        setIsSubmitting(false);
        return;
      }
    }

    try {
      await onSubmit(values);
    } catch (error) {
      console.error('Form submission error:', error);
    } finally {
      setIsSubmitting(false);
    }
  }, [values, validate, onSubmit]);

  const resetForm = useCallback(() => {
    setValues(initialValues);
    setErrors({});
    setTouched({});
    setIsSubmitting(false);
  }, [initialValues]);

  return {
    values,
    errors,
    touched,
    isSubmitting,
    handleChange,
    handleBlur,
    handleSubmit,
    resetForm
  };
}
```

#### Data Fetching Hooks
```typescript
// Good - Custom hook for data fetching with caching
interface UseQueryOptions<T> {
  enabled?: boolean;
  refetchInterval?: number;
  onSuccess?: (data: T) => void;
  onError?: (error: Error) => void;
}

function useQuery<T>(
  queryKey: string,
  queryFn: () => Promise<T>,
  options: UseQueryOptions<T> = {}
) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  const [lastFetch, setLastFetch] = useState<number>(0);

  const { enabled = true, refetchInterval, onSuccess, onError } = options;

  const fetchData = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      
      const result = await queryFn();
      setData(result);
      setLastFetch(Date.now());
      
      onSuccess?.(result);
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Unknown error');
      setError(error);
      onError?.(error);
    } finally {
      setLoading(false);
    }
  }, [queryFn, onSuccess, onError]);

  useEffect(() => {
    if (enabled) {
      fetchData();
    }
  }, [enabled, fetchData]);

  useEffect(() => {
    if (refetchInterval && enabled) {
      const interval = setInterval(fetchData, refetchInterval);
      return () => clearInterval(interval);
    }
  }, [refetchInterval, enabled, fetchData]);

  return {
    data,
    loading,
    error,
    refetch: fetchData,
    lastFetch
  };
}
```

### Hook Rules and Best Practices

#### Dependency Arrays
```typescript
// Good - Proper dependency management
const UserList: React.FC = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [filters, setFilters] = useState<UserFilters>({});

  // Memoized filtered users
  const filteredUsers = useMemo(() => {
    return users.filter(user => {
      if (filters.role && user.role !== filters.role) return false;
      if (filters.status && user.status !== filters.status) return false;
      return true;
    });
  }, [users, filters]);

  // Memoized search function
  const searchUsers = useCallback(async (searchTerm: string) => {
    const results = await UserService.searchUsers(searchTerm);
    setUsers(results);
  }, []);

  return (
    <div>
      {/* Component JSX */}
    </div>
  );
};
```

## State Management

### Local State with useState
```typescript
// Good - Local state management
const TodoList: React.FC = () => {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [filter, setFilter] = useState<TodoFilter>('all');

  const addTodo = useCallback((text: string) => {
    const newTodo: Todo = {
      id: Date.now().toString(),
      text,
      completed: false,
      createdAt: new Date()
    };
    setTodos(prev => [...prev, newTodo]);
  }, []);

  const toggleTodo = useCallback((id: string) => {
    setTodos(prev => 
      prev.map(todo => 
        todo.id === id ? { ...todo, completed: !todo.completed } : todo
      )
    );
  }, []);

  const removeTodo = useCallback((id: string) => {
    setTodos(prev => prev.filter(todo => todo.id !== id));
  }, []);

  return (
    <div>
      {/* Component JSX */}
    </div>
  );
};
```

### Context API for Global State
```typescript
// Good - Context for global state
interface AuthContextType {
  user: User | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  loading: boolean;
}

const AuthContext = createContext<AuthContextType | null>(null);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  const login = useCallback(async (email: string, password: string) => {
    try {
      setLoading(true);
      const userData = await AuthService.login(email, password);
      setUser(userData);
    } catch (error) {
      throw error;
    } finally {
      setLoading(false);
    }
  }, []);

  const logout = useCallback(() => {
    AuthService.logout();
    setUser(null);
  }, []);

  useEffect(() => {
    const initAuth = async () => {
      try {
        const userData = await AuthService.getCurrentUser();
        setUser(userData);
      } catch (error) {
        // User not authenticated
      } finally {
        setLoading(false);
      }
    };

    initAuth();
  }, []);

  const value = useMemo(() => ({
    user,
    login,
    logout,
    loading
  }), [user, login, logout, loading]);

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
```

### State Reducer Pattern
```typescript
// Good - useReducer for complex state
interface CartState {
  items: CartItem[];
  total: number;
  discount: number;
  tax: number;
}

type CartAction = 
  | { type: 'ADD_ITEM'; payload: CartItem }
  | { type: 'REMOVE_ITEM'; payload: string }
  | { type: 'UPDATE_QUANTITY'; payload: { id: string; quantity: number } }
  | { type: 'APPLY_DISCOUNT'; payload: number }
  | { type: 'CLEAR_CART' };

const cartReducer = (state: CartState, action: CartAction): CartState => {
  switch (action.type) {
    case 'ADD_ITEM':
      const existingItem = state.items.find(item => item.id === action.payload.id);
      if (existingItem) {
        return {
          ...state,
          items: state.items.map(item =>
            item.id === action.payload.id
              ? { ...item, quantity: item.quantity + action.payload.quantity }
              : item
          )
        };
      }
      return {
        ...state,
        items: [...state.items, action.payload]
      };

    case 'REMOVE_ITEM':
      return {
        ...state,
        items: state.items.filter(item => item.id !== action.payload)
      };

    case 'UPDATE_QUANTITY':
      return {
        ...state,
        items: state.items.map(item =>
          item.id === action.payload.id
            ? { ...item, quantity: action.payload.quantity }
            : item
        )
      };

    case 'APPLY_DISCOUNT':
      return {
        ...state,
        discount: action.payload
      };

    case 'CLEAR_CART':
      return {
        items: [],
        total: 0,
        discount: 0,
        tax: 0
      };

    default:
      return state;
  }
};
```

## Project Structure

### Recommended Directory Structure
```
src/
├── components/          # Reusable components
│   ├── common/         # Generic components
│   ├── forms/          # Form components
│   └── layout/         # Layout components
├── pages/              # Page components
├── hooks/              # Custom hooks
├── context/            # Context providers
├── services/           # API and external services
├── utils/              # Utility functions
├── types/              # TypeScript type definitions
├── constants/          # Application constants
├── assets/             # Static assets
├── styles/             # Global styles
├── tests/              # Test utilities
└── App.tsx             # Main app component
```

### Component Organization
```typescript
// components/common/Button/index.ts
export { default } from './Button';
export type { ButtonProps } from './Button';

// components/common/Button/Button.tsx
import React from 'react';
import { ButtonProps } from './Button.types';
import styles from './Button.module.css';

const Button: React.FC<ButtonProps> = ({ children, variant, ...props }) => {
  return (
    <button className={styles[variant]} {...props}>
      {children}
    </button>
  );
};

export default Button;

// components/common/Button/Button.types.ts
export interface ButtonProps {
  children: React.ReactNode;
  variant: 'primary' | 'secondary' | 'danger';
  onClick?: () => void;
  disabled?: boolean;
}
```

## Styling Guidelines

### CSS Modules
```typescript
// Good - CSS Modules with TypeScript
import styles from './UserCard.module.css';

interface UserCardProps {
  user: User;
  variant?: 'default' | 'compact';
}

const UserCard: React.FC<UserCardProps> = ({ user, variant = 'default' }) => {
  return (
    <div className={`${styles.card} ${styles[variant]}`}>
      <div className={styles.header}>
        <h3 className={styles.name}>{user.name}</h3>
      </div>
      <div className={styles.body}>
        <p className={styles.email}>{user.email}</p>
      </div>
    </div>
  );
};
```

### Styled Components (Alternative)
```typescript
// Good - Styled components with TypeScript
import styled from 'styled-components';

interface StyledButtonProps {
  variant: 'primary' | 'secondary' | 'danger';
  size: 'small' | 'medium' | 'large';
}

const StyledButton = styled.button<StyledButtonProps>`
  padding: ${props => {
    switch (props.size) {
      case 'small': return '8px 16px';
      case 'large': return '16px 32px';
      default: return '12px 24px';
    }
  }};
  
  background-color: ${props => {
    switch (props.variant) {
      case 'primary': return '#007bff';
      case 'danger': return '#dc3545';
      default: return '#6c757d';
    }
  }};
  
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  
  &:hover {
    opacity: 0.9;
  }
  
  &:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
`;
```

## Performance Optimization

### Memoization
```typescript
// Good - React.memo for component memoization
interface UserListItemProps {
  user: User;
  onEdit: (user: User) => void;
  onDelete: (userId: string) => void;
}

const UserListItem = React.memo<UserListItemProps>(({ user, onEdit, onDelete }) => {
  const handleEdit = useCallback(() => {
    onEdit(user);
  }, [user, onEdit]);

  const handleDelete = useCallback(() => {
    onDelete(user.id);
  }, [user.id, onDelete]);

  return (
    <div className="user-item">
      <span>{user.name}</span>
      <button onClick={handleEdit}>Edit</button>
      <button onClick={handleDelete}>Delete</button>
    </div>
  );
});

UserListItem.displayName = 'UserListItem';
```

### Lazy Loading
```typescript
// Good - Lazy loading with Suspense
import React, { Suspense, lazy } from 'react';

const UserDashboard = lazy(() => import('../pages/UserDashboard'));
const AdminDashboard = lazy(() => import('../pages/AdminDashboard'));

const Dashboard: React.FC = () => {
  const { user } = useAuth();

  return (
    <Suspense fallback={<div>Loading dashboard...</div>}>
      {user?.role === 'admin' ? <AdminDashboard /> : <UserDashboard />}
    </Suspense>
  );
};
```

### Virtual Scrolling for Large Lists
```typescript
// Good - Virtual scrolling implementation
interface VirtualListProps<T> {
  items: T[];
  itemHeight: number;
  containerHeight: number;
  renderItem: (item: T, index: number) => React.ReactNode;
}

function VirtualList<T>({ items, itemHeight, containerHeight, renderItem }: VirtualListProps<T>) {
  const [scrollTop, setScrollTop] = useState(0);

  const visibleCount = Math.ceil(containerHeight / itemHeight);
  const totalHeight = items.length * itemHeight;
  const startIndex = Math.floor(scrollTop / itemHeight);
  const endIndex = Math.min(startIndex + visibleCount, items.length);

  const visibleItems = items.slice(startIndex, endIndex);

  return (
    <div 
      style={{ height: containerHeight, overflow: 'auto' }}
      onScroll={e => setScrollTop(e.currentTarget.scrollTop)}
    >
      <div style={{ height: totalHeight, position: 'relative' }}>
        {visibleItems.map((item, index) => (
          <div
            key={startIndex + index}
            style={{
              position: 'absolute',
              top: (startIndex + index) * itemHeight,
              height: itemHeight,
              width: '100%'
            }}
          >
            {renderItem(item, startIndex + index)}
          </div>
        ))}
      </div>
    </div>
  );
}
```

## Testing Guidelines

### Component Testing
```typescript
// Good - Component testing with React Testing Library
import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { UserCard } from './UserCard';

const mockUser: User = {
  id: '1',
  name: 'John Doe',
  email: 'john@example.com',
  role: 'user'
};

describe('UserCard', () => {
  it('renders user information correctly', () => {
    render(<UserCard user={mockUser} />);
    
    expect(screen.getByText('John Doe')).toBeInTheDocument();
    expect(screen.getByText('john@example.com')).toBeInTheDocument();
  });

  it('calls onEdit when edit button is clicked', () => {
    const onEdit = jest.fn();
    render(<UserCard user={mockUser} onEdit={onEdit} />);
    
    fireEvent.click(screen.getByText('Edit'));
    
    expect(onEdit).toHaveBeenCalledWith(mockUser);
  });

  it('shows loading state when user is being updated', async () => {
    const onEdit = jest.fn().mockImplementation(() => new Promise(resolve => setTimeout(resolve, 100)));
    
    render(<UserCard user={mockUser} onEdit={onEdit} />);
    
    fireEvent.click(screen.getByText('Edit'));
    
    expect(screen.getByText('Updating...')).toBeInTheDocument();
    
    await waitFor(() => {
      expect(screen.queryByText('Updating...')).not.toBeInTheDocument();
    });
  });
});
```

### Hook Testing
```typescript
// Good - Custom hook testing
import { renderHook, act } from '@testing-library/react';
import { useCounter } from './useCounter';

describe('useCounter', () => {
  it('should initialize with default value', () => {
    const { result } = renderHook(() => useCounter());
    
    expect(result.current.count).toBe(0);
  });

  it('should initialize with provided value', () => {
    const { result } = renderHook(() => useCounter(5));
    
    expect(result.current.count).toBe(5);
  });

  it('should increment count', () => {
    const { result } = renderHook(() => useCounter(0));
    
    act(() => {
      result.current.increment();
    });
    
    expect(result.current.count).toBe(1);
  });

  it('should decrement count', () => {
    const { result } = renderHook(() => useCounter(5));
    
    act(() => {
      result.current.decrement();
    });
    
    expect(result.current.count).toBe(4);
  });

  it('should reset count', () => {
    const { result } = renderHook(() => useCounter(10));
    
    act(() => {
      result.current.increment();
      result.current.increment();
    });
    
    expect(result.current.count).toBe(12);
    
    act(() => {
      result.current.reset();
    });
    
    expect(result.current.count).toBe(10);
  });
});
```

## Accessibility Guidelines

### ARIA Attributes and Semantic HTML
```typescript
// Good - Accessible component
interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  children: React.ReactNode;
}

const Modal: React.FC<ModalProps> = ({ isOpen, onClose, title, children }) => {
  const modalRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (isOpen && modalRef.current) {
      modalRef.current.focus();
    }
  }, [isOpen]);

  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        onClose();
      }
    };

    if (isOpen) {
      document.addEventListener('keydown', handleEscape);
      return () => document.removeEventListener('keydown', handleEscape);
    }
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return (
    <div 
      className="modal-overlay"
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
      ref={modalRef}
      tabIndex={-1}
    >
      <div className="modal-content">
        <header className="modal-header">
          <h2 id="modal-title">{title}</h2>
          <button
            className="modal-close"
            onClick={onClose}
            aria-label="Close modal"
          >
            ×
          </button>
        </header>
        <main className="modal-body">
          {children}
        </main>
      </div>
    </div>
  );
};
```

### Focus Management
```typescript
// Good - Focus management in forms
const ContactForm: React