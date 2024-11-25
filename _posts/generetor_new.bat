@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: 如果没有输入标题，提示用户输入
if "%~1"=="" (
    set /p "title=请输入文章标题: "
) else (
    set "title=%~1"
)

:: 获取当前日期和时间
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set "date_str=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%"
set "datetime_str=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2% %datetime:~8,2%:%datetime:~10,2%:%datetime:~12,2%"

:: 创建文件名（移除标题中的特殊字符）
set "filename=%date_str%-%title%.md"
set "filename=%filename:"=%"
set "filename=%filename:?=%"
set "filename=%filename:/=-%"
set "filename=%filename:\=-%"
set "filename=%filename:<=%"
set "filename=%filename:>=%"
set "filename=%filename:|=%"

:: 创建文件内容
(
echo ---
echo title: %title%
echo date: %datetime_str% +0800
echo categories: []
echo tags: []
echo ---
echo.
) > "%filename%"

echo 文件已创建: %filename%
timeout /t 3
