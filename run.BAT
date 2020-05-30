doskey
cls
echo off
tasm %1
if errorlevel 1 goto end
tlink %1
%1
:end
