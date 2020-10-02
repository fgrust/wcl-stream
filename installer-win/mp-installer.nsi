Unicode true
ManifestDPIAware true

!define INSTALL64

; Define your application name
!define APPNAME "WCL Virtual Camera"

!ifndef APPVERSION
!define APPVERSION "1.0.0"
!define SHORTVERSION "1.0.0"
!endif

!define APPNAMEANDVERSION "WCL Virtual Camera ${SHORTVERSION}"

; Additional script dependencies
!include WinVer.nsh
!include x64.nsh

; Modern interface settings
!include "MUI.nsh"
!include nsDialogs.nsh

; Include library for dll stuff
!include Library.nsh

; Logging to file
!include Registry.nsh

; Main Install settings
Name "${APPNAMEANDVERSION}"
!ifdef INSTALL64
InstallDir "$PROGRAMFILES64\wcl-virtual-camera"
!else
InstallDir "$PROGRAMFILES32\wcl-virtual-camera"
!endif
InstallDirRegKey HKLM "Software\${APPNAME}" ""

!ifdef INSTALL64
 OutFile "WCL-VirtualCamera-${SHORTVERSION}-Full-Installer-x64.exe"
!else
 OutFile "WCL-VirtualCamera-${SHORTVERSION}-Full-Installer-x86.exe"
!endif

; Use compression
SetCompressor /SOLID LZMA

; Need Admin
RequestExecutionLevel admin

!define MUI_ICON "wcl.ico"
!define MUI_HEADERIMAGE_BITMAP "WCLHeader.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "WCLBanner.bmp"

!define MUI_ABORTWARNING
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "Launch WCL Virtual Camera ${SHORTVERSION}"
!define MUI_FINISHPAGE_RUN_FUNCTION "LaunchWCL"

!define MUI_WELCOMEPAGE_TEXT "This setup will guide you through installing WCL Virtual Camera.\n\nIt is recommended that you close all other applications before starting, including WCL Virtual Camera. This will make it possible to update relevant files without having to reboot your computer.\n\nClick Next to continue."

!define MUI_PAGE_CUSTOMFUNCTION_LEAVE PreReqCheck

!define MUI_HEADERIMAGE
!define MUI_PAGE_HEADER_TEXT "License Information"
!define MUI_PAGE_HEADER_SUBTEXT "Please review the license terms before installing WCL Virtual Camera."
!define MUI_LICENSEPAGE_TEXT_TOP "Press Page Down or scroll to see the rest of the license."
!define MUI_LICENSEPAGE_TEXT_BOTTOM " "
!define MUI_LICENSEPAGE_BUTTON "&Next >"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "resource\core\data\obs-studio\license\gplv2.txt"
!insertmacro MUI_PAGE_DIRECTORY
Page custom VirtualDeviceSelection VirtualDeviceSelectionPageLeave
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

;!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_COMPONENTS
!insertmacro MUI_UNPAGE_INSTFILES

; Set languages (first is default language)
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_RESERVEFILE_LANGDLL


Function PreReqCheck
!ifdef INSTALL64
	${if} ${RunningX64}
	${Else}
		MessageBox MB_OK|MB_ICONSTOP "This version of WCL Virtual Camera is not compatible with your system.  Please use the 32bit (x86) installer."
	${EndIf}
	; Abort on XP or lower
