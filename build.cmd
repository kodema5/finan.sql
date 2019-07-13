echo off
setlocal
rem nodemon -e md -x build
call md2sql.cmd
if %errorlevel% equ 0 goto end

set PGPASSWORD=rei
psql -U postgres -d postgres -f ./src/readme.sql

:end
endlocal