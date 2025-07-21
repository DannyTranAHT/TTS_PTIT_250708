
## 🕰️ Using Git Reflog

`git reflog` is a powerful tool that records updates to the tip of branches and other references. It helps you recover lost commits or branches, making it invaluable if you accidentally delete work or move a branch pointer.

### What is Reflog?

- Every time you change the HEAD (e.g., commit, rebase, reset, checkout), Git records the previous position in the reflog.
- Reflog is local to your repository and not shared with others.

### Common Commands

- **View the reflog:**  
    ```bash
    git reflog
    ```
    Shows a list of recent HEAD changes with commit hashes.

- **Recover a lost commit:**  
    1. Find the commit hash in the reflog output.
    2. Checkout or create a branch at that commit:
        ```bash
        git checkout <commit-hash>
        # or
        git branch restore-branch <commit-hash>
        ```

- **Clean up old reflog entries:**  
    ```bash
    git reflog expire --expire=30.days.ago --all
    git gc --prune=now
    ```
    Removes reflog entries older than 30 days and cleans up unreachable objects.

### Example Scenario

1. You accidentally reset your branch and lost some commits.
2. Run `git reflog` to see the history of HEAD.
3. Identify the commit you want to recover.
4. Use `git checkout <commit-hash>` or create a new branch to restore your work.

> **Tip:** Reflog is your safety net for recovering lost work. Use it whenever you think something is missing!