!endif

	${If} ${AtMostWinXP}
		MessageBox MB_OK|MB_ICONSTOP "Due to extensive use of DirectX 10 features, ${APPNAME} requires Windows Vista SP2 or higher and cannot be installed on this version of Windows."
		Quit
	${EndIf}

	; Vista specific checks
	${If} ${IsWinVista}
		; Check Vista SP2
		${If} ${AtMostServicePack} 1
			MessageBox MB_YESNO|MB_ICONEXCLAMATION "${APPNAME} requires Service Pack 2 when running on Vista. Would you like to download it?" IDYES sptrue IDNO spfalse
			sptrue:
				ExecShell "open" "http://windows.microsoft.com/en-US/windows-vista/Learn-how-to-install-Windows-Vista-Service-Pack-2-SP2"
			spfalse:
			Quit
		${EndIf}

		; Check Vista Platform Update
		nsexec::exectostack "$SYSDIR\wbem\wmic.exe qfe where HotFixID='KB971512' get HotFixID /Format:list"
		pop $0
		pop $0
		strcpy $1 $0 17 6
		strcmps $1 "HotFixID=KB971512" gotPatch
			MessageBox MB_YESNO|MB_ICONEXCLAMATION "${APPNAME} requires the Windows Vista Platform Update. Would you like to download it?" IDYES putrue IDNO pufalse
			putrue:
				${If} ${RunningX64}
					; 64 bit
					ExecShell "open" "http://www.microsoft.com/en-us/download/details.aspx?id=4390"
				${Else}
					; 32 bit
					ExecShell "open" "http://www.microsoft.com/en-us/download/details.aspx?id=3274"
				${EndIf}
			pufalse:
			Quit
		gotPatch:
	${EndIf}

!ifdef INSTALL64
	; 64 bit Visual Studio 2017 runtime check
	ClearErrors
	SetOutPath "$TEMP\WCL"
	File "resource\util\check_for_64bit_visual_studio_2017_runtimes.exe"
	ExecWait "$TEMP\WCL\check_for_64bit_visual_studio_2017_runtimes.exe" $R0
	Delete "$TEMP\WCL\check_for_64bit_visual_studio_2017_runtimes.exe"
	RMDir "$TEMP\WCL"
	IntCmp $R0 126 vs2017Missing_64 vs2017OK_64
	vs2017Missing_64:
		MessageBox MB_YESNO|MB_ICONEXCLAMATION "Your system is missing runtime components that ${APPNAME} requires.  Would you like to install them?" IDYES vs2017true_64 IDNO vs2017false_64
		vs2017false_64:
			Quit
		vs2017true_64:
			SetOutPath "$TEMP\WCL"
			File "resource\util\VC_redist.x64.exe"
			ExecWait "$TEMP\WCL\VC_redist.x64.exe"
			Delete "$TEMP\WCL\VC_redist.x64.exe"
			RMDir "$TEMP\WCL"
	vs2017OK_64:
	ClearErrors
!else
	; 32 bit Visual Studio 2017 runtime check
	; ClearErrors
	; GetDLLVersion "vcruntime140.DLL" $R0 $R1
	; GetDLLVersion "msvcp140.DLL" $R0 $R1
	; IfErrors vs2017Missing_32 vs2017OK_32
	; vs2017Missing_32:
	;	MessageBox MB_YESNO|MB_ICONEXCLAMATION "Your system is missing runtime components that ${APPNAME} requires.  Would you like to download them?" IDYES vs2017true_32 IDNO vs2017false_32
	;	vs2017true_32:
	;		ExecShell "open" "https://obsproject.com/visual-studio-2017-runtimes-32-bit"
	;	vs2017false_32:
	;	Quit
	; vs2017OK_32:
	; ClearErrors
