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
        $tempFolder = (Join-Path -Path "C:\" -ChildPath $guid)
        $ODDownloadUrl = 'https://aka.ms/OneDriveWVD-Installer'

        if (!(Test-Path -Path $tempFolder)) {
            New-Item -Path $tempFolder -ItemType Directory
        }

        Write-Host "AVD AIB Customization OneDrive Apps : Created temp folder $tempFolder"
    }

    Process {

        try {
         
            $ODexePath = Join-Path -Path $tempFolder -ChildPath "OneDriveSetup.exe"

   

    End {

        #Cleanup
   
        $stopwatch.Stop()
        $elapsedTime = $stopwatch.Elapsed
        Write-Host "Ending AVD AIB Customization : OneDrive Apps - Time taken: $elapsedTime"

    }
}

installOneDrive 
