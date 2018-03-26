; 3/25/2018
#NoEnv
#SingleInstance, Force
SendMode Input
SetWorkingDir %A_ScriptDir%
Menu, Tray, Icon, %A_WorkingDir%\Resources\toolboxB.ico,, 1

global      GitBash := "mintty.exe"
global 		RepoVar, ReadMeVar, ReadMePath, CurrPath
global  	GitTitleNum, GitTitleCut, GitLength, GitTitle, NewGitTitle, GitFolderNum, GitFolderLength, GitFolder

; Change these to what you need
			Directory1 = %A_WorkingDir%\Sandbox
	 		Directory2 = C:\Users\%A_UserName%\Downloads\atom-windows\Atom\projects
	 		Directory3 = %A_MyDocuments%\GitMaster
global 		CurrDirectory := Directory1


Gosub, GenerateMenu
Gosub, DirectoryPreview

; Comments are made with a semi-colon. Anything to the right of a semi-colon can't be seen by AHK, for humans only.

; Modifying these hotkeys is easy:

	; __:: designates a hotkey. The actions below it will execute until hitting Return and stopping.

	; ^ is Control
	; + is Shift (wouldn't recommend on it's own unless you don't need to capitalize letters as you type)
	; ! is Alt
	; # is Windows Key

	; SendInput, {Raw}Any text here will be sent
	; Send, {This key will be sent}

	; For more, visit https://autohotkey.com/docs/AutoHotkey.htm

; !!! I'm using F20-F24 keys for my macro commands. You can manually change these to different keys in this script's
;     code, or you can right-click on the tray menu icon to access them. 


#IfWinActive ahk_exe mintty.exe ; The script (and all hotkeys) will only work when/if GitBash is the active window

;GitBash hotkeys

	;  Backspace clearing
	^+BackSpace::
		SendInput, {Raw}clear
		Send, {Enter}
		Return

	; Overriding GitBash's hotkeys for a normal paste command
	^v::
		Send, %Clipboard%
		Return

	; Navigate up and look at current directory with Arrow keys
	^Up::
		SendInput, {Raw}cd ..
		Send, {Enter}
		Return
	^+Up::
		SendInput, {Raw}cd ../../
		Send, {Enter}
		Return

	^Down::
		SendInput, {Raw}pwd
		Send, {Enter}
		Return

	^+Down::
		SendInput, {Raw}ls
		Send, {Enter}
		Return

	; Basic shortcuts (all for right hand)
	^j::
		SendInput, {Raw}cd
		SendInput, {Space}
		Return

	^k::
		SendInput, {Raw}pwd
		SendInput, {Enter}
		Return

	^l::
		SendInput, {Raw}ls
		SendInput, {Enter}
		Return

	+^l::
		SendInput, {Raw}ls -a
		SendInput, {Enter}
		Return

	^i::
		SendInput, {Raw}git
		SendInput, {Space}
		Return

	^b::
		SendInput, {Raw}echo "" >> .txt
		SendInput, {Left 9}
		Return

	^n::
		SendInput, {Raw}touch
		SendInput, {Space}
		Return

	^m::
		SendInput, {Raw}mkdir
		SendInput, {Space}
		Return


	; git Numpad keys
	^Numpad1::
		SendInput, {Raw}git init
		SendInput, {Enter}
		Return

	^Numpad2::
		SendInput, {Raw}git add
		SendInput, {Space}
		Return

	^Numpad3::
		SendInput, {Raw}git commit -m ""
		SendInput, {Left}
		Return

	^NumpadEnd::
		SendInput, {Raw}git remote add origin
		SendInput, {Space}
		Return

	^NumpadDown::
		SendInput, {Raw}git add .
		SendInput, {Enter}
		Return

	^NumpadPgdn::
		SendInput, {Raw}git push -u origin master
		SendInput, {Enter}
		Return

	^NumpadIns::
		SendInput, {Raw}git --help
		SendInput, {Enter}
		Return

	^Numpad0::
		SendInput, {Raw}git status
		SendInput, {Enter}
		Return

	^NumpadDot::
		SendInput, {Raw}ls -a
		SendInput, {Enter}
		Return

	^Numpad4::
		SendInput, {Raw}git remote add origin
		SendInput, {Space}
		Return 

	^Numpad5::
		SendInput, {Raw}git remote -v
		SendInput, {Enter}
		Return 

	^Numpad6::
		SendInput, {Raw}git push -u origin master
		SendInput, {Enter}
		Return 

	^!Right::
		SendInput, {Raw}echo "" >> .txt
		SendInput, {Left 9}
		Return


; Scan directory folder for Git
ScanGit:
	WinActivate, ahk_exe mintty.exe
	WinGetTitle, CurrTitle, A
	GitTitleNum := (RegExMatch(CurrTitle, "/c/",,1) + 2)
	GitTitleCut := SubStr(CurrTitle, 1, GitTitleNum)
	GitLength := (StrLen(CurrTitle) - GitTitleNum) + 1
	StringGetPos, GitFolderNum, CurrTitle, /, R
	GitFolderLength := (StrLen(CurrTitle) - GitFolderNum)
	GitFolder := SubStr(CurrTitle, GitFolderNum + 2, GitFolderLength + 1)
	GitTitle := "C:" . SubStr(CurrTitle, GitTitleNum, GitLength)
	NewGitTitle := StrReplace(GitTitle, "/", "\")
	StringGetPos, RepoCut, NewGitTitle, \, R
	RepoPath := SubStr(NewGitTitle, 1, RepoCut)

; To verify variable contents, uncomment the below:
	; MsgBox % "1:" GitTitleNum "`r`n" "2:" GitTitleCut "`r`n" 
	; 		. "3:" GitLength "`r`n" "4:" GitTitle "`r`n" "5:" NewGitTitle "`r`n" 
	; 		. "6:" GitFolderNum "`r`n" "7:" GitFolderLength "`r`n" "8:" GitFolder
Return

; Open window explorer of Git's currently active directory
F24::
GitExplorer:
Gosub ScanGit
	If !WinExist(GitFolder " ahk_class CabinetWClass") {
		Run, explore %NewGitTitle%, Hidden
		WinMove, %GitFolder% ahk_class CabinetWClass,, -10, 0, (A_ScreenWidth/2), A_ScreenHeight
		WinWait, %GitFolder% ahk_class CabinetWClass,, 2
		If ErrorLevel
		{
			MsgBox Explorer failed
		}
	} Else {
		WinActivate, %GitFolder% ahk_class CabinetWClass
	}
Return

; Convert remote path to Git
^F24::
ConvertPath:
	GitPath := StrReplace(Clipboard, "\", "/")
	WinActivate, ahk_exe mintty.exe
	Send, cd{Space}%GitPath%{Enter}
Return


; Create new repository
F22::
NewRepo:
Gosub, ScanGit
	RepoVar := "", ReadMeVar := "", ReadMePath := ""
	FormatTime, CurrTime,, 'Gotinit at' hh:mm:ss tt 'on' MM/dd/yy
;Macro File Tree
	InputBox, RepoVar, Create a new repository, Enter name:,,, 100
		if ErrorLevel {
			MsgBox % "Repository cancelled"
			Return
		}
	RepoVar :=  StrReplace(RepoVar, A_Space, "-")	
	SendInput, {Raw}mkdir
	SendInput, {Space}
	Send, %RepoVar%
	SendInput, {Enter}
	Sleep, 300

	SendInput, cd{Space}
	Send, %RepoVar%
	SendInput, {Enter}
	Sleep, 300

	InputBox, ReadMeVar, Create a ReadMe, Enter a short description:,,, 100
		if ErrorLevel {
			MsgBox % "ReadMe cancelled"
			Return
		}

	SendInput, echo{Space}
		SendInput, {Raw}"
		Send, %CurrTime%
		SendInput, {Raw}"
		SendInput, {Space}>>{Space}ReadMe.txt{Enter}
	Sleep, 300

	; Inserting line breaks manually with AHK
	FileAppend, .`n, %CurrDirectory%\%RepoVar%\ReadMe.txt

	SendInput, echo{Space}-e{Space}
		SendInput, {Raw}"
		Send, %ReadMeVar%
		SendInput, {Raw}"
		SendInput, {Space}>>{Space}ReadMe.txt{Enter}
	Sleep, 300

	SendInput, touch{Space}index.html{Enter}
	Sleep, 300

	SendInput, mkdir{Space}resources{Enter}
	Sleep, 300

	SendInput, cd{Space}resources{Enter}
	Sleep, 300

	SendInput, mkdir{Space}images{Enter}
	Sleep, 300

	SendInput, mkdir{Space}CSS{Enter}
	Sleep, 300

	SendInput, cd{Space}CSS{Enter}
	Sleep, 300

	SendInput, touch{Space}style.css{Enter}
	Sleep, 300

	SendInput, cd{Space}../../{Enter}
	Sleep, 300
Return

; Push repo to github
^F22::
	PushRepo:
	InputBox, GitHubVar, Submit link to sync, Paste your GitHub link here:,,, 100
		if ErrorLevel {
			MsgBox % "Linking cancelled"
			Return
		}

	Winactivate, ahk_exe mintty.exe
	
	SendInput, {Raw}git init
	Send {Enter}

	SendInput, git{Space}add{Space}.{Enter}
	Sleep, 300

	SendInput, git{Space}status{Enter}
	Sleep, 1500

	SendInput, git{Space}commit{Space}-m
	SendInput, {Raw}"Syncing to Git"
	SendInput, {Enter}
	Sleep, 300

	SendInput, git{Space}remote{Space}add{Space}origin{Space}
	Send, %GitHubVar%
	SendInput, {Enter}
	Sleep, 300

	SendInput, git{Space}push{Space}-u{Space}origin{Space}master{Enter}
	Sleep, 300
Return


; Navigate between directories in GitBash
	F23::
	Direct1:
		CurrPath := StrReplace(Directory1, "\", "/")
		SendInput, cd{Space}%CurrPath%{Enter}
		Return

	^F23::
	Direct2:
		CurrPath := StrReplace(Directory2, "\", "/")
		SendInput, cd{Space}%CurrPath%{Enter}
		Return

	+F23::
	Direct3:
		CurrPath := StrReplace(Directory3, "\", "/")
		SendInput, cd{Space}%CurrPath%{Enter}
		Return

; Close GitBash with Escape
Esc::
	WinKill, ahk_exe mintty.exe
Return
#If


; Tray Menu on taskbar
GenerateMenu:
	MenuArray 	:= 	["Dir1", "Dir2", "Dir3", "Change Dir 1", "Change Dir 2", "Change Dir 3"
				   , "Create New Repository", "Automate First Commit"
				   , "Open Working Directory", "Directories", "Flip slashes"
				   , "Reload", "Suspend", "Kill"]
	LabelArray 	:=  ["TrayDir1", "TrayDir2", "TrayDir3", "ChangeDir4", "ChangeDir5", "ChangeDir6"
				   , "TrayNewRepo", "TrayAutoCommit"
				   , "TrayWorkingDirectory", ":Directories", "ConvertPath"
				   , "TrayReload", "TraySuspend", "TrayExit"]

	Menu, Tray, NoStandard
	Loop, % MenuArray.Length()
		{
		If (A_Index = 4)
			Menu, Directories, Add
		If ((A_Index = 9) || (A_Index = 12))
			Menu, Tray, Add
			if (A_Index < 7)
				{
					if (A_Index < 4) {
						Menu, Directories, Add, % MenuArray[A_Index], TrayDir%A_Index%
						Menu, Directories, Icon, % MenuArray[A_Index], %A_WorkingDir%\Resources\%A_Index%.ico
					} Else {
						Menu, Directories, Add, % MenuArray[A_Index], ChangeDir%A_Index%
						Menu, Directories, Icon, % MenuArray[A_Index], %A_WorkingDir%\Resources\%A_Index%.ico
					}
			} else {
				Menu, Tray, Add, % MenuArray[A_Index], % LabelArray[A_Index]
			    Menu, Tray, Icon, % MenuArray[A_Index], %A_WorkingDir%\Resources\%A_Index%.ico
			}
		}
	Return

	TrayPause:
	Pause, Toggle
	if (A_IsPaused)
		Menu, Tray, Icon, %A_WorkingDir%\Resources\toolbox1.ico,, 1
	Else
		Menu, Tray, Icon, %A_WorkingDir%\Resources\toolboxB.ico,, 1
	Return
	 
	TraySuspend:
	Suspend, Toggle
	if (A_IsSuspended)
		Menu, Tray, Icon , %A_WorkingDir%\Resources\toolbox0.ico,, 1
	Else
		Menu, Tray, Icon , %A_WorkingDir%\Resources\toolboxB.ico,, 1
	Menu, Tray, ToggleCheck, Suspend
	Return

	TrayReload:
	Reload
	Return

	ActivateGit:
	WinActivate, ahk_exe mintty.exe
	Return

	TrayDir1:
	Gosub, ActivateGit
	Gosub, Direct1
	Return

	TrayDir2:
	Gosub, ActivateGit
	Gosub, Direct2
	Return

	TrayDir3:
	Gosub, ActivateGit
	Gosub, Direct3
	Return

	ChangeDir4:
	DirNum = 1
	Gosub, ChangeDir
	Return

	ChangeDir5:
	DirNum = 2
	Gosub, ChangeDir
	Return

	ChangeDir6:
	DirNum = 3
	Gosub, ChangeDir
	Return

	ChangeDir:
	Loop, % DirNum 
	{
		If (A_Index < DirNum)
		Continue
		InputBox, NewDir%A_Index%, Changing Directory %A_Index%, Enter new directory:,,, 100
			if ErrorLevel {
				MsgBox % "Change Directory cancelled"
				Return
			}
		Directory%A_Index% := NewDir%A_Index%
	}
	; MsgBox % A_ThisMenu "`r`n" A_ThisMenuItem "`r`n" A_ThisMenuItemPos

	Gosub, DirectoryPreviewChange
	Return

	TrayNewRepo:
  	Gosub, ActivateGit
	Gosub, NewRepo
	Return

	TrayWorkingDirectory:
  	Gosub, ActivateGit
	Gosub, GitExplorer
	Return

	TrayAutoCommit:
  	Gosub, ActivateGit
	Gosub, PushRepo
	Return

	DirectoryPreview:
	Loop, 3
		{
		StringGetPos, Dir%A_Index%Cut, Directory%A_Index%, \, R
		Dir%A_Index%Preview := "../" . SubStr(Directory%A_Index%, Dir%A_Index%Cut + 2, (StrLen(Directory%A_Index%) - Dir%A_Index%Cut + 1))
		; Menu, Directories, Rename, % Dir%A_Index%, % Dir%A_Index%Preview
		Menu, Directories, Disable, Change Dir %A_Index%
		}

		Menu, Directories, Rename, Dir1, %Dir1Preview%
		Menu, Directories, Rename, Dir2, %Dir2Preview%
		Menu, Directories, Rename, Dir3, %Dir3Preview%
	Return


	DirectoryPreviewChange:
 	Directory%DirNum% := NewDir%DirNum%
	Loop, % DirNum
		{
			If (A_Index < DirNum)
			Continue
		StringGetPos, Dir%A_Index%Cut, Directory%A_Index%, \, R
		Dir%A_Index%Preview := "../" . SubStr(Directory%A_Index%, Dir%A_Index%Cut + 2, (StrLen(Directory%A_Index%) - Dir%A_Index%Cut + 1))
		}

		Menu, Directories, Rename, % NewDir%DirNum%, % Dir%DirNum%Preview
	Return

	TrayExit:
	ExitApp