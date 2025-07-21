# 🔄 Git Workflow Guide

## 🌳 Branch Structure

- `main` - Production-ready code
- `develop` - Integration branch for features
- Feature branches: `feat/*` (e.g., `feat/login-page`)
- Bug fix branches: `fix/*` (e.g., `fix/auth-token`)

## 📝 Branch Naming Convention

- Features: `feat/description-of-feature`
- Bug fixes: `fix/description-of-bug`
- Use lowercase and hyphens for spaces

## 🚀 Development Workflow

1. Create a new branch from `develop`:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feat/your-feature
   ```

2. Make your changes and commit:
   ```bash
   git add .
   git commit -m "feat: description of changes"
   ```

3. Keep your branch updated:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout feat/your-feature
   git rebase develop
   ```

4. Push your changes:
   ```bash
   git pull --rebase origin develop  # Update with latest changes
   git push origin feat/your-feature
   ```

   If push is rejected due to remote changes:
   ```bash
   git pull --rebase origin feat/your-feature  # Sync with remote branch
   git push origin feat/your-feature
   ```

## 🔄 Merge Process

1. Before creating PR:
   - Ensure all tests pass
   - Rebase with latest `develop`: `git pull --rebase origin develop`
   - Resolve any conflicts

2. Create Pull Request:
   - PR title should match branch prefix (`feat:` or `fix:`)
   - Send to partner for review
   - Resolve any comments on the code


## 📝 Commit Message Format

```
<type>: <description>

[optional body]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code formatting
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance tasks

## ⚠️ Important Rules

1. Never commit directly to `main` or `develop`
2. Always rebase before pushing
3. Keep commits atomic and focused
4. Write clear commit messages
5. Delete branches after
6. Use `git status` often checking state of working directory

# Useful Git features
- [Stash](git_stash.md)
- [Reflog](git_reflog.md)
- [Rebase](git_rebase.md)
- [Cherry-pick](git_cherry_pick.md)