!endif

	; DirectX Version Check
	ClearErrors
	GetDLLVersion "D3DCompiler_33.dll" $R0 $R1
	IfErrors dxMissing33 dxOK
	dxMissing33:
	ClearErrors
	GetDLLVersion "D3DCompiler_34.dll" $R0 $R1
	IfErrors dxMissing34 dxOK
	dxMissing34:
	ClearErrors
	GetDLLVersion "D3DCompiler_35.dll" $R0 $R1
	IfErrors dxMissing35 dxOK
	dxMissing35:
	ClearErrors
	GetDLLVersion "D3DCompiler_36.dll" $R0 $R1
	IfErrors dxMissing36 dxOK
	dxMissing36:
	ClearErrors
	GetDLLVersion "D3DCompiler_37.dll" $R0 $R1
	IfErrors dxMissing37 dxOK
	dxMissing37:
	ClearErrors
	GetDLLVersion "D3DCompiler_38.dll" $R0 $R1
	IfErrors dxMissing38 dxOK
	dxMissing38:
	ClearErrors
	GetDLLVersion "D3DCompiler_39.dll" $R0 $R1
	IfErrors dxMissing39 dxOK
	dxMissing39:
	ClearErrors
	GetDLLVersion "D3DCompiler_40.dll" $R0 $R1
	IfErrors dxMissing40 dxOK
	dxMissing40:
	ClearErrors
	GetDLLVersion "D3DCompiler_41.dll" $R0 $R1
	IfErrors dxMissing41 dxOK
	dxMissing41:
	ClearErrors
	GetDLLVersion "D3DCompiler_42.dll" $R0 $R1
	IfErrors dxMissing42 dxOK
	dxMissing42:
	ClearErrors
	GetDLLVersion "D3DCompiler_43.dll" $R0 $R1
	IfErrors dxMissing43 dxOK
	dxMissing43:
	ClearErrors
	GetDLLVersion "D3DCompiler_47.dll" $R0 $R1
	IfErrors dxMissing47 dxOK
	dxMissing47:
	ClearErrors
	GetDLLVersion "D3DCompiler_49.dll" $R0 $R1
	IfErrors dxMissing49 dxOK
	dxMissing49:
	MessageBox MB_YESNO|MB_ICONEXCLAMATION "Your system is missing DirectX components that ${APPNAME} requires. Would you like to download them?" IDYES dxtrue IDNO dxfalse
	dxtrue:
		ExecShell "open" "https://obsproject.com/go/dxwebsetup"
	dxfalse:
	Quit
	dxOK:
	ClearErrors

	; Check previous instance

	OBSInstallerUtils::IsProcessRunning "wcl32.exe"
	IntCmp $R0 1 0 notRunning1
		MessageBox MB_OK|MB_ICONEXCLAMATION "${APPNAME} is already running. Please close it first before installing a new version." /SD IDOK
		Quit
	notRunning1:

	${if} ${RunningX64}
		OBSInstallerUtils::IsProcessRunning "wcl64.exe"
		IntCmp $R0 1 0 notRunning2
			MessageBox MB_OK|MB_ICONEXCLAMATION "${APPNAME} is already running. Please close it first before installing a new version." /SD IDOK
			Quit
		notRunning2:
	${endif}

	SetShellVarContext all

	OBSInstallerUtils::AddInUseFileCheck "$INSTDIR\data\obs-plugins\win-capture\graphics-hook32.dll"
	OBSInstallerUtils::AddInUseFileCheck "$INSTDIR\data\obs-plugins\win-capture\graphics-hook64.dll"
	OBSInstallerUtils::AddInUseFileCheck "$APPDATA\obs-hook\graphics-hook32.dll"
	OBSInstallerUtils::AddInUseFileCheck "$APPDATA\obs-hook\graphics-hook64.dll"
	OBSInstallerUtils::GetAppNameForInUseFiles
	StrCmp $R0 "" gameCaptureNotRunning
		MessageBox MB_OK|MB_ICONEXCLAMATION "Game Capture files are being used by the following applications:$\r$\n$\r$\n$R0$\r$\nPlease close these applications before installing a new version of WCL." /SD IDOK
		Quit
	gameCaptureNotRunning:
FunctionEnd

Var Dialog
Var Label
Var VirtualDeviceNum
var Devices

Function VirtualDeviceSelection

	!insertmacro MUI_HEADER_TEXT "Device Selection" "Virtual devices to install"

	nsDialogs::Create 1018
	Pop $Dialog

	${If} $Dialog == error
		Abort
	${EndIf}

	${NSD_CreateLabel} 0 0 100% 12u "Select the number of virtual cameras to register. Typically, you will not need more than one."
	Pop $Label

	${NSD_CreateDropList} 15u 23u 40u 80u ""
		Pop $VirtualDeviceNum
  
		${NSD_CB_AddString} $VirtualDeviceNum "1"
		${NSD_CB_AddString} $VirtualDeviceNum "2"
		${NSD_CB_AddString} $VirtualDeviceNum "3"
		${NSD_CB_AddString} $VirtualDeviceNum "4"
		${NSD_CB_SelectString} $VirtualDeviceNum "1"

	nsDialogs::Show
	
