
## 🗂️ Using Git Stash

`git stash` lets you temporarily save changes that you’re not ready to commit. This is useful if you need to switch branches but don’t want to commit unfinished work.

### Common Commands

- **Save your changes:**  
    ```bash
    git stash
    ```
    This saves your modified files and reverts your working directory to the last commit.

- **List stashes:**  
    ```bash
    git stash list
    ```
    Shows all stashed changes.

- **Apply the latest stash:**  
    ```bash
    git stash apply
    ```
    Brings back your most recent stashed changes.

- **Apply and remove the latest stash:**  
    ```bash
    git stash pop
    ```
    Applies and deletes the latest stash.

- **Drop a specific stash:**  
    ```bash
    git stash drop stash@{0}
    ```
    Removes a specific stash from the list.

### Example Workflow

1. You’re working on a feature but need to quickly fix a bug on another branch.
2. Run `git stash` to save your work.
3. Switch branches and fix the bug.
4. Switch back and run `git stash pop` to restore your changes.

> **Tip:** Stashes are local and not shared with others.