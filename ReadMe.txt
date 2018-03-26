---  3/26/18  -  Gitinit launch

NOTE: You must change the repositories of this script manually in the .ahk code before using it to full capacity, by default the repository is GitinitAHK/Sandbox.

See https://github.com/Contactician/Gitinit.AHK/wiki for visual guides, hotkey chart and flowchart.

This is a script for creating empty repositories and syncing them to GitHub, along with basic hotkeys for GitBash.


_____________________
||| MANUAL METHOD |||

With GitBash running and in the target directory (with [OPT] as an optional step):

  1) Create a New Repository on GitHub and copy the link to your clipboard.

  2) (All below steps with GitBash active) Press F22 or use "Create New Repository" = Create a new repository framework. You will be prompted to name it (which needs to be the same as your GitHub repo, spaces automatically convert) and then add a single line of text for the Read Me.

  3) CTRL + Numpad1 = Submit "git init" to initialize this repo

  4) CTRL + SHIFT + Numpad2 = Submit "git add ." to stage all files

  5) [OPT] CTRL + Numpad0 = Submit "git status" to verify staging is correct

  6) CTRL + Numpad3 = Prompt for the commit message, type in your comment and submit with Enter

  7) CTRL + SHIFT + Numpad1 = Prompt "git remote add origin", paste your GitHub link here and press Enter

  8) CTRL + SHIFT + Numpad3 = Submit "git push -u origin master" to sync to GitHub. 

  9) All done! Now reload your GitHub page to see.

________________________
||| AUTOMATED METHOD |||

The above can be done in three steps, and two hotkeys which contain macros for key input.

  1) Create a New Repository on GitHub and copy the link to your clipboard.

  2) Use "Create New Repository" option from the taskbar, name your repo and provide a short description for the ReadMe.

  3) Use "Automate First Commit" and paste the GitHub link when prompted to init, stage, commit and push to GitHub. 

  4) All done!

__________________________
||| UPDATING TO GITHUB |||

  1) Press CTRL + Numpad2 and type in the file/folder to update, or CTRL + SHIFT + Numpad2 to update all.
 
  2) CTRL + Numpad3 to commit with prompt for message.

  3) CTRL + SHIFT + Numpad3 to push to GitHub.  

_______________
||| HOTKEYS |||


^ = CTRL
+ = SHIFT
! = ALT

Misc
	^+BackSpace:: clear
	^v::          (Overrides GitBash for normal Paste)

(If you don't have these, change them in the script
 or use the Taskbar icon menu to access them)
        F22::   Create new repository framework
       ^F22::   Sync Repository to Github
        F23::   Go to Directory1 in GitBash
       ^F23::	Go to Directory2 in GitBash
       +F23::	Go to Directory3 in GitBash
	F24::   Open Windows explorer window of current directory in GitBash

Arrow Keys 
	^Up::      cd ..
	^+Up::     cd ../../
	^Down::    pwd
	^+Down::   ls

Basics
	^j::       cd
	^k::       pwd
	^l::       ls
       +^l::       ls -a
	^i::       git
	^m::       mkdir
	^n::       touch
	^b::       echo "" >> .txt

Numpad keys deal with git
These are modeled after the git workflow  --  Init (1), Stage (2), Commit (3)
	^Numpad1::    git init
	^+Numpad1::   git remote add origin

	^Numpad2::    git add
	^+Numpad2::   git add .

	^Numpad3::    git commit -m ""
	^+Numpad3::   git push -u origin master

	^Numpad0::    git status
	^+Numpad0::   git --help

	^NumpadDot::  ls -a
