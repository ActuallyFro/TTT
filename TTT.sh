#!/bin/sh
ProgVersion="2.0.1"
ProgName="TTT"
ProgUrl="https://raw.githubusercontent.com/ActuallyFro/TTT/master/TTT.sh"

TTT_Mode="default"
TTT_MainMUX="TTT-Main"
TTT_User="TTT"

Session0="Scratch Pad"
Session1="Recon"
Session2="Exploit"
Session3="Persistence"
Session4="PostExploit"

HelpMessage=$(cat<<EOF
Tmux Team Together ($ProgName) v$ProgVersion
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
0. $0: Launch the default TTT workspace
1. $0 -w <workspace name>: Creates a new TTT workspace
2. $0 -K: Kills ALL tmux sessions. (WARNING! This applies to non-TTT windows too!)
3. $0 -c -u <user name>: Creates a user 'overlay'
4. $0 -a -u <user name>: Joins to "$TTT_MainMUX" as a specified user.
5. $0 -L: Shows the current sessions
6. $0 -l -w <workspace OR user>: Shows current windows for a given user/workspace
7. $0 -a -u <workspace name>: Connects as the default 'overlay' on a non-default workspace

Example Invocations
-------------------
1. Default Workspace
 - $0 (Starts  TTT)
 - $0 -c -u actuallyfro (creates a user for the default $0 workspace)
 - $0 -a -u actuallyfro (attaches the user to the workspace)

2. Non-default Workspace
 - $0 -w Box2 (Starts TTT for another workspace)
 - $0 -c -u actuallyfro2 -w Box2 (creates a user for the new)(IT CANT BE the same username!)
 - $0 -a -u actuallyfro2 (attaches the user to the new workspace)

Other Options
-------------
--license - print license
--version - print version number
--install - copy this script to /bin/($ProgName)
--update  - update to the most recent GitHub commit
EOF
)

License=$(cat<<EOF
Copyright (c) 2016 Brandon Froberg

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
EOF
)

while [ "$#" -gt "0" ]; do
   parsearg="$1" #read in the first argument

   case $parsearg in
   -l|--list|--list-all)
      TTT_Mode="list"
   ;;
   -L|--sessions|--List-sessions)
      TTT_Mode="listsessions"
   ;;
   -w|--workspace)
      TTT_MainMUX="$2"
      shift
   ;;
   -c|--create-user|--create)
      TTT_Mode="createuser"
   ;;
   -k|--kill-user)
      TTT_Mode="killalluser"
   ;;
   -K|--kill-all)
      TTT_Mode="killall"
   ;;
   -a|--attach|--attach-session)
      TTT_Mode="attachuser"
      #TTT_User="$2"
      #shift
   ;;
   -u|--user)
      TTT_User="$2"
      shift
   ;;
   -v|-d|--debug)
      DEBUG=YES
   ;;
   ## EXAMPLE COMMANDS -- END ##
   #-----------------------------------#
   --license)
      echo ""
      echo "$License"
      exit
   ;;
   -h|--help)
      echo ""
      echo "$HelpMessage"
      exit
   ;;
   -i|--install)
      echo ""
      echo "Attempting to install $0 to /bin"

      User=`whoami`
      if [ "$User" != "root" ]; then
         echo "[WARNING] Currently NOT root!"
      fi
      cp $0 /bin/$ProgName
      Check=`ls /bin/$ProgName | wc -l`
      if [ "$Check" = "1" ]; then
         echo "$ProgName installed successfully!"
      fi
      exit
   ;;
   --version)
      echo ""
      echo "Version: $ProgVersion"
      echo "md5 (less last line): "`cat $0 | grep -v "###" | md5sum | awk '{print $1}'`
      exit
   ;;
   --crc|--check-script)
      CRCRan=`$0 --version | grep "md5" | tr ":" "\n" | grep -v "md5" | tr -d " "`
      CRCScript=`tail -1 $0 | grep -v "md5sum" | grep -v "cat" | tr ":" "\n" | grep -v "md5" | tr -d " " | grep -v "#"`
      if [ "$CRCRan" = "$CRCScript" ]; then
         echo "$0 is good!"
      else
         echo "The checksums didn't match!"
         echo "1. $CRCRan  (vs.)"
         echo "2. $CRCScript"
      fi
      exit
   ;;
   -u|--update)
   echo ""
   if [ "`which wget`" != "" ]; then
      echo "Grabbing latest GitHub commit..."
      wget $ProgUrl -O /tmp/junk$ProgName
   elif [ "`which curl`" != "" ]; then
      echo "Grabbing latest GitHub commit...with curl...ew"
      curl $ProgUrl > /tmp/junk$ProgName
   else
      echo "... or I cant; Install wget or curl"
   fi

   if [ -f /tmp/junk$ProgName ]; then
      lastVers="$ProgVersion"
      newVers=`cat /tmp/junk$ProgName | grep "Version=" | grep -v "cat" | tr "\"" "\n" | grep "\."`

      lastVersHack=`echo "$lastVers" | tr "." " " | awk '{printf("9%04d%04d%04d",$1,$2,$3)}'`
      newVersHack=`echo "$newVers" | tr "." " " | awk '{printf("9%04d%04d%04d",$1,$2,$3)}'`

      echo ""
      if [ "$lastVersHack" -lt "$newVersHack" ]; then
         echo "Updating $ProgName to $newVers"
         chmod +x /tmp/junk$ProgName

         echo "Checking the CRC..."
         CheckCRC=`/tmp/junk$ProgName --check-script | grep "good" | wc -l`

         if [ "$CheckCRC" = "1" ]; then
            echo "Installing ..."
            /tmp/junk$ProgName --install
         else
            echo "ERROR! The CRC failed, considering file to be bad!"
            rm /tmp/junk$ProgName
            exit
         fi
         rm /tmp/junk$ProgName
      else
         echo "You are up to date! ($lastVers)"
      fi
   else
      echo "Well ... that happened. (Check your Inet; the new $ProgName couldn't be grabbed!"
   fi
   exit
   ;;
   *)
      #The catch all; Throw warnings or don't...
      echo "[WARNING] Option: $1 -- NOT RECOGNIZED!"
   ;;
   esac

   shift #check next parsed arg
