# Guide to `git cherry-pick`

`git cherry-pick` is a command that allows you to apply the changes introduced by existing commits onto your current branch.

## Basic Usage

```bash
git cherry-pick <commit-hash>
```

This applies the changes from the specified commit to your current branch.

## Step-by-Step Example

1. **Find the commit hash**  
    Use `git log` to find the commit you want to cherry-pick.

    ```bash
    git log --oneline
    ```

2. **Checkout your target branch**  
    Switch to the branch where you want to apply the commit.

    ```bash
    git checkout <target-branch>
    ```

3. **Cherry-pick the commit**  
    Apply the commit using its hash.

    ```bash
    git cherry-pick <commit-hash>
    ```

## Cherry-picking Multiple Commits

You can cherry-pick a range of commits:

```bash
git cherry-pick <start-commit-hash>^..<end-commit-hash>
```

## Resolving Conflicts

If there are conflicts, Git will pause and allow you to resolve them. After resolving:

```bash
git add <file>
git cherry-pick --continue
```

To abort the cherry-pick:

```bash
git cherry-pick --abort
```

## Tips

- Use cherry-pick for selective commit transfer, not for merging branches.
- Always review the changes after cherry-picking.

## References

- [Git Documentation: git-cherry-pick](https://git-scm.com/docs/git-cherry-pick)
- [Atlassian Guide: Git Cherry Pick](https://www.atlassian.com/git/tutorials/cherry-pick)