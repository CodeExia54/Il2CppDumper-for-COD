@echo off
REM ------------------------------------------------------------
REM  Auto Il2Cpp Dumper Script (Windows)
REM  Usage: auto_dump.bat [folder]
REM  If no folder is given, it uses the current directory.
REM  It looks for one .so file and one global-metadata.dat file.
REM  You can also drag a folder onto this file in Explorer.
REM ------------------------------------------------------------
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"

REM Locate the Il2CppDumper binary. It can sit next to this script (that is how
REM the CI artifacts are laid out) or in one of the local build output folders.
set "DUMPER=%IL2CPPDUMPER%"

if "%DUMPER%"=="" (
    for %%C in (
        "%SCRIPT_DIR%Il2CppDumper.exe"
        "%SCRIPT_DIR%out_win\Il2CppDumper.exe"
        "%SCRIPT_DIR%out_fwdep\Il2CppDumper.exe"
        "%SCRIPT_DIR%out\Il2CppDumper.exe"
    ) do (
        if exist "%%~C" if "!DUMPER!"=="" set "DUMPER=%%~C"
    )
)

if not exist "%DUMPER%" (
    echo [X] Error: Il2CppDumper.exe not found.
    echo     Looked next to this script and in out_win\, out_fwdep\, out\.
    echo     Set IL2CPPDUMPER=C:\path\to\Il2CppDumper.exe to point at it explicitly.
    goto :fail
)

REM Get the target directory (first argument or current directory)
set "TARGET_DIR=%~1"
if "%TARGET_DIR%"=="" set "TARGET_DIR=%CD%"

pushd "%TARGET_DIR%" 2>nul || (
    echo [X] Cannot enter directory %TARGET_DIR%
    goto :fail
)
set "TARGET_DIR=%CD%"

echo [*] Scanning in: %TARGET_DIR%

REM Find .so files (excluding possible backup or temporary files)
set "SO_COUNT=0"
for %%F in ("%TARGET_DIR%\*.so") do (
    echo %%~nxF | findstr /i /c:"backup" /c:"tmp" >nul
    if errorlevel 1 (
        set /a SO_COUNT+=1
        set "SO_!SO_COUNT!=%%~fF"
    )
)

REM Find global-metadata.dat
set "DAT_COUNT=0"
for %%F in ("%TARGET_DIR%\global-metadata.dat") do (
    set /a DAT_COUNT+=1
    set "DAT_!DAT_COUNT!=%%~fF"
)

if %SO_COUNT%==0 (
    echo [X] No .so file found in %TARGET_DIR%
    goto :fail_popd
)

if %DAT_COUNT%==0 (
    echo [X] No global-metadata.dat file found in %TARGET_DIR%
    goto :fail_popd
)

REM If more than one, let the user choose (or just pick the first)
if %SO_COUNT% GTR 1 (
    echo [!] Multiple .so files found:
    for /l %%I in (1,1,%SO_COUNT%) do (
        for %%N in ("!SO_%%I!") do echo    %%I^) %%~nxN
    )
    set "choice="
    set /p "choice=Choose the number (1-%SO_COUNT%, default 1): "
    if "!choice!"=="" set "choice=1"
    call set "SO_FILE=%%SO_!choice!%%"
) else (
    set "SO_FILE=!SO_1!"
)

if not exist "%SO_FILE%" (
    echo [X] Invalid selection.
    goto :fail_popd
)

if %DAT_COUNT% GTR 1 (
    echo [!] Multiple .dat files found:
    for /l %%I in (1,1,%DAT_COUNT%) do (
        for %%N in ("!DAT_%%I!") do echo    %%I^) %%~nxN
    )
    set "choice="
    set /p "choice=Choose the number (1-%DAT_COUNT%, default 1): "
    if "!choice!"=="" set "choice=1"
    call set "DAT_FILE=%%DAT_!choice!%%"
) else (
    set "DAT_FILE=!DAT_1!"
)

if not exist "%DAT_FILE%" (
    echo [X] Invalid selection.
    goto :fail_popd
)

REM Create output directory (named after the .so file)
for %%N in ("%SO_FILE%") do set "BASE_NAME=%%~nN"
set "OUTPUT_DIR=%TARGET_DIR%\%BASE_NAME%_dump"

echo [*] Using:
echo     SO   : %SO_FILE%
echo     DAT  : %DAT_FILE%
echo     OUT  : %OUTPUT_DIR%

if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

REM Run the dumper
echo [*] Running Il2CppDumper...
"%DUMPER%" "%SO_FILE%" "%DAT_FILE%" "%OUTPUT_DIR%"
set "RC=%ERRORLEVEL%"

popd

if "%RC%"=="0" (
    echo [OK] Dump completed successfully. Output in: %OUTPUT_DIR%
) else (
    echo [X] Dumper failed. Check the error messages above.
)

endlocal & exit /b %RC%

:fail_popd
popd
:fail
endlocal & exit /b 1
