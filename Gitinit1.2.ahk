; 3/25/18 Gitinit created
; 3/26/18 Published to GitHub
; 3/27/18 Solved Change Directories reporting non-existent menu item, now enabled. Added username icon, pushed others down.
; 3/27/18 Created prompt for Username, hotkey for GitHub launch on Chrome, right arrow key for .html, .css, .txt generation
; 4/12/18 Rebuilt hotkeys and other features

; TO - DO
	; Auto-complete for username on prompt

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

global 		inputArray := ["clear{Enter}", "%Clipboard%", "cd "]

; global 		TestArray := 	{"^BackSpace":"clear{Enter}"
; 							, "^v":"%Clipboard%"
; 							, "^j":"cd "}

; global 		TestArray := 	{"^BackSpace":"clear{Enter}"
; 							, "^v":Clipboard
; 							, "^j":"cd "}

Gosub, InputUsername
Gosub, GenerateMenu
Gosub, DirectoryPreview
Gosub, Templates

; SetTimer, ClipCheck, 100

global			hotkeyA :=  {"^BackSpace":"clear{Enter}"
								,"^v":"+{Insert}"
								,"^j":"cd "
								,"^k":"pwd{Enter}"
								,"^l":"ls{Enter}"
								,"+^l":"ls -a{Enter}"
								,"^i":"git "
				         	    ,"^b":"echo """" >> .txt{Left 9}"
				    	        ,"^n":"touch "
				      	        ,"^m":"mkdir "
				      	    	,"^Up":"cd ..{Enter}"
				      	    	,"^+Up":"cd ../../{Enter}"
				      	    	,"^Down":"pwd{Enter}"
								,"^+Down":"ls{Enter}"
								,"^Right":"touch .html{Left 5}"
								,"^+Right":"touch .css{Left 4}"
								,"!Right":"touch .txt{Left 4}"
								,"^!Right":"echo """" >> .txt{Left 9}"
								,"^Numpad1":"git init{Enter}"
								,"^NumpadEnd":"git remote add origin "
								,"^Numpad2":"git add "
								,"^NumpadDown":"git add .{Enter}"
								,"^!Numpad2":"git reset HEAD ."
								,"^Numpad3":"git commit -m """"{Left}"
								,"^NumpadPgdn":"git push -u origin master{Enter}"
								,"^NumpadIns":"git --help{Enter}"
								,"^Numpad0":"git status{Enter}"
								,"^NumpadDot":"ls -a{Enter}"
								,"^Numpad4":"git remote add origin "
								,"^Numpad5":"git remote -v{Enter}" 
								,"^Numpad6":"git push -u origin master{Enter}"}

; ClipChanged() {
; 	hotkeyA.Push({"^v":Clipboard})
; 	; MsgBox % "Changed"
; }

; ClipCheck:
; 	OnClipboardChange("ClipChanged")
; Return

Hotkey, IfWinActive, ahk_exe mintty.exe
for index, value in hotkeyA {
    bf  :=  Func("SendIt").bind(value)
    Hotkey, % index, % bf, On
}
Hotkey, If
Return

SendIt(msg) {
    SendInput, % msg
}

#IfWinActive, ahk_exe mintty.exe

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

F19::
	WinSet, Style, ^0xC00000, ahk_exe mintty.exe
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
			MsgBox, 16, Explorer failed
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
			MsgBox, 16, Repository cancelled, You've interrupted the script.
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
			MsgBox, 16, ReadMe cancelled, You've interrupted the script.
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

	SendInput, mkdir{Space}css{Enter}
	Sleep, 300

	SendInput, cd{Space}css{Enter}
	Sleep, 300

	SendInput, touch{Space}reset.css{Enter}
	Sleep, 300

	SendInput, touch{Space}style.css{Enter}
	Sleep, 300

	SendInput, cd{Space}../../{Enter}
	Sleep, 300

	icoArray := ["0Lemniscate","1Hourglass","1Eye","2Heart","3Triquetra","4Cube"]

	dropIco := CurrDirectory . "\" RepoVar . "\resources\images\"

	vOutput := ""
	Loop, % icoArray.Length()
	{
		ico := icoArray[A_Index]
		; dropIco := CurrDirectory . "\resources\images"
		FileCopy, C:\Users\PortablePawnShop\Documents\GitMaster\%ico%.png, %dropIco%
			if ErrorLevel {
			MsgBox, 16, Files failed to copy.
			Return
			} 
		; FileCopy, C:\My Documents\List1.txt, D:\Main Backup\
		vOutput .= "C:\Users\PortablePawnShop\Documents\GitMaster\" . ico "`r`n" dropIco
	}
	MsgBox % ico ".png" "`r`n" dropIco 
Return


!F24::
; Append:
	htmlDirect := CurrDirectory . "\" . RepoVar . "\" . "index.html"
	cssDirect  := CurrDirectory . "\" . RepoVar . "\resources\css\" . "style.css"
	resetDirect := CurrDirectory . "\" . RepoVar . "\resources\css\" . "reset.css"

FileAppend,
(
%resetVar%
), %resetDirect%

MsgBox % resetDirect
Return


; Push repo to github
^F22::
	PushRepo:
	InputBox, GitHubVar, Submit link to sync, Paste your GitHub link here:,,, 100
		if ErrorLevel {
			MsgBox, 16, Linking cancelled, You've interrupted the script.
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

	MsgBox, 48, Success!, %CurrTime%.
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

F20::
Gosub, ScanGit
If !WinExist("ahk_exe chrome.exe") {
	Run, %A_ProgramFiles% (x86)\Google\Chrome\Application\chrome.exe
	WinWaitActive, New Tab - Google Chrome
		If ErrorLevel
			{
				MsgBox, 16, Chrome has failed, The window was never activated.
				Return
			}
	} Else {
		WinActivate, ahk_exe chrome.exe
			WinWaitActive, ahk_exe chrome.exe
			If ErrorLevel
				{
					MsgBox, 16, Chrome has failed, The window was never activated.
					Return
				}
		IfWinActive, ahk_exe chrome.exe
	 	{
	 		Send, {CtrlDown}{t}{CtrlUp}
	 		Sleep, 100
			SendInput, {Raw}https://github.com/
			Send, %GitUsername%
			SendInput, {Raw}/
			Send, %GitFolder%
			Sleep, 50
			Send, {Enter}
		}
	}
Return

^F20::
If !WinExist("ahk_exe chrome.exe") {
	Run, %A_ProgramFiles% (x86)\Google\Chrome\Application\chrome.exe
	WinWaitActive, New Tab - Google Chrome
		If ErrorLevel
			{
				MsgBox, 16, Chrome has failed, The window was never activated.
				Return
			}
	} Else {
		WinActivate, ahk_exe chrome.exe
			WinWaitActive, ahk_exe chrome.exe
			If ErrorLevel
				{
					MsgBox, 16, Chrome has failed, The window was never activated.
					Return
				}
		IfWinActive, ahk_exe chrome.exe
	 	{
	 		Send, {CtrlDown}{t}{CtrlUp}
	 		Sleep, 100
			SendInput, {Raw}https://
			Send, %GitUsername%
			SendInput, {Raw}.github.io/
			Send, %GitFolder%
			SendInput, {Raw}/
			Sleep, 50
			Send, {Enter}
		}
	}
Return
; Return
#If


; Tray Menu on taskbar
GenerateMenu:
	MenuArray 	:= 	["Dir1", "Dir2", "Dir3", "Change Dir 1", "Change Dir 2", "Change Dir 3"
				   , "GitUser", "Create New Repository", "Automate First Commit"
				   , "Open Working Directory", "Directories", "Flip slashes"
				   , "Reload", "Suspend", "Kill"]
	LabelArray 	:=  ["TrayDir1", "TrayDir2", "TrayDir3", "ChangeDir4", "ChangeDir5", "ChangeDir6"
				   , "gGitUser", "TrayNewRepo", "TrayAutoCommit"
				   , "TrayWorkingDirectory", ":Directories", "ConvertPath"
				   , "TrayReload", "TraySuspend", "TrayExit"]

	Menu, Tray, NoStandard
	Loop, % MenuArray.Length()
		{
		If (A_Index = 4)
			Menu, Directories, Add
		If ((A_Index = 10) || (A_Index = 13))
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

	gGitUser:
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
				MsgBox, 16, Change Directory cancelled, You've interrupted the script.
				Return
			}
		Directory%A_Index% := NewDir%A_Index%
	}

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

	InputUsername:
	If (A_UserName = "PortablePawnShop")
	{
		GitUsername := "Contactician"
		Return		
	} Else {
	InputBox, GitUsername, Enter your GitHub username:,,,, 100
		if ErrorLevel {
			MsgBox, 16, You're not ready to Gitinit, Please have a GitHub account prior to using this script.
			ExitApp
		}
	}
	Return

	DirectoryPreview:
	Loop, 3
		{
		StringGetPos, Dir%A_Index%Cut, Directory%A_Index%, \, R
		Dir%A_Index%Preview := "../" . SubStr(Directory%A_Index%, Dir%A_Index%Cut + 2, (StrLen(Directory%A_Index%) - Dir%A_Index%Cut + 1))
		; Menu, Directories, Rename, % Dir%A_Index%, % Dir%A_Index%Preview
		Menu, Tray, Disable, GitUser
		}
		Menu, Tray, Rename, GitUser, %GitUsername%
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
		Dir%A_Index%PreviewNEW := "../" . SubStr(Directory%A_Index%, Dir%A_Index%Cut + 2, (StrLen(Directory%A_Index%) - Dir%A_Index%Cut + 1))
		}

		Menu, Directories, Rename, % Dir%DirNum%Preview, % Dir%DirNum%PreviewNEW
		; Menu, Directories, Rename, % NewDir%DirNum%, % Dir%DirNum%Preview
	Return

Templates:
resetVar =
(%
/* http://meyerweb.com/eric/tools/css/reset/
   v2.0 | 20110126
   License: none (public domain)
*/

html, body, div, span, applet, object, iframe,
h1, h2, h3, h4, h5, h6, p, blockquote, pre,
a, abbr, acronym, address, big, cite, code,
del, dfn, em, img, ins, kbd, q, s, samp,
small, strike, strong, sub, sup, tt, var,
b, u, i, center,
dl, dt, dd, ol, ul, li,
fieldset, form, label, legend,
table, caption, tbody, tfoot, thead, tr, th, td,
article, aside, canvas, details, embed,
figure, figcaption, footer, header, hgroup,
menu, nav, output, ruby, section, summary,
time, mark, audio, video {
  margin: 0;
  padding: 0;
  border: 0;
  font-size: 100%;
  font: inherit;
  vertical-align: baseline;
}

article, aside, details, figcaption, figure,
footer, header, hgroup, menu, nav, section {
  display: block;
}
body {
  line-height: 1;
}
ol, ul {
  list-style: none;
}
blockquote, q {
  quotes: none;
}
blockquote:before, blockquote:after,
q:before, q:after {
  content: '';
  content: none;
}
table {
  border-collapse: collapse;
  border-spacing: 0;
}
)


; htmlVar =
; (

; )

; cssVar =
; (

; )

Return

MoveFilesAndFolders(SourcePattern, DestinationFolder, DoOverwrite = false)
; Moves all files and folders matching SourcePattern into the folder named DestinationFolder and
; returns the number of files/folders that could not be moved. This function requires [v1.0.38+]
; because it uses FileMoveDir's mode 2.
{
    if DoOverwrite = 1
        DoOverwrite = 2  ; See FileMoveDir for description of mode 2 vs. 1.
    ; First move all the files (but not the folders):
    FileMove, %SourcePattern%, %DestinationFolder%, %DoOverwrite%
    ErrorCount := ErrorLevel
    ; Now move all the folders:
    Loop, %SourcePattern%, 2  ; 2 means "retrieve folders only".
    {
        FileMoveDir, %A_LoopFileFullPath%, %DestinationFolder%\%A_LoopFileName%, %DoOverwrite%
        ErrorCount += ErrorLevel
        if ErrorLevel  ; Report each problem folder by name.
            MsgBox Could not move %A_LoopFileFullPath% into %DestinationFolder%.
    }
    return ErrorCount
}



	TrayExit:
	ExitApp



