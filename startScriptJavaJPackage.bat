@echo off
setlocal enabledelayedexpansion

rem =======================================
rem               Config
rem =======================================

set "scriptVersion=v1.0.0" 

rem --- Ausgabe wählen: CONSOLE oder LOG ---
rem möglich ist: CONSOLE oder LOG
rem CONSOLE = Ausgabe nur in der Konsole
rem LOG = Ausgabe nur im LOG-File
set "OUTPUT_MODE=CONSOLE" 

rem Welche Datei soll gestartet werden (die exportierte exe)
set "startDatei=JavaFX-Test-App.exe" 

rem welche Java-Args sollen zum Start-Befehl hinzugefügt werden
set "java_args[0]=-authStartMitLogin"
set "java_args[1]=-authStartMitLogin"

set "appLocation=%cd%"

echo Script-Infos
echo ===============================================================================================================
echo Script-Version:	!scriptVersion!
echo:

rem Erstelle logs-Ordner, falls nicht vorhanden
if not exist "logs" mkdir "logs"

rem Name der Log-Datei mit aktuellem Datum/Uhrzeit, damit sie pro Konsole einzigartig ist
set "logfile=logs\run_%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%.log"
rem Entfernt Leerzeichen in der Zeit, falls TIME 0-padded Stunde hat
set "logfile=%logfile: =0%"

rem Überprüfen der Ausgabeoption und entsprechend umleiten
if not defined _LOGGING_ACTIVE (
    set "_LOGGING_ACTIVE=1"
    
    if /I "%OUTPUT_MODE%"=="LOG" (
        rem Nur ins Log schreiben
        cmd /c "%~f0" %* >"%logfile%" 2>&1
        exit /b %errorlevel%
    ) else if /I "%OUTPUT_MODE%"=="CONSOLE" (
        rem Standardmäßig nur in die Konsole schreiben (keine Umleitung)
        rem Das Skript wird normal fortgesetzt
    )
)

rem Prüfen, ob die Datei die gestartet werden soll, existiert
if not exist "!cd!\!startDatei!" (
    echo ===============================================================================================================
    echo Das Programm "!cd!\!startDatei!" wird nicht gestartet, da die Datei "!startDatei!" nicht gefunden wurde!
    echo ===============================================================================================================
    echo:
    echo:
    pause
    exit /b 0
)

rem Die command-line wird erstellt
set "command=!startDatei!"

rem Die Java-Args werden in die command-line eingefügt (falls benötigt)
echo Java-Args
echo ===============================================================================================================
for /F "tokens=1 delims==" %%a in ('set java_args[') do (        
    set "args=!%%a!"
    echo java_args: !args!
    set "command=!command! !args!"
)

echo:
echo Command-Line
echo ===============================================================================================================
echo !command!

echo:
echo ===============================================================================================================
echo Das Programm "!cd!\!startDatei!" wird gestartet!
echo ===============================================================================================================

rem Command-Line ausführen
call !command!

pause