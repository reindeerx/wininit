############################################################
# Initialize
############################################################
$ErrorActionPreference = 'Stop'
if ($PSVersionTable.PSVersion.Major -ge 7){
  Import-Module Appx -UseWindowsPowerShell -WarningAction SilentlyContinue
}

############################################################
# Definitons
############################################################
# NOTE: https://github.com/microsoft/winget-cli/releases/latest
$wingetUrl = "https://github.com/microsoft/winget-cli/releases/download/v1.2.10271/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
# NOTE: https://docs.microsoft.com/ja-jp/troubleshoot/developer/visualstudio/cpp/libraries/c-runtime-packages-desktop-bridge#how-to-install-and-update-desktop-framework-packages
$vcLibsUrl = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
$packagesWinGet = @(
   ,'Git.Git'
   ,'7zip.7zip'
   ,'Microsoft.PowerShell'
   ,'gerardog.gsudo'
)
$MyProjectRoot = "c:/Home/Projects"

############################################################
# Functions
############################################################
function Install-WinPackageManagement(){
  Write-Host 'Installing Windows Package Manager:'
  Install-WinGet
  Write-Host ''
}

function Install-WinGet(){
  Write-Host '->Installing WinGet'
  if (!(Get-AppxPackage | Select-String "Microsoft.Winget.Source")){
    $tempPath = [IO.Path]::GetTempPath()
    # VCLibs (prerequisites)
    $outFilePath = $tempPath + [System.IO.Path]::GetFileName($vcLibsUrl)
    Invoke-WebRequest -Uri $vcLibsUrl -OutFile $outFilePath -UseBasicParsing
    add-appxpackage -Path $outFilePath
    # WinGet
    $outFilePath = $tempPath + [System.IO.Path]::GetFileName($wingetUrl)
    Invoke-WebRequest -Uri $wingetUrl -OutFile $outFilePath -UseBasicParsing
    add-appxpackage -Path $outFilePath
    # agree to the Terms of Use 
    ECHO 'Y' | winget list
    Write-Host '-> WinGet has been installed.'
  } else {
    Write-Host '-> WinGet is already installed.'
  }
  Write-Host ''
}

function  Install-WinApps {
  Install-WinAppsByWinGet
}

function  Install-WinAppsByWinGet {
  Write-Host 'Installing applications [WinGet]:'
  $packagesWinGet | ForEach-Object {
    $pkg = "$_"
    Write-Host "-> $pkg"
    if (!(winget list | Select-String $pkg)){
      # NOTE: https://docs.microsoft.com/ja-jp/windows/package-manager/winget/install#options
      winget install --exact --id $pkg
    } else {
      Write-Host "$pkg is already installed."
    }
  }
  Write-Host ''
}

function  Setup-SSH {
  Write-Host 'Creating ssh config file.'
  if (!(Test-Path $env:HOMEPATH/.ssh/config)) {
    New-Item -Path "$env:HOMEPATH/.ssh" -Type Directory -Force

    # Create .ssh/config
    Write-Output @"
Host github.com
  User git
  Port 22
  IdentityFile ~/.ssh/github
  IdentitiesOnly yes
  LogLevel FATAL

Host gitlab.com
  User git
  Port 22
  #IdentityFile ~/.ssh/
  IdentitiesOnly yes
  LogLevel FATAL
"@  | Out-File $env:HOMEPATH/.ssh/config
    #ssh-keygen -t ed25519 -C "e-mail address"
    Write-Host "-> $env:HOMEPATH/.ssh/config was created."
  } else {
    Write-Host '-> Nothing was done.'
  }
  Write-Host ''
}
function  Create-ProjectRoot {
  Write-Host 'Creating Project Root Directory.'
  if (!(Test-Path $MyProjectRoot)) {
    New-Item -Path "$MyProjectRoot" -Type Directory
  }
  Write-Host ''
}

function  Setup-Git {
  Write-Host 'Setting up git.'
  # update git path
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
  git config --global core.autocrlf false
  Write-Host ''
}
############################################################
# Main
############################################################
Set-Location -Path $PSScriptRoot

Install-WinPackageManagement
Install-WinApps
Setup-Git
Setup-SSH
Create-ProjectRoot

Write-Host '*** Done! ***'
