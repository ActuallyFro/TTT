
Tmux Team Together (TTT) v2.0.1
===============================
This tool is designed to launch a Pentesting Tmux Command and Control Session with a default set of
windows. Ideally these windows are setup to allow a team to compartmentalize work for a better red
team experience.
                                              - ActuallyFro -- 2017"

Commands
--------
--list-all (--list or -l) - Lists all windows for a workspace (see below)
--List-sessions (--sessions or -L) - Lists ALL tmux sessions on the machine
--workspace (-w) - Sets the base workspace for creation or listing of windows
--create-user (--create | -c) - creates a new tmux session
--kill-user (-k) - destroys a user overlay (useful to drop a user with a smaller terminal)
--kill-all (-K) - Lazy means to kill ALL tmux sessions
--attach-session (--attach or -a) - attaches to a created workspace/user overlay
--user (-u) - defines a custom username
--debug (-v or -d) - prints any and all debug/error messages

Use Cases
---------
0. ./TTT.sh: Launch the default TTT workspace
1. ./TTT.sh -w <workspace name>: Creates a new TTT workspace
2. ./TTT.sh -K: Kills ALL tmux sessions. (WARNING! This applies to non-TTT windows too!)
3. ./TTT.sh -c -u <user name>: Creates a user 'overlay'
4. ./TTT.sh -a -u <user name>: Joins to "TTT-Main" as a specified user.
5. ./TTT.sh -L: Shows the current sessions
6. ./TTT.sh -l -w <workspace OR user>: Shows current windows for a given user/workspace
7. ./TTT.sh -a -u <workspace name>: Connects as the default 'overlay' on a non-default workspace

Example Invocations
-------------------
1. Default Workspace
 - ./TTT.sh (Starts  TTT)
 - ./TTT.sh -c -u actuallyfro (creates a user for the default ./TTT.sh workspace)
 - ./TTT.sh -a -u actuallyfro (attaches the user to the workspace)

2. Non-default Workspace
 - ./TTT.sh -w Box2 (Starts TTT for another workspace)
 - ./TTT.sh -c -u actuallyfro2 -w Box2 (creates a user for the new)(IT CANT BE the same username!)
 - ./TTT.sh -a -u actuallyfro2 (attaches the user to the new workspace)

Other Options
-------------
--license - print license
--version - print version number
--install - copy this script to /bin/(TTT)
--update  - update to the most recent GitHub commit
