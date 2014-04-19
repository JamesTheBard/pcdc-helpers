@echo off

REM  Windows batch file
REM  createUsers.bat
REM  creates users and sets passwords on a Windows system
REM  contact: allynstott@gmail.com

if "%1" == "" (
  echo Batch user creation on a Windows system
  echo.
  echo usage: %0 input.txt
  echo.
  echo input.txt should be in the following format:
  echo username1:password1
  echo username2:password2
  echo username3:password3
  echo ...
  echo.
  exit /B 1
)


for /F "tokens=1,2* delims=:" %%i in (%1) do (
  echo Creating user %%i with password %%j
  net user %%i %%j /add
)