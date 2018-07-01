#In this section, I chose to use the .net window manager to pick the path. This script could also be modified to accept input from various other methods, like passing command line arguments for the path, or prompting the user to manually input folder paths in the window.

#For example you could prompt for input this way, or set these via arguments
#$path1 = Get-ChildItem -Path (Read-Host -Prompt 'Get path')
#$path2 = Get-ChildItem -Path (Read-Host -Prompt 'Get path')


#Function to set source folder via a system popup window. Stored as a global variable.
function set-sourceFolder()
{
Add-Type -AssemblyName System.Windows.Forms
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
[void]$folderBrowser.ShowDialog()
$global:sPath=$folderBrowser.SelectedPath
$sPath
}

#Function to set A-L destination folder via a system popup window. Stored as a global variable.
function set-destFolder1()
{
Add-Type -AssemblyName System.Windows.Forms
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
[void]$folderBrowser.ShowDialog()
$global:dPath1=$folderBrowser.SelectedPath
$dPath1
}

#funtion to set M-Z destination folder via a system popup window. Stored as a global variable.
function set-destFolder2()
{
Add-Type -AssemblyName System.Windows.Forms
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
[void]$folderBrowser.ShowDialog()
$global:dPath2=$folderBrowser.SelectedPath
$dPath2

}

#Quick and dirty function to check if files are present and proceed with the cleanup function if files exist. It will return an error if none are present.
function check-directory()
{
$files = Get-ChildItem -Path $sPath -Recurse -Force -ErrorAction SilentlyContinue
if (!$files)
{
Write-Host "No files present in source directory. Returning to menu." -ForegroundColor Red

}
else
{
Write-Host "Files found. Proceeding with operation..." -ForegroundColor Green
organize-Files
}
}

#Function to get files and sort them to the selected destination directories. Currently this function does not support handling folders, as it will treat the folder as another item to be sorted. 
#I tried utilzing !$_.psIsContainer and $_.psIsContainer -eq $false to ignore folders, but I cannot make it work with the -and statement yet(I suspect a syntax problem). I skipped this due to time constraint.
function organize-Files()
{
$aFiles = Get-ChildItem -Path $sPath -Recurse -Force -ErrorAction SilentlyContinue | where-object {$_.Name -match '^[a-l]' <#} -and {!$_.psIsContainer}#>} | % { $_.FullName }
$zFiles = Get-ChildItem -Path $sPath -Recurse -Force -ErrorAction SilentlyContinue | where-object {$_.Name -match '^[m-z]' <#} -and {!$_.psIsContainer}#>} | % { $_.FullName }
foreach ($file in $aFiles)
    {
    Copy-Item -Force -Container $file $dPath1
    Remove-Item $file
    }
foreach ($file in $zFiles)
    {
    Copy-Item -Force -Container $file $dPath2
    Remove-Item $file
    }
Write-Host "Operation Successful" -ForegroundColor Green

}

#Basic case switch menu that allows for user selection, ties to various functions above. 
function Action-Prompt
{
     param (
           [string]$Title = 'File Organizer'
     )
     cls
     Write-Host "================ $Title ================"
     Write-Host ""
     Write-Host "1: Set Source Directory" + "Current Selection : " $sPath
     Write-Host "2: Set A-L Destination Directory" + "Current Selection : " $dPath1
     Write-Host "3: Set M-Z Destination Directory" + "Current Selection : " $dPath2
     Write-Host "4: Run Organization Job"
     Write-Host "Q: Press 'Q' to quit."
}

do
{
     Action-Prompt
     $result = Read-Host "Please make a selection"
     switch ($result)
     {
           '1' {
                cls
                'Please pick the file source directory'
                set-sourceFolder
           } '2' {
                cls
                'Plese pick the A-L destination directory'
                set-destFolder1
           } '3' {
                cls
                'Plese pick the M-Z destination directory'
                set-destFolder2
           } '4' {
                'Running Job...'
                check-directory
           } 'q' {
                return
           }

     }
     pause
}
until ($result -eq 'q')

