@echo off

REM From .PRG to .C = Harbour
..\..\bin\harbour %1.prg /n
if errorlevel 1 goto end

REM From .C to .EXE = BuildExe
call BLD32W %1 %2

:end
