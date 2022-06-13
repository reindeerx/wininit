# Win-Init
Setting up a windows machine.

## Initial Installation Instructions

1. Open PowerShell as an administrator.
1. Change the ExecutionPolicy.(if necessary)
   ```bash
   Set-ExecutionPolicy RemoteSigned -Scope Process -Force
   ```
1. Run the following command::
   ```powershell
   powershell -ExecutionPolicy Bypass ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/reindeerx/wininit/main/init.ps1') | iex)
   ```