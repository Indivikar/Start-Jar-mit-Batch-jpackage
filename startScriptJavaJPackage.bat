@echo off
setlocal enabledelayedexpansion

rem =======================================
rem               Config
rem =======================================

set "scriptVersion=v1.1.2" 

rem --- Ausgabe wählen: CONSOLE oder LOG ---
rem möglich ist: CONSOLE oder LOG
rem CONSOLE = Ausgabe nur in der Konsole
rem LOG = Ausgabe nur im LOG-File
set "OUTPUT_MODE=CONSOLE" 

rem Welche Datei soll mit Java gestartet werden
set "startDatei=package.exe" 

rem welche "--add-modules" sollen zum Start-Befehl hinzugefügt werden
set "add_modules[0]=javafx.controls"
set "add_modules[1]=javafx.fxml"
set "add_modules[2]=javafx.graphics"
set "add_modules[3]=javafx.base"
set "add_modules[4]=javafx.media"
set "add_modules[5]=javafx.web"
rem ab Java 14 nicht mehr supportet
set "add_modules[6]=javafx.swing"

rem welche "--add-opens" sollen zum Start-Befehl hinzugefügt werden
set "add_opens[0]=javafx.graphics/javafx.css=ALL-UNNAMED"
set "add_opens[1]=javafx.graphics/com.sun.javafx.scene=ALL-UNNAMED"

rem welche Java-Args sollen zum Start-Befehl hinzugefügt werden
set "java_args[0]=-arg1"
set "java_args[1]=-arg2"


rem Liste mit Versionsnummern, nach den gesucht werden sollen, die bevorzugte Version muss oben stehen 
rem ACHTUNG - keine Version auskommenieren, sonst läuft das Script nich mehr
set "javaVersions[0]=14.0.1"
set "javaVersions[1]=11.0.5"
set "javaVersions[2]=11.0.11"
set "javaVersions[3]=12.0.2"
set "javaVersions[4]=13.0.1"

rem Liste mit Pfaden, wo sich die Java-Versionen befinden könnten, der bevorzugte Pfad muss oben stehen
set "pfade[0]=C:\ProgramData\IndivikarAG\runtime\javaVers"
set "pfade[1]=!cd!\runtime"
set "pfade[2]=!cd!\runtime\javaVers"

set "appLocation=%cd%"
REM echo appLocation = %appLocation%.

set "appdata=%APPDATA%"
REM echo appdata = %appdata%.

set "javaLocaton=\bin\java.exe"
set "javafxLocaton=\javafx\lib"

set "gefundene_java_version="
set "gefundene_java_pfad="
set "gefundene_javafx_pfad="

set "isJavaExists=0"
set "isJavaFXExists=0"
set "isRightJavaVersion=0"

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

rem Schleife durchläuft das Array der Java-Versionen
for /F "tokens=1 delims==" %%i in ('set pfade[') do (
    set "pfad=!%%i!"
    REM echo Java-Version: !javaVer!

    rem Schleife durchläuft das Array der Pfade
    for /F "tokens=1 delims==" %%j in ('set javaVersions[') do (        
        set "javaVer=!%%j!"
        REM echo Pfad: !pfad!"
        
        rem Setze den Pfad für Java zusammen
        call set newPfadJavaRuntime=%%pfad:javaVers=!%%j!%%
        call set newPfadJava=!newPfadJavaRuntime!!javaLocaton!
        REM echo newPfadJava: !newPfadJava!
        
        rem Die Release-Datei öffnen und prüfen, ob es die richtige Java-Version ist
        set "releaseFile=!newPfadJavaRuntime!\release"
        if exist "!releaseFile!" (
            for /f "tokens=1,* delims==" %%a in ('findstr /i /c:"JAVA_VERSION" "!releaseFile!"') do (
                set "JAVA_VERSION=%%~b"
                REM echo Die aktuelle Java-Version lautet: "!JAVA_VERSION!"
                
                if "!JAVA_VERSION!" == "!javaVer!" (
                    set "isRightJavaVersion=1"
                )
            )
        )
    
        rem gibt es den Java-Pfad
        if exist "!newPfadJava!" (
            REM echo gefundene Version: !javaVer!
            set "gefundene_java_version=!javaVer!"
            set "gefundene_java_pfad=!newPfadJava!"
            set "isJavaExists=1"
            REM goto :pfad_gefunden
        )
        
        rem Setze den Pfad für JavaFX zusammen
        SET "divider=javaVer"
        CALL SET "after=%%pfad:*!divider!=%%"
        CALL SET "before=%%pfad:!divider!!after!=%%"

        call set newPfadJavaFX=%%pfad:javaVers=!%%j!%%
        call set newPfadJavaFX=!newPfadJavaFX!!javafxLocaton!%%
        
        REM echo newPfadJavaFX: !newPfadJavaFX!
        
        rem gibt es den JavaFX-Pfad
        if exist "!newPfadJavaFX!" (
            REM echo gefundene Version: !javaVer!
            SET "gefundene_javafx_pfad=!newPfadJavaFX!"
            set "isJavaFXExists=1"
            REM goto :pfad_gefunden
        )
        
        rem Wenn ein Java-Pfad und ein JavaFX-Pfad gefunden wurden, zu ":pfad_gefunden" springen
        if !isJavaExists!==1 if !isJavaFXExists!==1 if !isRightJavaVersion!==1 goto :pfad_gefunden
    )
)

