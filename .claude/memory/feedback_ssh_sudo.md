---
name: feedback-ssh-sudo
description: Cannot run sudo commands on remote hosts via SSH from this environment
metadata:
  type: feedback
---

Cannot use sudo over SSH from the Claude Code environment when connecting to remote hosts like sentinel. The user must run sudo commands themselves on the remote host.

**Why:** No TTY available for password prompt; SSH sessions from this environment don't support interactive sudo.

**How to apply:** When needing to run privileged commands on sentinel (or other remote hosts), provide the commands for the user to run themselves rather than attempting them via SSH.
