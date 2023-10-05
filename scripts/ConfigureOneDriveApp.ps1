<#Author       : Frans Nijskens
# Usage        : Configure OneDrive app for AVD
#>

#############################################
#         Configure OneDrive app            #
#############################################



[CmdletBinding()] Param (

    
)


function installOneDrive() {


    Begin {

        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        Write-Host "Starting AVD AIB Customization : OneDrive Apps : $((Get-Date).ToUniversalTime())"

        $ODDownloadLinkRegex = 'OneDriveSetup.exe'
        $guid = [guid]::NewGuid().Guid
        $tempFolder = (Join-Path -Path "C:\temp\" -ChildPath $guid)
        $ODDownloadUrl = 'https://aka.ms/OneDriveWVD-Installer'

        if (!(Test-Path -Path $tempFolder)) {
            New-Item -Path $tempFolder -ItemType Directory
        }

        Write-Host "AVD AIB Customization OneDrive Apps : Created temp folder $tempFolder"
    }

    Process {

        try {
         
            $ODexePath = Join-Path -Path $tempFolder -ChildPath "OneDriveSetup.exe"

            Write-Host "AVD AIB Customization OneDrive Apps : Downloading OneDrive Installer into folder $ODexePath"
            $ODResponse = Invoke-WebRequest -Uri "$ODDownloadUrl " -UseBasicParsing -UseDefaultCredentials -OutFile $ODexePath -PassThru

            if ($ODResponse.StatusCode -ne 200) { 
                throw "OneDrive Installation script failed to download OneDrive deployment tool -- Response $($ODResponse.StatusCode) ($($ODResponse.StatusDescription))"
            }

            Write-Host "AVD AIB Customization OneDrive Apps : Setup Registry key"
            New-ItemProperty  -Path "HKLM:\Software\Microsoft\OneDrive"  -Name "AllUsersInstall" -Value 64 -type dword -Force


            $setupExePath = Join-Path -Path $tempFolder -ChildPath 'OneDriveSetup.exe'
            
            Write-Host "AVD AIB Customization OneDrive Apps : Running setup.exe to Install OneDrive"
            $InstallOneDrive = Start-Process -FilePath $setupExePath -ArgumentList "/allusers" -PassThru -Wait -WorkingDirectory $tempFolder -WindowStyle Hidden

            if (!$InstallOneDrive) {
                Throw "AVD AIB Customization OneDrive Apps : Failed to run `"$setupExePath`" to install OneDrive"
            }

            if ( $InstallOneDrive.ExitCode ) {
                Throw "AVD AIB Customization OneDrive Apps : Exit code $($RunSetupExe.ExitCode) returned from `"$setupExePath`" to insstall OneDrive"
            }
             
            Write-Host "AVD AIB Customization OneDrive Apps : Setup Registry key, post install"
            New-ItemProperty  -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"  -Name "OneDrive" -Value "C:\Program Files (x86)\Microsoft OneDrive\OneDrive.exe /background" -type string -Force
            New-ItemProperty  -Path "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive"  -Name "SilentAccountConfig" -Value 1 -type dword -Force
            New-ItemProperty  -Path "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive"  -Name "KFMSilentOptIn" -Value "9b6179a9-c0ce-4b46-89a8-2c455eb9b2ce" -type String -Force

        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSitem)
        }
    }

    End {

        #Cleanup
        if ((Test-Path -Path $tempFolder -ErrorAction SilentlyContinue)) {
            Remove-Item -Path $tempFolder -Force -Recurse -ErrorAction Continue
        }

        $stopwatch.Stop()
        $elapsedTime = $stopwatch.Elapsed
        Write-Host "Ending AVD AIB Customization : OneDrive Apps - Time taken: $elapsedTime"

    }
}

installOneDrive 

