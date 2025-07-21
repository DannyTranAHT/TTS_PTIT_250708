# Git Rebase Guide

## What is `git rebase`?

`git rebase` is a command that lets you move or combine a sequence of commits to a new base commit. It's often used to keep a clean, linear project history.

---

## Basic Example

Suppose you have this history:

```
A---B---C  main
         \
          D---E  feature
```

You want to move your `feature` branch on top of the latest `main`:

```sh
git checkout feature
git rebase main
```

Now the history looks like:

```
A---B---C  main
             \
              D'---E'  feature
```

- `D'` and `E'` are new commits, replayed on top of `C`.

---

## Why Use Rebase?

- **Cleaner history:** Avoids unnecessary merge commits.
- **Easier to review:** Linear history is easier to follow.

---

## Visual Example: Rebase vs Merge

### Using Merge

```
A---B---C---F  main
         \ /
          D---E  feature
```

### Using Rebase

```
A---B---C---D'---E'  main/feature
```

---

## Interactive Rebase

You can also edit, squash, or reorder commits:

```sh
git rebase -i HEAD~3
```

This opens an editor where you can pick, squash, or edit commits.

---

## Tips

- Only rebase local branches that you haven't shared with others.
- Use `git status` and `git log` to check your progress.
- If you hit conflicts, resolve them and run `git rebase --continue`.

---

## Undoing a Rebase

If something goes wrong:

```sh
git rebase --abort
```

---

## Further Reading

- [Git Rebase Documentation](https://git-scm.com/docs/git-rebase)
- [Atlassian Git Rebase Tutorial](https://www.atlassian.com/git/tutorials/rewriting-history/git-rebase)