FunctionEnd

Function VirtualDeviceSelectionPageLeave

        ${NSD_GetText} $VirtualDeviceNum $Devices
		
FunctionEnd


Function filesInUse
	MessageBox MB_OK|MB_ICONEXCLAMATION "Some files were not able to be installed. If this is the first time you are installing WCL, please disable any anti-virus or other security software and try again. If you are re-installing or updating WCL, close any applications that may be have been hooked, or reboot and try again."  /SD IDOK
FunctionEnd

Function LaunchWCL
!ifdef INSTALL64
	Exec '"$WINDIR\explorer.exe" "$SMPROGRAMS\WCL Virtual Camera\WCL Virtual Camera (64bit).lnk"'
!else
	Exec '"$WINDIR\explorer.exe" "$SMPROGRAMS\WCL Virtual Camera\WCL Virtual Camera (32bit).lnk"'
!endif
FunctionEnd

Var outputErrors

Section "WCL Virtual Camera" SecCore

	; Set Section properties
	SectionIn RO
	SetOverwrite on
	AllowSkipFiles off

	SetShellVarContext all

	; Set Section Files and Shortcuts
	SetOutPath "$INSTDIR"
	OBSInstallerUtils::KillProcess "obs-plugins\32bit\cef-bootstrap.exe"
	OBSInstallerUtils::KillProcess "obs-plugins\64bit\cef-bootstrap.exe"

	File /r "resource\core\data"

!ifdef INSTALL64
	SetOutPath "$INSTDIR\bin"
	File /r "resource\core\bin\64bit"
	SetOutPath "$INSTDIR\obs-plugins"
	File /r "resource\core\obs-plugins\64bit"
!else
	SetOutPath "$INSTDIR\bin"
	File /r "resource\core\bin\32bit"
	SetOutPath "$INSTDIR\obs-plugins"
	File /r "resource\core\obs-plugins\32bit"
!endif

	# ----------------------------

	SetShellVarContext all

	#SetOutPath "$INSTDIR"
	#File /r "new\wcl-browser\data"
	#SetOutPath "$INSTDIR\obs-plugins"
	#OBSInstallerUtils::KillProcess "32bit\cef-bootstrap.exe"
	#OBSInstallerUtils::KillProcess "32bit\obs-browser-page.exe"
	#${if} ${RunningX64}
	#	OBSInstallerUtils::KillProcess "64bit\cef-bootstrap.exe"
	#	OBSInstallerUtils::KillProcess "64bit\obs-browser-page.exe"
	#${endif}
!ifdef INSTALL64
	#File /r "new\wcl-browser\obs-plugins\64bit"
	#SetOutPath "$INSTDIR\bin\64bit"
!else
	#File /r "new\wlc-browser\obs-plugins\32bit"
	#SetOutPath "$INSTDIR\bin\32bit"
!endif

	# ----------------------------
	# Copy game capture files to ProgramData
	SetOutPath "$APPDATA\wcl-hook"
	#File "resource\core\data\obs-plugins\win-capture\graphics-hook32.dll"
	File "resource\core\data\obs-plugins\win-capture\graphics-hook64.dll"
	#File "resource\core\data\obs-plugins\win-capture\obs-vulkan32.json"
	File "resource\core\data\obs-plugins\win-capture\obs-vulkan64.json"
	#OBSInstallerUtils::AddAllApplicationPackages "$APPDATA\obs-hook"

	ClearErrors

	IfErrors 0 +2
		StrCpy $outputErrors "yes"

	WriteUninstaller "$INSTDIR\uninstall.exe"