done


#if [ "$TTT_Mode" = "default" ];  then
if [ "$TTT_Mode" = "list" ];  then
   tmux list-windows -t $TTT_MainMUX

elif [ "$TTT_Mode" = "listsessions" ];  then
   tmux ls

elif [ "$TTT_Mode" = "attachuser" ];  then
   echo "[$ProgName] Attempting to join to '$TTT_MainMUX' as '$TTT_User'"
   if [ "$TTT_User" = "TTT" ];then
      echo "[$ProgName][WARNING] User is NOT defined... this would take over ALL user overlays"
      echo "[$ProgName][WARNING] Quiting!"
      exit
   fi
   FindName=`tmux ls | grep $TTT_User`
   if [ "$FindName" != "" ]; then
      tmux a -t $TTT_User
   else
      echo "[$ProgName][ERROR] Can't find User '$TTT_User'"
      exit
   fi

elif [ "$TTT_Mode" = "killalluser" ];  then
   echo "[$ProgName] Killing all TMUX sessions for user $TTT_User..."
   Sessions=`tmux ls | grep $TTT_User | awk '{print $1}' | tr -d ":"`
   for i in $Sessions; do
      tmux kill-session -t $i
   done
   Running=`tmux ls | grep $TTT_User | wc -l 2>/dev/null`
   if [ "$Running" = "0" ];then
      echo "[$ProgName] Success!"
   else
      echo "[$ProgName][ERROR] Could NOT stop sessions for $TTT_User. Current sessions: "
      tmux ls
   fi

elif [ "$TTT_Mode" = "killall" ];  then
   echo "[$ProgName] Killing the $TTT_MainMUX workspace..."
   Sessions=`tmux ls | grep $TTT_MainMUX | awk '{print $1}' | tr -d ":"`
   for i in $Sessions; do
      tmux kill-session -t $i
      #tmux killneww -t $TTT_MainMUX -n $Session1
      #tmux neww -t $TTT_MainMUX -n $Session2
      #tmux neww -t $TTT_MainMUX -n $Session3
      #tmux neww -t $TTT_MainMUX -n $Session4
   done
   Running=`tmux ls | grep $TTT_MainMUX | wc -l 2>/dev/null`
   if [ "$Running" = "0" ];then
      echo "[$ProgName] Success!"
   else
      echo "[$ProgName][ERROR] Could NOT stop sessions for $TTT_MainMUX. Current sessions: "
      tmux ls
   fi

elif [ "$TTT_Mode" = "createuser" ];  then
   #TTT_User="$2"
   echo "[$ProgName] Attempting to create New Session (named $TTT_User) attached to $TTT_MainMUX"
   FindName=`tmux ls | grep $TTT_User`
   if [ "$FindName" = "" ]; then
      tmux new -s $TTT_User -t $TTT_MainMUX -d
   else
      echo "[$ProgName][ERROR] User session (named $TTT_User) is already created!"
      echo "[$ProgName][ERROR] Run: '$0 connectas $TTT_User' to connect!"
   fi
fi

if [ "$TTT_Mode" = "default" ]; then
   FindMUX=`tmux ls | grep $TTT_MainMUX`
   if [ "$FindMUX" = "" ]; then
      tmux new -s $TTT_MainMUX -d
      tmux rename-window -t $TTT_MainMUX:0 $Session0
      tmux neww -t $TTT_MainMUX -n $Session1
      tmux neww -t $TTT_MainMUX -n $Session2
      tmux neww -t $TTT_MainMUX -n $Session3
      tmux neww -t $TTT_MainMUX -n $Session4

      #Tmux Settings
         tmux set -g history-limit 10000
         #set color for status bar
         tmux set-option -g status-bg colour235 #base02
         tmux set-option -g status-fg green
         tmux set-option -g status-attr bright

         #set window list colors - red for active and cyan for inactive
         tmux set-window-option -g window-status-fg brightblue #base0
         tmux set-window-option -g window-status-bg colour236
         tmux set-window-option -g window-status-attr dim

         tmux set-window-option -g window-status-current-bg colour235
         tmux set-window-option -g window-status-current-fg yellow #orange
         tmux set-window-option -g window-status-current-attr bright

      echo "DONE! Created the tmux session $TTT_MainMUX with windows:"
      tmux list-windows -t $TTT_MainMUX
   else
      echo "[ERROR] It appears the Session $TTT_MainMUX is already running: "
      echo ""
      tmux ls
      echo ""
      echo ""
      echo "[ERROR] Run '$0 killall' to destroy all running tmux sessions"
   fi
fi

### Current File MD5 (less this line): fd9fb4fe2a9c2d81723dfaf25b693ba4
