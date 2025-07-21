# Coding Guidelines

## Table of Contents
- [TypeScript Guidelines](#typescript-guidelines)
    - [Frontend](#frontend)
    - [Backend](#backend)
- [Flutter Guidelines](#flutter-guidelines)

## Detailed Guidelines
- [Backend](CG_Backend.md)
- [Web](CG_Frontend_web.md)
- [Mobile](CG_Frontend_Mobile.md)

---

## TypeScript Guidelines

### Frontend

- **File Structure**: Organize by feature/module.
- **Component Naming**: Use `PascalCase` for components, `camelCase` for variables/functions.
- **Type Safety**: Always define interfaces/types for props, state, and API responses.
- **State Management**: Use hooks (`useState`, `useReducer`) and context appropriately.
- **Styling**: Prefer CSS-in-JS or CSS Modules. Avoid inline styles.
- **Imports**: Use absolute imports where possible.
- **Testing**: Write unit tests for components and utilities.
- **Linting**: Enforce with ESLint and Prettier.

### Backend

- **Project Structure**: Organize by domain (e.g., controllers, services, models).
- **Type Definitions**: Use interfaces/types for request/response objects and database models.
- **Error Handling**: Centralize error handling middleware.
- **Async/Await**: Use async/await for asynchronous code.
- **Environment Variables**: Store sensitive data in `.env` files.
- **Logging**: Use a logging library (e.g., Winston, Pino).
- **Testing**: Write unit and integration tests.
- **Documentation**: Document APIs with OpenAPI/Swagger.

---

## Flutter Guidelines

- **File Structure**: Organize by feature/module, separate UI, logic, and data layers.
- **Widget Naming**: Use `PascalCase` for widgets, `camelCase` for variables/functions.
- **State Management**: Use Provider, Riverpod, or Bloc for state management.
- **Immutability**: Prefer immutable data structures.
- **Theming**: Use centralized theme data.
- **Assets**: Organize images, fonts, and other assets in dedicated folders.
- **Testing**: Write unit, widget, and integration tests.
- **Linting**: Enforce with `flutter analyze` and format code with `dart format`.

---