!ifdef INSTALL64
	SetOutPath "$INSTDIR\bin\64bit"
	CreateShortCut "$DESKTOP\WCL Virtual Camera.lnk" "$INSTDIR\bin\64bit\wcl64.exe"
!else
	SetOutPath "$INSTDIR\bin\32bit"
	CreateShortCut "$DESKTOP\WCL Virtual Camera.lnk" "$INSTDIR\bin\32bit\wcl32.exe"
!endif

	CreateDirectory "$SMPROGRAMS\WCL Virtual Camera"

!ifdef INSTALL64
	SetOutPath "$INSTDIR\bin\64bit"
	CreateShortCut "$SMPROGRAMS\WCL Virtual Camera\WCL Virtual Camera (64bit).lnk" "$INSTDIR\bin\64bit\wcl64.exe"
!else
	SetOutPath "$INSTDIR\bin\32bit"
	CreateDirectory "$SMPROGRAMS\WCL Virtual Camera"
	CreateShortCut "$SMPROGRAMS\WCL Virtual Camera\WCL Virtual Camera (32bit).lnk" "$INSTDIR\bin\32bit\wcl32.exe"
!endif

	CreateShortCut "$SMPROGRAMS\WCL Virtual Camera\Uninstall.lnk" "$INSTDIR\uninstall.exe"
	
	StrCmp $outputErrors "yes" 0 +2
	Call filesInUse
	
	SetShellVarContext current
	
	SetOutPath "$APPDATA"
	File /r "resource\user-setting\obs-studio"
	
	ClearErrors
SectionEnd

