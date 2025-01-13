:: done by TweakingGuy with a little help of GPT4 :D
@echo off

:: Set partition letters for the old and new Windows
set /p oldPartition="Enter the drive letter for old Windows (e.g., C): "
set /p newPartition="Enter the drive letter for new Windows (e.g., D): "

:: Find the primary user folder on the new Windows partition
for /d %%u in (%newPartition%:\Users\*) do (
    set "folderName=%%~nxu"
    if not "%folderName%"=="Public" if not "%folderName%"=="Default" (
        set "newUser=%%~nxu"
        goto :foundUser
    )
)

:foundUser

:: Loop through all user folders on the old Windows partition and copy Valorant and FortniteGame folders to new primary user on new Windows partition
for /d %%i in (%oldPartition%:\Users\*) do (
    xcopy /s /e /y "%%i\AppData\Local\Valorant" "%newPartition%:\Users\%newUser%\AppData\Local\Valorant"
    xcopy /s /e /y "%%i\AppData\Local\FortniteGame" "%newPartition%:\Users\%newUser%\AppData\Local\FortniteGame"
)

:: Delete specific folders in the new location for Valorant
rd /s /q "%newPartition%:\Users\%newUser%\AppData\Local\Valorant\Saved\Crashes"
rd /s /q "%newPartition%:\Users\%newUser%\AppData\Local\Valorant\Saved\Logs"
rd /s /q "%newPartition%:\Users\%newUser%\AppData\Local\Valorant\Saved\Telemetry"
rd /s /q "%newPartition%:\Users\%newUser%\AppData\Local\Valorant\Saved\webcache"

echo Valorant and FortniteGame folders have been moved. Specific folders for Valorant have been deleted.
pause
