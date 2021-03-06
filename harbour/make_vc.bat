@echo off
rem
rem $Id$
rem

rem ---------------------------------------------------------------
rem This is a generic template file, if it doesn't fit your own needs
rem please DON'T MODIFY IT.
rem
rem Instead, make a local copy and modify that one, or make a call to
rem this batch file from your customized one. [vszakats]
rem
rem Set any of the below settings to customize your build process:
rem    set HB_BUILD_DLL=yes
rem    set HB_BUILD_DEBUG=yes
rem    set HB_BUILD_VERBOSE=no
rem    set HB_REBUILD_PARSER=yes
rem    set HB_MAKE_PROGRAM=
rem    set HB_SHOW_ERRORS=
rem    set HB_MAKE_FLAGS=
rem
rem To create a WinCE build, use the following settings:
rem    set HB_BUILD_WINCE=yes
rem    set HB_CC_NAME=vcce
rem    set HB=C:\your_harbour_windows_binaries\harbour.exe
rem    set HBPP=C:\your_harbour_windows_binaries\hbpp.exe
rem ---------------------------------------------------------------

set _HB_CC_NAME=%HB_CC_NAME%
set _HB_MAKE_PROGRAM=%HB_MAKE_PROGRAM%

if "%_HB_CC_NAME%"      == "" set _HB_CC_NAME=vc
if "%_HB_MAKE_PROGRAM%" == "" set _HB_MAKE_PROGRAM=nmake.exe

set _HB_MAKEFILE=make_vc.mak
set HB_EXIT_LEVEL=

rem ---------------------------------------------------------------

rem Save the user value, force silent file overwrite with COPY
rem (not all Windows versions support the COPY /Y flag)
set HB_ORGENV_COPYCMD=%COPYCMD%
set COPYCMD=/Y

rem ---------------------------------------------------------------

if "%1" == "clean" goto CLEAN
if "%1" == "Clean" goto CLEAN
if "%1" == "CLEAN" goto CLEAN
if "%1" == "install" goto INSTALL
if "%1" == "Install" goto INSTALL
if "%1" == "INSTALL" goto INSTALL

rem ---------------------------------------------------------------

if not "%HB_BUILD_WINCE%" == "yes" goto BUILD

rem Checking if HB and HBPP are set

if not "%HB%" == "" if exist %HB% goto CHECK_HBPP
   echo.
   echo. *******************************************
   echo. You must set HB environment variable to a
   echo. working copy of Harbour compiler executable
   echo. harbour.exe.
   echo. Example: set HB=C:\harbour\harbour.exe
   echo. *******************************************
   echo.
   goto EXIT

:CHECK_HBPP
if not "%HBPP%" == "" if exist %HBPP% goto BUILD
   echo.
   echo. **********************************************
   echo. You must set HBPP environment variable to a
   echo. working copy of hbpp.exe helper executable
   echo. Example: set HBPP=C:\harbour\hbpp.exe
   echo. **********************************************
   echo.
   goto EXIT

rem ---------------------------------------------------------------

:BUILD

   %_HB_MAKE_PROGRAM% %HB_MAKE_FLAGS% -nologo -f %_HB_MAKEFILE% %1 %2 %3 > make_%_HB_CC_NAME%.log
   if errorlevel 1 set HB_EXIT_LEVEL=1
   if errorlevel 1 if not "%HB_SHOW_ERRORS%" == "no" notepad make_%_HB_CC_NAME%.log
   goto EXIT

:CLEAN

   %_HB_MAKE_PROGRAM% %HB_MAKE_FLAGS% -nologo -f %_HB_MAKEFILE% CLEAN > make_%_HB_CC_NAME%.log
   if errorlevel 1 set HB_EXIT_LEVEL=1
   if errorlevel 1 goto EXIT
   if exist make_%_HB_CC_NAME%.log del make_%_HB_CC_NAME%.log > nul
   if exist inst_%_HB_CC_NAME%.log del inst_%_HB_CC_NAME%.log > nul
   goto EXIT

:INSTALL

   %_HB_MAKE_PROGRAM% %HB_MAKE_FLAGS% -nologo -f %_HB_MAKEFILE% INSTALL > nul
   if errorlevel 1 set HB_EXIT_LEVEL=1
   goto EXIT

:EXIT

rem ---------------------------------------------------------------

rem Restore user value
set COPYCMD=%HB_ORGENV_COPYCMD%

set _HB_CC_NAME=
set _HB_MAKE_PROGRAM=
set _HB_MAKEFILE=

if exist hbpostmk.bat call hbpostmk.bat