Section -FinishSection

	SetShellVarContext all

	# ---------------------------------------
	# 64bit vulkan hook registry stuff

	${if} ${RunningX64}
		SetRegView 64
		WriteRegStr HKLM "Software\${APPNAME}" "" "$INSTDIR"

		ClearErrors
		DeleteRegValue HKCU "Software\Khronos\Vulkan\ImplicitLayers" "$APPDATA\obs-hook\obs-vulkan64.json"
		ClearErrors
		WriteRegDWORD HKLM "Software\Khronos\Vulkan\ImplicitLayers" "$APPDATA\obs-hook\obs-vulkan64.json" 0
	${endif}

	# ---------------------------------------
	# 32bit vulkan hook registry stuff

	SetRegView 32
	WriteRegStr HKLM "Software\${APPNAME}" "" "$INSTDIR"

	ClearErrors
	DeleteRegValue HKCU "Software\Khronos\Vulkan\ImplicitLayers" "$APPDATA\obs-hook\obs-vulkan32.json"
	ClearErrors
	WriteRegDWORD HKLM "Software\Khronos\Vulkan\ImplicitLayers" "$APPDATA\obs-hook\obs-vulkan32.json" 0

	# ---------------------------------------
	# Register virtual camera dlls

	
	${if} ${RunningX64}
		Exec '"$SYSDIR\regsvr32.exe" /s "$INSTDIR\data\obs-plugins\win-dshow\obs-virtualcam-module64.dll"'
	${else}
		Exec '"$SYSDIR\regsvr32.exe" /s "$INSTDIR\data\obs-plugins\win-dshow\obs-virtualcam-module32.dll"'
	${endif}
	# ---------------------------------------

	ClearErrors
	SetRegView default

	WriteRegStr HKLM "Software\${APPNAME}" "" "$INSTDIR"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayName" "${APPNAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "UninstallString" "$INSTDIR\uninstall.exe"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "ProductID" "d16d2409-3151-4331-a9b1-dfd8cf3f0d9c"
!ifdef INSTALL64
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayIcon" "$INSTDIR\bin\64bit\wcl64.exe"
!else
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayIcon" "$INSTDIR\bin\32bit\wcl32.exe"
!endif
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "Publisher" "WCL Project"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "HelpLink" "https://obsproject.com"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayVersion" "${APPVERSION}"
	
	; Register Virtual Camera Device
	ExecWait '$WinDir\Sysnative\regsvr32.exe /s /n /i:$Devices $\"$INSTDIR\data\obs-plugins\obs-virtualoutput\obs-virtualsource.dll$\"'
	ExecWait '$SYSDIR\regsvr32.exe /s /n /i:$Devices $\"$INSTDIR\bin\64bit\obs-virtualsource.dll$\"'
	
	SetRegView 64
	WriteRegStr HKLM "Software\Classes\CLSID\{860BB310-5D01-11d0-BD3B-00A0C911CE86}\Instance\{27B05C2D-93DC-474A-A5DA-9BBA34CB2A9C}" "FriendlyName" "WCL-Camera"
	
	SetRegView 32
	WriteRegStr HKLM "Software\Classes\CLSID\{860BB310-5D01-11d0-BD3B-00A0C911CE86}\Instance\{27B05C2D-93DC-474A-A5DA-9BBA34CB2A9C}" "FriendlyName" "WCL-Camera"
	
	; Install Virtual Audio Cable
	SetOutPath "$TEMP\WCL"
	File "resource\audio\vbMmeCable64_win7.inf"
	File "resource\audio\vbaudio_cable64_win7.sys"
	File "resource\audio\vbaudio_cable64_win7.cat"
	File "resource\audio\audio.dll"
	
	UserInfo::GetAccountType
	
	pop $0
	
	${if} $0 != "admin"
		MessageBox mb_iconstop "Administrator rights required!"
		SetErrorLevel 740
		Quit
	${endif}
	
	ExecWait "$TEMP\WCL\audio.dll -i -h"
	
	Delete "$TEMP\WCL\vbMmeCable64_win7.inf"
	Delete "$TEMP\WCL\vbaudio_cable64_win7.sys"
	Delete "$TEMP\WCL\vbaudio_cable64_win7.cat"
	Delete "$TEMP\WCL\audio.dll"
	RMDir "$TEMP\WCL"
	
	; Change Registry for VB-Audio Virtual Cable
	${if} ${RunningX64}
		SetRegView 64
	${endif}
	${registry::Open} "HKLM\SYSTEM\ControlSet001\Enum\ROOT\Media" "/NS='{4d36e96c-e325-11ce-bfc1-08002be10318}' /G /T=REG_SZ" $0
	StrCmp $0 0 close
	${registry::Find} "$0" $1 $2 $3 $4
	StrCmp $1 "" close
	WriteRegStr HKLM "$1" "FriendlyName" "WCL-Audio Virtual Cable"
	Goto +2
close:
	MessageBox MB_OK "Unable to install audio driver."
	${registry::Close} $0
	${registry::Unload}

	SetRegView default
	
	
	MessageBox MB_YESNO|MB_ICONQUESTION "Do you wish to reboot the system?" IDNO +2
	Reboot

SectionEnd

; Modern install component descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${SecCore} "Core WCL Virtual Camera files"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;Uninstall section
Section "un.wcl Program Files" UninstallSection1

	SectionIn RO

	; Remove hook files and vulkan registry
	SetShellVarContext all

	RMDir /r "$APPDATA\wcl-hook"

	SetRegView 32
	DeleteRegValue HKCU "Software\Khronos\Vulkan\ImplicitLayers" "$APPDATA\wcl-hook\obs-vulkan32.json"
	DeleteRegValue HKLM "Software\Khronos\Vulkan\ImplicitLayers" "$APPDATA\wcl-hook\obs-vulkan32.json"
	${if} ${RunningX64}
		SetRegView 64
		DeleteRegValue HKCU "Software\Khronos\Vulkan\ImplicitLayers" "$APPDATA\wcl-hook\obs-vulkan64.json"
		DeleteRegValue HKLM "Software\Khronos\Vulkan\ImplicitLayers" "$APPDATA\wcl-hook\obs-vulkan64.json"
	${endif}
	SetRegView default
	ClearErrors

	; Unregister virtual camera dlls
	Exec '"$SYSDIR\regsvr32.exe" /u /s "$INSTDIR\data\obs-plugins\win-dshow\obs-virtualcam-module32.dll"'
	${if} ${RunningX64}
		Exec '"$SYSDIR\regsvr32.exe" /u /s "$INSTDIR\data\obs-plugins\win-dshow\obs-virtualcam-module64.dll"'
	${endif}

	; Remove from registry...
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"
	DeleteRegKey HKLM "SOFTWARE\${APPNAME}"
	
	; Unregister Virtual Camera Device
	!insertmacro UnInstallLib REGDLL NOTSHARED NOREBOOT_PROTECTED "$INSTDIR\data\obs-plugins\obs-virtualoutput\wcl-virtualsource.dll"
	!define LIBRARY_X64
	!insertmacro UnInstallLib REGDLL NOTSHARED NOREBOOT_PROTECTED "$INSTDIR\bin\64bit\wcl-virtualsource.dll"

	; Delete self
	Delete "$INSTDIR\uninstall.exe"

	; Delete Shortcuts
	Delete "$DESKTOP\WCL Virtual Camera.lnk"
	Delete "$SMPROGRAMS\WCL Virtual Camera\WCL Virtual Camera (32bit).lnk"
	Delete "$SMPROGRAMS\WCL Virtual Camera\Uninstall.lnk"
	${if} ${RunningX64}
		Delete "$SMPROGRAMS\WCL Virtual Camera\WCL Virtual Camera (64bit).lnk"
	${endif}

	IfFileExists "$INSTDIR\data\obs-plugins\win-ivcam\seg_service.exe" UnregisterSegService SkipUnreg
	UnregisterSegService:
	ExecWait '"$INSTDIR\data\obs-plugins\win-ivcam\seg_service.exe" /UnregServer'
	SkipUnreg:

	; Clean up WCL Virtual Camera
	RMDir /r "$INSTDIR\bin"
	RMDir /r "$INSTDIR\data"
	RMDir /r "$INSTDIR\obs-plugins"
	RMDir "$INSTDIR"

	; Remove remaining directories
	RMDir "$SMPROGRAMS\WCL Virtual Camera"
SectionEnd

Section /o "un.User Settings" UninstallSection2
	SetShellVarContext current
	RMDir /r "$APPDATA\obs-studio"
	SetShellVarContext all
	RMDir /r "$APPDATA\wcl-hook"
	
	; Uninstall Virtual Audio Cable
	SetShellVarContext current
	
	SetOutPath "$TEMP\WCL"
	File "resource\audio\audio.dll"
	File "resource\audio\vbMmeCable64_win7.inf"
	File "resource\audio\vbaudio_cable64_win7.sys"
	File "resource\audio\vbaudio_cable64_win7.cat"
	
	ExecWait "$TEMP\WCL\audio.dll -u -h"
	
	Delete "$TEMP\WCL\audio.dll"
	Delete "$TEMP\WCL\vbMmeCable64_win7.inf"
	Delete "$TEMP\WCL\vbaudio_cable64_win7.sys"
	Delete "$TEMP\WCL\vbaudio_cable64_win7.cat"
	RMDir "$TEMP\WCL"
	
	MessageBox MB_YESNO|MB_ICONQUESTION "Do you wish to reboot the system?" IDNO +2
	Reboot
SectionEnd

!insertmacro MUI_UNFUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${UninstallSection1} "Remove the WCL program files."
	!insertmacro MUI_DESCRIPTION_TEXT ${UninstallSection2} "Removes all settings, plugins, scenes and sources, profiles, log files and other application data."
!insertmacro MUI_UNFUNCTION_DESCRIPTION_END

; Version information
VIProductVersion "${APPVERSION}.0"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "WCL Virtual Camera"
VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "Worldcast Live Inc"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "(c) 2012-2020"
; FileDescription is what shows in the UAC elevation prompt when signed
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "WCL Virtual Camera"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "1.0"

; eof