rem Wenn kein vorhandener Pfad gefunden wurde, setze die Variable auf einen Standardwert
set "gefundene_java_version=Keine Java-Version gefunden!"
set "gefundene_java_pfad=Kein Java-Pfad gefunden!"
set "gefundene_javafx_pfad=Kein JavaFX-Pfad gefunden!"

:pfad_gefunden
echo Gefundene Java-Version
echo ===============================================================================================================
echo Java-Version: 	!gefundene_java_version!
echo Java-Pfad: 	!gefundene_java_pfad!
echo JavaFX-Pfad: 	!gefundene_javafx_pfad!
echo:

echo folgenden Befehl Testen: Java.exe -Version
echo ===============================================================================================================
echo Java-Version: 	
"!gefundene_java_pfad!" -version
echo:

echo folgende Umgebungsvariable suchen: JAVA_HOME
echo ===============================================================================================================
@echo off
if "%JAVA_HOME%"=="" (
    echo JAVA_HOME ist nicht gesetzt.
) else (
    echo JAVA_HOME: %JAVA_HOME%
)
echo:

rem Wenn alle Bedingungen erfüllt sind, dann zum Programm-Start springen, andernfalls wird das Programm beendet
if !isJavaExists!==1 if !isJavaFXExists!==1 if !isRightJavaVersion!==1 goto :start_app

echo ===============================================================================================================
echo Das Programm "!cd!!startDatei!" wird nicht gestartet, da keine Java-Version gefunden wurde!
echo ===============================================================================================================
echo:
echo:

pause
exit /b 0

:start_app
rem die command-line wird erstellt (Teil 1 der command-line)
rem WICHTIG: Java-Pfad in Anführungszeichen setzen wegen Leerzeichen
set "command="!gefundene_java_pfad!" --module-path "!gefundene_javafx_pfad!""

rem die Module für --add-modules werden in die command-line eingefügt (Teil 2 der command-line)
echo:
echo --add-modules
echo ===============================================================================================================
set "modules_to_add="
for /f "tokens=1 delims=." %%v in ("!gefundene_java_version!") do set "majorVer=%%v"

rem Debug: Zeige die Major-Version
echo Debug: Major Version = !majorVer!

for /F "tokens=1 delims==" %%m in ('set add_modules[') do (
    set "modul=!%%m!"
    echo Debug: Prüfe Modul: !modul!
    
    rem Prüfe, ob javafx.swing bei Java 14+ übersprungen werden soll
    set "skip_module=0"
    if "!majorVer!" GEQ "14" (
        if /I "!modul!"=="javafx.swing" (
            set "skip_module=1"
            echo modules: !modul! "wird nicht verwendet, weil es ab Java 14 nicht mehr supportet wird"
        )
    )
    
    rem Modul hinzufügen, wenn es nicht übersprungen werden soll
    if "!skip_module!"=="0" (
        echo modules: !modul!
        if "!modules_to_add!"=="" (
            set "modules_to_add=!modul!"
        ) else (
            set "modules_to_add=!modules_to_add!,!modul!"
        )
    )
)

echo Debug: Finale Module-Liste: !modules_to_add!

rem Nur --add-modules hinzufügen, wenn Module vorhanden sind
if not "!modules_to_add!"=="" (
    set "command=!command! --add-modules=!modules_to_add!"
) else (
    echo WARNUNG: Keine Module für --add-modules gefunden!
)

rem die --add-opens werden in die command-line eingefügt (Teil 3 der command-line)
echo:
echo --add-opens
echo ===============================================================================================================
for /F "tokens=1 delims==" %%o in ('set add_opens[') do (        
    set "opens=!%%o!"
    echo opens: !opens!
    set "command=!command! --add-opens !opens!"
)

rem die Datei, die gestartet werden soll, wird in die command-line eingefügt (Teil 4 der command-line)
set "command=!command! -jar !startDatei!"

rem die Java-Args werden in die command-line eingefügt (Teil 5 der command-line)
rem Entferne doppelte Args - nur einmal -authStartMitLogin
echo:
echo Java-Args
echo ===============================================================================================================
set "command=!command! -authStartMitLogin"
echo java_args: -authStartMitLogin

echo:
echo Command-Line
echo ===============================================================================================================
echo !command!

echo:
echo ===============================================================================================================
echo Das Programm "!cd!\!startDatei!" wird gestartet!
echo ===============================================================================================================

rem Command-Line ausführen - WICHTIG: call entfernen bei Pfaden in Anführungszeichen
!command!

pause